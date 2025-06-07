import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> logActivity(String text) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance.collection('activities').add({
    'userId': user.uid,
    'text': text,
    'timestamp': Timestamp.now(),
  });
}
