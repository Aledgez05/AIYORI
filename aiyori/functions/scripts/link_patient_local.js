const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const fs = require('fs');

function usage() {
  console.log(`Usage:
  node scripts/link_patient_local.js <serviceAccountKey.json> <therapistId> <patientId|patientEmail> <pin>

Examples:
  node scripts/link_patient_local.js ./serviceAccount.json therapistUid patientUid 1234
  node scripts/link_patient_local.js ./serviceAccount.json therapistUid patient@example.com 1234
`);
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length !== 4) {
    usage();
    process.exit(1);
  }

  const [svcPath, therapistId, patientIdent, pin] = args;

  if (!fs.existsSync(svcPath)) {
    console.error('Service account file not found:', svcPath);
    process.exit(1);
  }

  const serviceAccount = require(require('path').resolve(svcPath));

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  const db = admin.firestore();

  try {
    let patientRef;
    if (patientIdent.includes('@')) {
      const q = await db.collection('users').where('email', '==', patientIdent).limit(1).get();
      if (q.empty) {
        console.error('Patient by email not found:', patientIdent);
        process.exit(1);
      }
      patientRef = q.docs[0].ref;
    } else {
      patientRef = db.collection('users').doc(patientIdent);
    }

    const snap = await patientRef.get();
    if (!snap.exists) {
      console.error('Patient document not found:', patientRef.path);
      process.exit(1);
    }

    const data = snap.data();

    // Validate PIN (support pinHash or legacy pin)
    if (data.pinHash) {
      const ok = await bcrypt.compare(pin, data.pinHash);
      if (!ok) {
        console.error('Invalid PIN (pinHash mismatch)');
        process.exit(1);
      }
    } else if (data.pin) {
      if (data.pin !== pin) {
        console.error('Invalid PIN (plaintext mismatch)');
        process.exit(1);
      }
    } else {
      console.error('Patient has no PIN set');
      process.exit(1);
    }

    // Perform link: add therapist to therapistIds and set assignedTherapistId
    await patientRef.update({
      therapistIds: admin.firestore.FieldValue.arrayUnion(therapistId),
      assignedTherapistId: therapistId,
    });

    console.log('Patient linked successfully:', patientRef.path);
    process.exit(0);
  } catch (err) {
    console.error('Error linking patient:', err);
    process.exit(1);
  }
}

main();
