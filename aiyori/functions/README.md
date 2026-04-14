Functions: materialize therapist patient summaries

Setup

1. Install dependencies:

```bash
cd functions
npm install
```

2. Local emulation:

```bash
# start firestore + functions emulators
npx -y firebase-tools@latest emulators:start --only functions,firestore

# you can call the HTTP resync manually:
npx -y firebase-tools@latest emulators:exec "curl http://localhost:5001/<PROJECT_ID>/us-central1/resyncAllPatients"
```

3. Deploy:

```bash
cd functions
npx -y firebase-tools@latest deploy --only functions --project <PROJECT_ID>
```

Notes
- The functions use the Admin SDK and must be deployed with a service account that has write access to Firestore.
- The `resyncAllPatients` HTTPS function is a manual utility to (re)materialize summaries for existing users; use with care on large datasets.
