const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const fs = require('fs');

function usage() {
  console.log(`Usage:
  node scripts/migrate_pins_local.js <serviceAccountKey.json>

Example:
  node scripts/migrate_pins_local.js ./serviceAccount.json
`);
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length !== 1) {
    usage();
    process.exit(1);
  }

  const svcPath = args[0];
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

    console.log('Migration complete. Documents migrated:', migrated);
    process.exit(0);
  } catch (err) {
    console.error('Migration error:', err);
    process.exit(1);
  }
}

main();
