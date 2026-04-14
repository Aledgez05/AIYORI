---
name: analytics-flow
description: "Generate a data flow, event taxonomy, BigQuery mapping and Firestore materialization plan for a Firestore-driven app (Flutter-first)."
---

I have a Firestore-backed Flutter app. Produce a concise analytics data-flow plan and the following artifacts:

- `event-taxonomy.md`: list of events (name, description, required params, mapping to Firestore doc IDs), privacy notes for each event.
- `bigquery/aggregations.sql`: one or two example scheduled SQL queries (daily active users, 7-day retention).
- `materialization-plan.md`: approach to materialize aggregates back to Firestore (idempotency, triggers, schedules).

Defaults and constraints:
- Avoid sending PII; prefer pseudonymous IDs if compliance is unknown.
- Keep event names lowercase and snake_case.
- Assume `user_id` or `patient_id` maps to Firestore document IDs when provided.

Return the artifacts as files and a short checklist to validate each item.
