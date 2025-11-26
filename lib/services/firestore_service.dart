import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String,dynamic>> diaryCol() => _fire.collection('diary').doc(uid).collection('entries');
  CollectionReference<Map<String,dynamic>> commitmentsCol() => _fire.collection('commitments').doc(uid).collection('items');
  CollectionReference<Map<String,dynamic>> goalsCol() => _fire.collection('goals').doc(uid).collection('items');

  Future<void> addDiary(Map<String,dynamic> data) async {
    await diaryCol().add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> deleteDiary(String id) async => await diaryCol().doc(id).delete();

  // other functions similar for commitments/goals...
}
