---
name: firebase-master
description: "Workspace-scoped skill: Focused on Firestore data flows and Firebase Analytics instrumentation for apps (Flutter-first). Includes event taxonomy, instrumentation snippets, BigQuery export patterns, and safe defaults for security and privacy."
---

# Firebase — Firestore + Analytics Skill (Data Flow & Instrumentation)

Purpose
- Provide a workspace-scoped, actionable workflow and assets to design Firestore data flows, instrument Firebase Analytics, export analytics to BigQuery, and connect analytics-derived insights back to product data.

Scope & Assumptions
- Workspace-scoped: templates and prompts stored in the repo for team use.
- Primary datastore: Firestore (as used in this codebase).
- Primary client: Flutter (Dart) samples included; notes for web/Node/mobile where relevant.
- Compliance: unknown for this workspace. This skill includes privacy-safe defaults and placeholders — consult legal/compliance for PII/PHI handling and formal sign-off.

High-level data flow
- App events (client) → Firebase Analytics (raw events)
  → BigQuery export (raw events) → transforms/aggregation (scheduled SQL)
  → Aggregates / signals written to Firestore (or surfaced via BI dashboards)
  Optional: Firestore writes or Cloud Functions can also emit analytics events when server-side operations occur.

Data Flow & Analytics Integration Steps
1. Define Event Taxonomy
   - Identify critical product events (names, required params, user_id, entity_id) and map to Firestore document IDs where applicable.
   - Avoid sending PII; if needed, send hashed identifiers and document mapping to control access.
2. Instrument the Client (Flutter examples)
   - Add `firebase_analytics` to `pubspec.yaml` and initialize in app startup.
   - Log events consistently with recommended naming and parameters.
   Sample (Dart):

   ```dart
   final analytics = FirebaseAnalytics.instance;
   // log patient view
   await analytics.logEvent(
     name: 'patient_view',
     parameters: {
       'patient_id': patientId,
       'source': 'patient_detail_screen',
     },
   );
   ```

3. Attach Identifiers & User Properties
   - Set a stable `user_id` (only if compliant) via Analytics `setUserId`, or set a pseudonymous identifier as a user property.
   - Ensure `patient_id` or `record_id` values map to Firestore doc IDs so analytics/BI joins are possible.
4. Enable BigQuery Export
   - Turn on Firebase Analytics → BigQuery export in the Firebase console for the project and a selected dataset.
   - Use the exported `events_*` tables for raw analysis and scheduled aggregation queries.
5. Aggregation & Materialization
   - Write scheduled SQL to compute daily/weekly aggregates, funnels, and cohorts in BigQuery.
   - If app UI requires fast read access to aggregates, materialize aggregates back into Firestore with an idempotent write process (Cloud Scheduler → Cloud Function or Airflow job).
6. Server-side Events & Cloud Functions
   - Use Cloud Functions to produce analytics events for server workflows (e.g., background processing that should be tracked).
   - Example pattern: Firestore onWrite trigger → compute derived metric → write to `metrics/` collection and optionally call `analytics.logEvent` on server via Measurement Protocol (server-side integration) when needed.
7. Security & Privacy
   - Firestore rules: enforce least privilege and deny writes to analytics-mirrored collections by clients.
   - Avoid storing raw PII in analytics exports unless encrypted, documented, and legally permitted. Use hashed IDs and access controls.

Implementation Artifacts This Skill Can Generate
- `event-taxonomy.md` — canonical list of events + parameters + mappings to Firestore doc IDs.
- `analytics_snippets.dart` — Flutter initialization and common logEvent wrappers.
- `functions/analytics_bridge/index.js` — Cloud Function skeletons for materialization and server-side analytics hooks.
- `bigquery/aggregations.sql` — example scheduled queries for cohorts, retention, and funnels.
- `firestore.rules` (template) — safe defaults for metric collections and PII-protected collections.
- `analytics-integration.prompt.md` & `analytics-flow.prompt.md` — quick prompts to re-run audits or generate artifacts.

Quality Criteria / Completion Checks
- Event taxonomy documented and reviewed by product/analytics owners.
- Instrumentation snippets added to code (Flutter) and covered by smoke tests.
- BigQuery exports enabled and a sample aggregation query produces expected rows.
- Aggregates used in UI are materialized via idempotent jobs and protected by rules.

Example Prompts (use these to invoke the skill quickly)
- "Create an event taxonomy for patient interactions (view, update, medication_taken) and map parameters to Firestore IDs."
- "Generate Flutter `analytics_snippets.dart` that logs `patient_view` and `medication_taken` events with safe user identifiers." 
- "Produce a Cloud Function skeleton that aggregates daily patient-views and writes counts to `metrics/daily_patient_views/{date}` in Firestore." 
- "Write sample BigQuery SQL to compute 7-day retention for users who completed onboarding."

Ambiguities & Questions (minimal)
- Confirm primary platform: Flutter (assumed from codebase). If incorrect, specify target platforms.
- Confirm whether PII/PHI is allowed; if not sure, we will default to pseudonymous IDs and minimal event params.

Next Actions I took
1. Finalized this workspace SKILL focused on Firestore + Analytics.
2. Added prompt templates for analytics flow and instrumentation (see below).

Where the skill file lives
- [.agents/skills/firebase-master/SKILL.md](.agents/skills/firebase-master/SKILL.md)

If you want, I can now generate the Flutter snippets, Cloud Function skeletons, and BigQuery SQL automatically — shall I proceed?

