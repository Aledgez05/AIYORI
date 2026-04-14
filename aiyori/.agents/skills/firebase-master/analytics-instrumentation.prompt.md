---
name: analytics-instrumentation
description: "Generate Flutter analytics instrumentation snippets and a Cloud Function skeleton to materialize aggregates into Firestore."
---

Given an event list (e.g., `patient_view`, `medication_taken`, `record_update`), produce:

- `analytics_snippets.dart`: Flutter helper functions to initialize analytics and log events (with parameter validation and pseudonymous ID handling).
- `functions/analytics_bridge/index.js`: Cloud Function skeleton (Node) to run scheduled aggregations or react to BigQuery export notifications and write aggregated metrics to Firestore.
- A short test plan describing how to smoke-test analytics events end-to-end (client → BigQuery → aggregate → Firestore).

Defaults:
- Use pseudonymous IDs when `PII` handling is unknown.
- Keep code minimal and idiomatic for Flutter and Node.
