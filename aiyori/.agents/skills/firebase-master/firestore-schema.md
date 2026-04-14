# Firestore schema — Therapist ⇄ Patient linking (Firestore + Analytics)

This document defines a minimal, production-ready Firestore schema to link patients to therapists, plus sample documents and recommended indexes. It aligns with the existing project structure that stores user profiles under `users/{uid}` and `users/{uid}/daily_records`.

Goals
- Allow therapists to read only their assigned patients quickly and efficiently.
- Keep patient personal data protected and avoid storing sensitive secrets in plaintext (e.g., `pin`).
- Provide a materialized view for fast therapist-list reads.
- Make analytics joins possible by keeping stable identifiers that map to Firestore document IDs.

Collections (recommended)

- `users/{uid}` (auth user profiles)
  - Fields (common):
    - `uid` (string) — auth uid (same as document id)
    - `name` (string)
    - `email` (string)
    - `role` (string) — one of `patient`, `therapist`, `admin`
    - `profile` (map)
      - `age` (number)
      - `avatar` (string)
      - `riskLevel` (string: `low|medium|high`)
    - `assignedTherapistId` (string) — single therapist id (optional)
    - `therapistIds` (array of strings) — multiple therapists (optional)
    - `createdAt` (timestamp)
    - `updatedAt` (timestamp)
  - Subcollections:
    - `daily_records/{recordId}` — existing per-user daily records (keep as-is).

- `therapists/{therapistId}/patients/{patientId}` (materialized summaries)
  - Purpose: fast reads for therapist UIs (list + key filters). Only server/cloud functions should write these.
  - Fields:
    - `patientId` (string)
    - `name` (string)
    - `age` (number)
    - `avatar` (string)
    - `lastCheckIn` (timestamp)
    - `riskLevel` (string)
    - `summary` (map) — small denormalized metrics (e.g., `sessionsCount`, `avgMood`)
    - `createdAt`, `updatedAt` (timestamps)

- `metrics/*` or BigQuery exports
  - Store derived metrics in BigQuery (recommended) and materialize only the aggregates required by UI back to Firestore.

Design notes and choices
- Single vs multiple therapists: choose `assignedTherapistId` if each patient has a primary therapist. Use `therapistIds` if patients can have multiple therapists.
- Materialization: use Cloud Functions triggers on `users/{uid}` (patient updates) and `users/{uid}/daily_records` to update `therapists/{tid}/patients/{uid}`. Keep these writes server-side to avoid client-side impersonation.
- Avoid storing plain PINs or other credentials in `users` documents. Replace with a salted hash or use Firebase Authentication custom claims if needed.
- Analytics: keep `patientId` values stable and not PII (do not put raw identifiers that identify individuals in public analytics events). Prefer pseudonymous IDs when compliance is unsure.

Sample documents

users/patient_abc123 (patient document)

```json
{
  "uid": "patient_abc123",
  "name": "María González",
  "email": "maria@example.com",
  "role": "patient",
  "profile": { "age": 34, "avatar": "MG", "riskLevel": "low" },
  "assignedTherapistId": "therapist_xyz890",
  "createdAt": "2024-04-01T10:30:00Z",
  "updatedAt": "2024-04-11T12:00:00Z"
}
```

therapists/therapist_xyz890/patients/patient_abc123 (materialized summary)

```json
{
  "patientId": "patient_abc123",
  "name": "María González",
  "age": 34,
  "avatar": "MG",
  "lastCheckIn": "2024-04-11T10:30:00Z",
  "riskLevel": "low",
  "summary": { "sessionsCount": 8, "avgMood": 4.2 },
  "createdAt": "2024-04-01T10:30:00Z",
  "updatedAt": "2024-04-11T12:00:00Z"
}
```

Example queries
- List patients for therapist (fast):
  - `db.collection('therapists').doc(therapistId).collection('patients').orderBy('lastCheckIn', 'desc')` (fast, no composite index required)
- Find patients assigned to a therapist (collection query):
  - `db.collection('users').where('assignedTherapistId', '==', therapistId)` (single-field index automatic)

Recommended indexes (export as `firestore.indexes.json`)
- Index for ordering patients by `updatedAt` within `users` when filtering by `assignedTherapistId` (useful if you choose to query `users` directly):

See the accompanying `firestore.indexes.json` for the suggested index entries.

Next steps
- Implement server-side Cloud Functions to maintain the materialized `therapists/{id}/patients/{pid}` collection (sync on `users` update and `daily_records` updates).
- Add Firestore rules to restrict writes to materialized collections to server service accounts only (move to step B).
- Instrument `StatisticsScreen` to log analytics events (step D) once the model is in place.

Files added alongside this document:
- `sample_docs/patient_example.json`
- `sample_docs/therapist_patient_summary.json`
- `firestore.indexes.json`

If you want, I can also generate a seeding script for the emulator to populate these samples automatically.
