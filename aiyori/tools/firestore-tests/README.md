Firestore rules unit tests

Setup & run


1. Install Node 16+ and npm.
2. From the project folder run:

```bash
cd tools/firestore-tests
npm install
```

Running the tests

- Option A — Start the Firestore emulator yourself (recommended):

```bash
# in a separate terminal, start the emulator
npx -y firebase-tools@latest emulators:start --only firestore

# then run tests in this terminal
npm test
```

- Option B — Let the test script start the emulator for you (may require a firebase.json):

```bash
npm run test:emulator
```

Notes
- If you don't have a `firebase.json` with an `emulators` section, `emulators:exec` may complain. In that case use Option A to start the emulator manually.
- The test harness reads `../../firestore.rules` (project root). Adjust the path in the test file if you move files.
- These tests use `@firebase/rules-unit-testing` which evaluates rules against a local Firestore emulator.
