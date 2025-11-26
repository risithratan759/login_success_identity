import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  final nameCtl = TextEditingController();
  final locCtl = TextEditingController();
  File? newPhoto;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    userData = doc.data();

    nameCtl.text = userData?['name'] ?? "";
    locCtl.text = userData?['location'] ?? "";

    setState(() {});
  }

  Future<void> pickPhoto() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => newPhoto = File(file.path));
    }
  }

  Future<void> saveProfile() async {
    String? photoUrl = userData?['photo'];

    if (newPhoto != null) {
      photoUrl = await StorageService().uploadProfileImage(newPhoto!, uid);
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': nameCtl.text.trim(),
      'location': locCtl.text.trim(),
      'photo': photoUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")));

    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Center(
            child: GestureDetector(
              onTap: pickPhoto,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: newPhoto != null
                    ? FileImage(newPhoto!)
                    : (userData!['photo'] != null
                        ? NetworkImage(userData!['photo'])
                        : const AssetImage('assets/images/default.png'))
                            as ImageProvider,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameCtl,
            decoration: const InputDecoration(labelText: "Full Name"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: locCtl,
            decoration: const InputDecoration(labelText: "Location"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: saveProfile, child: const Text("Save"))
        ]),
      ),
    );
  }
}
