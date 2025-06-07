const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

// Firebase Admin SDK JSON faylını düzgün yolda göstər
const serviceAccount = require("./firebase-adminsdk.json");

// Firebase-i initialize et
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  ignoreUndefinedProperties: true
});

// Firestore referansı
const db = admin.firestore();

// JSON faylını oxu
const driversFile = fs.readFileSync(path.join(__dirname, "drivers.json"), "utf8");
const driversData = JSON.parse(driversFile);

// Firestore-a sürücüləri əlavə et
async function uploadDrivers() {
  for (const driver of driversData) {
    const {
      name,
      surname,
      fatherName,
      fin,
      sv,
      photoUrl = "",
      entries = [],
      ownerUid = "" // 🔹 Bunu əlavə et
    } = driver;

    try {
      // Yeni document əlavə et
      const docRef = await db.collection("drivers").add({
        name,
        surname,
        fatherName,
        fin,
        sv,
        photoUrl,
        ownerUid, // 🔹 Bunu mütləq əlavə et!
        entries: entries.map(entry => ({
          owner: entry.owner || "",
          ownerPhone: entry.ownerPhone || "",
          note: entry.note || "",
          park: entry.park || "",
          phone: entry.phone || "",
          status: entry.status || "",
          reason: entry.reason || "",
          date: entry.date || new Date().toISOString(),
          ownerUid: ownerUid // 🔹 Burada da eyni UID təkrar yazılmalıdır
        }))
      });

      console.log(`✅ Əlavə olundu: ${name} ${surname} → ID: ${docRef.id}`);
    } catch (error) {
      console.error(`❌ Xəta baş verdi (${name} ${surname}):`, error);
    }
  }

  console.log("✔️ Bütün sürücülər əlavə olundu.");
}

uploadDrivers();
