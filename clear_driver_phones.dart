import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  final snapshot = await firestore.collection('drivers').get();

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final List entries = data['entries'] ?? [];

    // Yeni entries listi: phone sahəsi silinir
    final cleanedEntries = entries.map((entry) {
      final cleanedEntry = Map<String, dynamic>.from(entry);
      cleanedEntry.remove('phone'); // 💥 phone sahəsini silirik
      return cleanedEntry;
    }).toList();

    await firestore.collection('drivers').doc(doc.id).update({
      'entries': cleanedEntries,
    });

    print('✔️ phone silindi: ${doc.id}');
  }

  print('✅ Bütün drivers içindəki entries.phone sahələri silindi.');
}
