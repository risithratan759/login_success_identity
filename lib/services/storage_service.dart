import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(File f, String uid) async {
    final ref = _storage.ref().child('profiles').child('$uid.jpg');
    final task = await ref.putFile(f);
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadDiaryImage(File f, String uid) async {
    final ref = _storage.ref().child('diary').child(uid).child('img_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(f);
    return await task.ref.getDownloadURL();
  }
}
