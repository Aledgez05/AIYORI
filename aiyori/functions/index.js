const functions = require('firebase-functions');
const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');

admin.initializeApp();
const db = admin.firestore();

/**
 * Sync user profile -> materialized therapist patient summaries.
 * Triggers on create/update/delete of users/{uid}.
 */
exports.syncPatientToTherapistsOnUserWrite = functions.firestore
  .document('users/{uid}')
  .onWrite(async (change, context) => {
    const uid = context.params.uid;
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;

    try {
      const batch = db.batch();

      // User deleted: remove materialized summaries
      if (!after) {
        if (before?.assignedTherapistId) {
          const ref = db.collection('therapists').doc(before.assignedTherapistId).collection('patients').doc(uid);
          batch.delete(ref);
        }
        if (Array.isArray(before?.therapistIds)) {
          before.therapistIds.forEach(tid => {
            const ref = db.collection('therapists').doc(tid).collection('patients').doc(uid);
            batch.delete(ref);
          });
        }
        await batch.commit();
        return null;
      }

      // Build summary doc
      const summaryDoc = {
        patientId: uid,
        name: after.name || '',
        age: after.profile?.age ?? null,
        avatar: after.profile?.avatar || '',
        riskLevel: after.profile?.riskLevel || null,
        summary: after.summary || {},
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      };

      if (!change.before.exists) summaryDoc.createdAt = admin.firestore.FieldValue.serverTimestamp();

      const beforeTids = new Set();
      if (before?.assignedTherapistId) beforeTids.add(before.assignedTherapistId);
      if (Array.isArray(before?.therapistIds)) before.therapistIds.forEach(t => beforeTids.add(t));

      const afterTids = new Set();
      if (after?.assignedTherapistId) afterTids.add(after.assignedTherapistId);
      if (Array.isArray(after?.therapistIds)) after.therapistIds.forEach(t => afterTids.add(t));

      // Remove from therapists no longer assigned
      for (const tid of beforeTids) {
        if (!afterTids.has(tid)) {
          const ref = db.collection('therapists').doc(tid).collection('patients').doc(uid);
          batch.delete(ref);
        }
      }

      // Add/update for current assigned therapists
      for (const tid of afterTids) {
        const ref = db.collection('therapists').doc(tid).collection('patients').doc(uid);
        batch.set(ref, summaryDoc, { merge: true });
      }

      await batch.commit();
      return null;
    } catch (err) {
      console.error('syncPatientToTherapistsOnUserWrite error', err);
      return null;
    }
  });


/**
 * Update therapist summaries when daily_records change.
 * - On create: increment sessionsCount and update lastCheckIn
 * - On update: update lastCheckIn
 * - On delete: update updatedAt only (no decrement to avoid inconsistency)
 */
exports.onDailyRecordWrite = functions.firestore
  .document('users/{uid}/daily_records/{rid}')
  .onWrite(async (change, context) => {
    const uid = context.params.uid;
    const isCreate = !change.before.exists && change.after.exists;
    const isDelete = change.before.exists && !change.after.exists;

    try {
      const userSnap = await db.collection('users').doc(uid).get();
      if (!userSnap.exists) return null;
      const user = userSnap.data();

      const tids = new Set();
      if (user.assignedTherapistId) tids.add(user.assignedTherapistId);
      if (Array.isArray(user.therapistIds)) user.therapistIds.forEach(t => tids.add(t));
      if (tids.size === 0) return null;

      const batch = db.batch();
      for (const tid of tids) {
        const ref = db.collection('therapists').doc(tid).collection('patients').doc(uid);
        if (isDelete) {
          batch.set(ref, { updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
        } else if (isCreate) {
          batch.set(ref, {
            lastCheckIn: admin.firestore.FieldValue.serverTimestamp(),
            'summary.sessionsCount': admin.firestore.FieldValue.increment(1),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          }, { merge: true });
        } else {
          batch.set(ref, { lastCheckIn: admin.firestore.FieldValue.serverTimestamp(), updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
        }
      }

      await batch.commit();
      return null;
    } catch (err) {
      console.error('onDailyRecordWrite error', err);
      return null;
    }
  });


/**
 * HTTPS-triggered manual resync for all users.
 * Use sparingly (may need pagination for large datasets).
 */
exports.resyncAllPatients = functions.https.onRequest(async (req, res) => {
  try {
    const usersSnap = await db.collection('users').get();
    let batch = db.batch();
    let writes = 0;

    for (const doc of usersSnap.docs) {
      const data = doc.data();
      const uid = doc.id;
      const tids = new Set();
      if (data.assignedTherapistId) tids.add(data.assignedTherapistId);
      if (Array.isArray(data.therapistIds)) data.therapistIds.forEach(t => tids.add(t));
      if (tids.size === 0) continue;

      const summaryDoc = {
        patientId: uid,
        name: data.name || '',
        age: data.profile?.age ?? null,
        avatar: data.profile?.avatar || '',
        riskLevel: data.profile?.riskLevel || null,
        summary: data.summary || {},
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      };

      for (const tid of tids) {
        const ref = db.collection('therapists').doc(tid).collection('patients').doc(uid);
        batch.set(ref, summaryDoc, { merge: true });
        writes++;
      }

      // commit in chunks to avoid large batches
      if (writes >= 400) {
        await batch.commit();
        batch = db.batch();
        writes = 0;
      }
    }

    if (writes > 0) await batch.commit();
    res.status(200).send({ ok: true });
  } catch (err) {
    console.error('resyncAllPatients error', err);
    res.status(500).send({ error: err.message });
  }
});


/**
 * HTTPS endpoint to link a patient to the authenticated therapist using a PIN.
 * Request: POST JSON { patientId?: string, email?: string, pin: string }
 * Must include Authorization: Bearer <ID_TOKEN>
 */
exports.linkPatient = functions.https.onRequest(async (req, res) => {
  // Basic CORS handling for browser clients (preflight + response headers)
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    return res.status(204).send('');
  }

  if (req.method !== 'POST') return res.status(405).send({ error: 'Method not allowed' });

  const authHeader = (req.headers.authorization || req.headers.Authorization || '');
  if (!authHeader.toString().startsWith('Bearer ')) return res.status(401).send({ error: 'Missing Authorization header' });
  const idToken = authHeader.toString().split('Bearer ')[1];

  let decoded;
  try {
    decoded = await admin.auth().verifyIdToken(idToken);
  } catch (err) {
    console.error('verifyIdToken error', err);
    return res.status(401).send({ error: 'Invalid token' });
  }

  const therapistId = decoded.uid;

  try {
    const therapistSnap = await db.collection('users').doc(therapistId).get();
    if (!therapistSnap.exists) return res.status(403).send({ error: 'Therapist not found' });
    const therapist = therapistSnap.data();
    if (!therapist || !(therapist.role === 'therapist' || therapist.isAdmin === true)) {
      return res.status(403).send({ error: 'Not authorized' });
    }

    const body = req.body || {};
    const { patientId, email, pin } = body;
    if (!pin || (!patientId && !email)) return res.status(400).send({ error: 'Missing parameters' });

    let patientRef;
    if (patientId) {
      patientRef = db.collection('users').doc(patientId);
    } else {
      const q = await db.collection('users').where('email', '==', email).limit(1).get();
      if (q.empty) return res.status(404).send({ error: 'Patient not found' });
      patientRef = q.docs[0].ref;
    }

    const patientSnap = await patientRef.get();
    if (!patientSnap.exists) return res.status(404).send({ error: 'Patient not found' });
    const patient = patientSnap.data();

    // Validate PIN — prefer hashed 'pinHash' and fallback to legacy plain 'pin'.
    if (patient.pinHash) {
      const ok = await bcrypt.compare(pin, patient.pinHash);
      if (!ok) return res.status(401).send({ error: 'Invalid PIN' });
    } else if (patient.pin) {
      if (patient.pin !== pin) return res.status(401).send({ error: 'Invalid PIN' });
    } else {
      return res.status(400).send({ error: 'Patient has no link PIN set' });
    }

    // Link: add therapist to therapistIds and set assignedTherapistId
    const updates = {
      therapistIds: admin.firestore.FieldValue.arrayUnion(therapistId),
      assignedTherapistId: therapistId,
    };

    await patientRef.update(updates);

    return res.status(200).send({ ok: true });
  } catch (err) {
    console.error('linkPatient error', err);
    return res.status(500).send({ error: err.message || 'server error' });
  }
});


/**
 * Callable version of linkPatient for SDK clients.
 * Accepts data: { patientId?: string, email?: string, pin: string }
 * Authenticated via context.auth (Firebase Functions SDK)
 */
exports.linkPatientCallable = functions.https.onCall(async (data, context) => {
  try {
    const therapistId = context.auth && context.auth.uid;
    if (!therapistId) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');

    const therapistSnap = await db.collection('users').doc(therapistId).get();
    if (!therapistSnap.exists) throw new functions.https.HttpsError('not-found', 'Therapist not found');
    const therapist = therapistSnap.data();
    if (!therapist || !(therapist.role === 'therapist' || therapist.isAdmin === true)) {
      throw new functions.https.HttpsError('permission-denied', 'Not authorized');
    }

    const patientId = data?.patientId;
    const email = data?.email;
    const pin = data?.pin;
    if (!pin || (!patientId && !email)) throw new functions.https.HttpsError('invalid-argument', 'Missing parameters');

    let patientRef;
    if (patientId) {
      patientRef = db.collection('users').doc(patientId);
    } else {
      const q = await db.collection('users').where('email', '==', email).limit(1).get();
      if (q.empty) throw new functions.https.HttpsError('not-found', 'Patient not found');
      patientRef = q.docs[0].ref;
    }

    const patientSnap = await patientRef.get();
    if (!patientSnap.exists) throw new functions.https.HttpsError('not-found', 'Patient not found');
    const patient = patientSnap.data();

    // Validate PIN — prefer hashed 'pinHash' and fallback to legacy plaintext 'pin'.
    if (patient.pinHash) {
      const ok = await bcrypt.compare(pin, patient.pinHash);
      if (!ok) throw new functions.https.HttpsError('unauthenticated', 'Invalid PIN');
    } else if (patient.pin) {
      if (patient.pin !== pin) throw new functions.https.HttpsError('unauthenticated', 'Invalid PIN');
    } else {
      throw new functions.https.HttpsError('failed-precondition', 'Patient has no link PIN set');
    }

    const updates = {
      therapistIds: admin.firestore.FieldValue.arrayUnion(therapistId),
      assignedTherapistId: therapistId,
    };

    await patientRef.update(updates);

    return { ok: true };
  } catch (err) {
    console.error('linkPatientCallable error', err);
    if (err instanceof functions.https.HttpsError) throw err;
    throw new functions.https.HttpsError('internal', err.message || 'server error');
  }
});


/**
 * Admin-only migration: convert plaintext `pin` -> `pinHash` (bcrypt) and remove plaintext.
 * POST only. Requires Authorization: Bearer <ID_TOKEN> of an admin user.
 */
exports.migratePinsToHash = functions.https.onRequest(async (req, res) => {
  // CORS headers for browser invocations
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(204).send('');
  if (req.method !== 'POST') return res.status(405).send({ error: 'Method not allowed' });

  const authHeader = (req.headers.authorization || req.headers.Authorization || '');
  if (!authHeader.toString().startsWith('Bearer ')) return res.status(401).send({ error: 'Missing Authorization header' });
  const idToken = authHeader.toString().split('Bearer ')[1];

  let decoded;
  try {
    decoded = await admin.auth().verifyIdToken(idToken);
  } catch (err) {
    console.error('verifyIdToken error', err);
    return res.status(401).send({ error: 'Invalid token' });
  }

  const requesterId = decoded.uid;
  try {
    const requesterSnap = await db.collection('users').doc(requesterId).get();
    if (!requesterSnap.exists) return res.status(403).send({ error: 'Requester not found' });
    const requester = requesterSnap.data();
    if (!requester || requester.isAdmin !== true) return res.status(403).send({ error: 'Not authorized' });

    const usersSnap = await db.collection('users').get();
    let batch = db.batch();
    let writes = 0;
    let migrated = 0;

    for (const doc of usersSnap.docs) {
      const data = doc.data();
      if (data && data.pin) {
        const hash = await bcrypt.hash(data.pin, 10);
        const ref = db.collection('users').doc(doc.id);
        batch.update(ref, { pinHash: hash, pin: admin.firestore.FieldValue.delete() });
        migrated++;
        writes++;
      }

      if (writes >= 400) {
        await batch.commit();
        batch = db.batch();
        writes = 0;
      }
    }

    if (writes > 0) await batch.commit();
    return res.status(200).send({ ok: true, migrated });
  } catch (err) {
    console.error('migratePinsToHash error', err);
    return res.status(500).send({ error: err.message || 'server error' });
  }
});
