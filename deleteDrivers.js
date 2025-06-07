const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function deleteAllDrivers() {
  const driversRef = db.collection("drivers");
  const snapshot = await driversRef.get();

  const batch = db.batch();

  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();
  console.log("✅ Bütün sürücülər silindi.");
}

deleteAllDrivers().catch(console.error);
