const fs = require('fs');
const path = require('path');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');

describe('Firestore security rules', function() {
  this.timeout(20000);
  let testEnv;

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: 'aiyori-firestore-test',
      firestore: {
        rules: fs.readFileSync(path.join(__dirname, '..', '..', '..', 'firestore.rules'), 'utf8')
      }
    });
  });

  after(async () => {
    await testEnv.cleanup();
  });

  it('patient can read own user doc', async () => {
    const admin = testEnv.admin;
    await admin.firestore().collection('users').doc('patient_abc123').set({
      uid: 'patient_abc123',
      name: 'María González'
    });

    const patientCtx = testEnv.authenticatedContext('patient_abc123');
    const db = patientCtx.firestore();
    await assertSucceeds(db.collection('users').doc('patient_abc123').get());
  });

  it('therapist can read assigned patient user doc', async () => {
    const admin = testEnv.admin;
    await admin.firestore().collection('users').doc('patient_def456').set({
      uid: 'patient_def456',
      name: 'Carlos Ruiz',
      assignedTherapistId: 'therapist_thera1'
    });

    const therapistCtx = testEnv.authenticatedContext('therapist_thera1');
    const tdb = therapistCtx.firestore();
    await assertSucceeds(tdb.collection('users').doc('patient_def456').get());
  });

  it('other therapist cannot read unassigned patient', async () => {
    const admin = testEnv.admin;
    await admin.firestore().collection('users').doc('patient_xyz999').set({
      uid: 'patient_xyz999',
      name: 'Ana Martínez',
      assignedTherapistId: 'therapist_others'
    });

    const otherTherapist = testEnv.authenticatedContext('therapist_unrelated');
    const odb = otherTherapist.firestore();
    await assertFails(odb.collection('users').doc('patient_xyz999').get());
  });

  it('therapist can read materialized patients collection', async () => {
    const admin = testEnv.admin;
    await admin.firestore().collection('therapists').doc('therapistA').collection('patients').doc('patient1').set({
      patientId: 'patient1',
      name: 'John Doe'
    });

    const therapistCtx = testEnv.authenticatedContext('therapistA');
    const tdb = therapistCtx.firestore();
    await assertSucceeds(tdb.collection('therapists').doc('therapistA').collection('patients').doc('patient1').get());
  });

  it('patient cannot set assignedTherapistId on create', async () => {
    const patientCtx = testEnv.authenticatedContext('patient_newuser');
    const pdb = patientCtx.firestore();
    await assertFails(pdb.collection('users').doc('patient_newuser').set({
      uid: 'patient_newuser',
      name: 'Evil',
      assignedTherapistId: 'therapist_bad'
    }));
  });

  it('patient cannot update assignedTherapistId', async () => {
    const admin = testEnv.admin;
    await admin.firestore().collection('users').doc('patient_update_test').set({ uid: 'patient_update_test', name: 'T' });

    const patientCtx = testEnv.authenticatedContext('patient_update_test');
    const pdb = patientCtx.firestore();
    await assertFails(pdb.collection('users').doc('patient_update_test').update({ assignedTherapistId: 'therapist_x' }));
  });
});
