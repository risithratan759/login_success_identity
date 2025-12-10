/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'profile_preview_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final picker = ImagePicker();
  File? _imageFile;

  final nameCtl = TextEditingController();
  final phoneCtl = TextEditingController();
  final emailCtl = TextEditingController();
  final passwordCtl = TextEditingController(); // Needed for re-auth

  bool loading = true;

  final user = FirebaseAuth.instance.currentUser;

  String? firestorePhoto;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = user!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      nameCtl.text = doc['name'] ?? "";
      phoneCtl.text = doc['phone'] ?? "";
      emailCtl.text = doc['email'] ?? user!.email!;
      firestorePhoto = doc["photo"];
    }

    setState(() => loading = false);
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> saveProfile() async {
    final uid = user!.uid;

    try {
      // ---------------- IMAGE UPLOAD ----------------
      String? imageUrl;
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref("profile_photos/$uid.jpg");
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      // ---------------- UPDATE EMAIL (New Firebase API) ----------------
      if (emailCtl.text.trim() != user!.email) {
        if (passwordCtl.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Enter password to change email address")),
          );
          return;
        }

        // Re-authenticate
        final credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: passwordCtl.text.trim(),
        );

        await user!.reauthenticateWithCredential(credential);

        // Send verification to new email
        await user!.verifyBeforeUpdateEmail(emailCtl.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Verification email sent. Please verify the new email."),
          ),
        );
      }

      // ---------------- UPDATE FIRESTORE ----------------
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "name": nameCtl.text.trim(),
        "phone": phoneCtl.text.trim(),
        "email": emailCtl.text.trim(),
        if (imageUrl != null) "photo": imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  ImageProvider getProfileImage() {
    if (_imageFile != null) return FileImage(_imageFile!);

    if (firestorePhoto != null && firestorePhoto!.isNotEmpty) {
      return NetworkImage(firestorePhoto!);
    }

    return const AssetImage("assets/default.png");
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---------------- Profile Photo ----------------
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: getProfileImage(),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------- Name ----------------
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),

            // ---------------- Phone ----------------
            TextField(
              controller: phoneCtl,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            // ---------------- Email ----------------
            TextField(
              controller: emailCtl,
              decoration: const InputDecoration(labelText: "Email ID"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            // ---------------- Password (for email update) ----------------
            TextField(
              controller: passwordCtl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Enter Password to Change Email",
              ),
            ),
            const SizedBox(height: 20),

            // ---------------- Save Button ----------------
            ElevatedButton(
              onPressed: saveProfile,
              child: const Text("Save"),
            ),

            const SizedBox(height: 20),

            // ---------------- Preview Button ----------------
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePreviewPage()),
                );
              },
              child: const Text("Preview Profile"),
            )
          ],
        ),
      ),
    );
  }
}
*/
/*import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_card/screens/auth/auth_service.dart';
import 'profile_preview_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _picker = ImagePicker();
  File? _localImageFile;

  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  // ⭐ UPDATED FIELDS ⭐
  final _designationCtl = TextEditingController();
  final _lifeMotoCtl = TextEditingController();

  final _authService = AuthService();
  bool _saving = false;

  DocumentReference<Map<String, dynamic>> userDocRef(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (picked != null) setState(() => _localImageFile = File(picked.path));
  }

  Future<String?> _uploadProfileImage(String uid, File file) async {
    final ref = FirebaseStorage.instance.ref('profile_photos/$uid.jpg');
    final uploadTask = ref.putFile(file);

    final completer = Completer<String?>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StreamBuilder<TaskSnapshot>(
          stream: uploadTask.snapshotEvents,
          builder: (context, snapshot) {
            final progress = snapshot.hasData && snapshot.data!.totalBytes > 0
                ? snapshot.data!.bytesTransferred / snapshot.data!.totalBytes
                : 0.0;
            return AlertDialog(
              title: const Text('Uploading'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 12),
                  Text('${(progress * 100).toStringAsFixed(0)}% completed'),
                ],
              ),
            );
          },
        );
      },
    );

    uploadTask.whenComplete(() async {
      Navigator.of(context).pop();
      final url = await ref.getDownloadURL();
      completer.complete(url);
    });

    return completer.future;
  }

  Future<void> _saveProfile(Map<String, dynamic> currentData) async {
    final user = _authService.currentUser;
    if (user == null) return;

    final uid = user.uid;
    setState(() => _saving = true);

    try {
      String? uploadedUrl;
      if (_localImageFile != null) {
        uploadedUrl = await _uploadProfileImage(uid, _localImageFile!);
      }

      // ---------------------------
      // ⭐ Firestore SAVE ⭐
      // ---------------------------
      final updateData = <String, dynamic>{
        'name': _nameCtl.text.trim(),
        'phone': _phoneCtl.text.trim(),
        'email': _emailCtl.text.trim(),
        'designation': _designationCtl.text.trim(),
        'life_motto': _lifeMotoCtl.text.trim(),   // ⭐ FIXED FIELD NAME ⭐
      };

      if (uploadedUrl != null) updateData['photo'] = uploadedUrl;

      await userDocRef(uid).update(updateData);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile Saved')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future:
            userDocRef(user.uid).get(const GetOptions(source: Source.serverAndCache)),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() ?? {};

          // Preload fields
          if (_nameCtl.text.isEmpty) _nameCtl.text = data['name'] ?? "";
          if (_phoneCtl.text.isEmpty) _phoneCtl.text = data['phone'] ?? "";
          if (_emailCtl.text.isEmpty) _emailCtl.text = data['email'] ?? user.email ?? "";
          if (_designationCtl.text.isEmpty) _designationCtl.text = data['designation'] ?? "";
          if (_lifeMotoCtl.text.isEmpty) _lifeMotoCtl.text = data['life_motto'] ?? "";  // ⭐ FIXED ⭐

          final photoUrl = data['photo'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _localImageFile != null
                        ? FileImage(_localImageFile!)
                        : photoUrl.isNotEmpty
                            ? CachedNetworkImageProvider(photoUrl)
                            : const AssetImage('assets/default.png'),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _nameCtl,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _designationCtl,
                  decoration: const InputDecoration(labelText: "Designation"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _lifeMotoCtl,
                  decoration: const InputDecoration(labelText: "Life's Motto"),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _phoneCtl,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _emailCtl,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 20),

                _saving
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: () => _saveProfile(data),
                        icon: const Icon(Icons.save),
                        label: const Text("Save Profile"),
                      ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfilePreviewPage()),
                    );
                  },
                  child: const Text("Preview Profile"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    _designationCtl.dispose();
    _lifeMotoCtl.dispose();
    super.dispose();
  }
}
*/
// lib/screens/home/edit_profile_page.dart
/*import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_card/screens/profile_preview_page.dart';
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // controllers
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _designationCtl = TextEditingController();
  final _lifeMotoCtl = TextEditingController();
  final _emailCtl = TextEditingController();

  // validation errors
  String? _nameError;
  String? _phoneError;
  String? _lifeMotoError;

  // local image
  File? _localImage;

  // state
  bool _loading = true;
  bool _saving = false;
  Timer? _debounceTimer;

  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  String get _uid => _auth.currentUser!.uid;
  DocumentReference<Map<String, dynamic>> get _docRef =>
      _fire.collection('users').doc(_uid);

  @override
  void initState() {
    super.initState();
    _loadInitial();
    // listen to text changes -> auto-save debounce
    _nameCtl.addListener(_onFieldChanged);
    _phoneCtl.addListener(_onFieldChanged);
    _designationCtl.addListener(_onFieldChanged);
    _lifeMotoCtl.addListener(_onFieldChanged);
  }

  Future<void> _loadInitial() async {
    try {
      final snap = await _docRef.get(const GetOptions(source: Source.serverAndCache));
      final data = snap.data() ?? {};
      _nameCtl.text = data['name'] ?? '';
      _phoneCtl.text = data['phone'] ?? '';
      _designationCtl.text = data['designation'] ?? '';
      _lifeMotoCtl.text = data['life_motto'] ?? '';
      _emailCtl.text = _auth.currentUser?.email ?? data['email'] ?? '';
    } catch (e) {
      // ignore – show blank
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onFieldChanged() {
    // clear previous validation while typing
    setState(() {
      _nameError = null;
      _phoneError = null;
      _lifeMotoError = null;
    });

    // debounce auto-save: 1 second after last edit
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    // validate lightweight before saving (don't upload image here)
    final valid = _validateForSave(autoSave: true);
    if (!valid) return;

    try {
      await _docRef.set({
        'name': _nameCtl.text.trim(),
        'phone': _phoneCtl.text.trim(),
        'designation': _designationCtl.text.trim(),
        'life_motto': _lifeMotoCtl.text.trim(),
        'email': _emailCtl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        // optional: small visual feedback
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Autosaved')));
      }
    } catch (e) {
      // handle or ignore silently for autosave
      debugPrint('autosave failed: $e');
    }
  }

  bool _validateForSave({bool autoSave = false}) {
    final name = _nameCtl.text.trim();
    final phone = _phoneCtl.text.trim();
    final lifeMoto = _lifeMotoCtl.text.trim();

    bool ok = true;

    if (name.isEmpty) {
      _nameError = 'Name is required';
      ok = false;
    } else {
      _nameError = null;
    }

    if (phone.isNotEmpty && phone.replaceAll(RegExp(r'\D'), '').length < 10) {
      _phoneError = 'Enter a valid phone number';
      ok = false;
    } else {
      _phoneError = null;
    }

    if (lifeMoto.length > 120) {
      _lifeMotoError = 'Max 120 characters';
      ok = false;
    } else {
      _lifeMotoError = null;
    }

    if (!autoSave) setState(() {}); // update errors immediately for manual saves

    return ok;
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
      if (picked == null) return;
      setState(() => _localImage = File(picked.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
    }
  }

  Future<void> _uploadImageAndSaveAll() async {
    // manual "Save" uploads image (if any) then saves document
    if (!_validateForSave()) return;

    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (_localImage != null) {
        final ref = FirebaseStorage.instance.ref('profile_photos/$_uid.jpg');
        final task = await ref.putFile(_localImage!);
        photoUrl = await task.ref.getDownloadURL();
      }

      await _docRef.set({
        'name': _nameCtl.text.trim(),
        'phone': _phoneCtl.text.trim(),
        'designation': _designationCtl.text.trim(),
        'life_motto': _lifeMotoCtl.text.trim(),
        'email': _emailCtl.text.trim(),
        if (photoUrl != null) 'photo': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0,4))],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _designationCtl.dispose();
    _lifeMotoCtl.dispose();
    _emailCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            tooltip: 'Open live preview',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePreviewPage())),
          )
        ],
      ),
      body: Stack(
        children: [
          // background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.teal.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Column(
              children: [
                // header card with avatar
                _buildGlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _localImage != null
                              ? FileImage(_localImage!)
                              : null,
                          child: _localImage == null
                              ? FutureBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                                  future: _docRef.get(const GetOptions(source: Source.serverAndCache)),
                                  builder: (context, snap) {
                                    final data = snap.data?.data();
                                    final url = data?['photo'] as String?;
                                    if (url != null && url.isNotEmpty) {
                                      return ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: url,
                                          width: 92, height: 92, fit: BoxFit.cover,
                                          placeholder: (_, __) => const Icon(Icons.person, size: 48, color: Colors.white70),
                                          errorWidget: (_, __, ___) => const Icon(Icons.person, size: 48, color: Colors.white70),
                                        ),
                                      );
                                    }
                                    return const Icon(Icons.person, size: 48, color: Colors.white70);
                                  },
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_nameCtl.text.isNotEmpty ? _nameCtl.text : 'Your name',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(_designationCtl.text.isNotEmpty ? _designationCtl.text : 'Designation',
                                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(Icons.phone, size: 14, color: Colors.white70),
                              const SizedBox(width: 6),
                              Text(_phoneCtl.text.isNotEmpty ? _phoneCtl.text : 'Phone',
                                  style: TextStyle(color: Colors.white70)),
                            ])
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // form card
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Personal information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 12),

                      // Name
                      TextField(
                        controller: _nameCtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Full name',
                          errorText: _nameError,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.02),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Designation
                      TextField(
                        controller: _designationCtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Designation',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.02),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Life motto (multi-line)
                      TextField(
                        controller: _lifeMotoCtl,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Life's motto",
                          helperText: '${_lifeMotoCtl.text.length}/120',
                          errorText: _lifeMotoError,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.02),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (_) { setState(() {}); },
                      ),
                      const SizedBox(height: 12),

                      // Phone
                      TextField(
                        controller: _phoneCtl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Phone number',
                          errorText: _phoneError,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.02),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Email (read-only - changing email requires reauth)
                      TextField(
                        controller: _emailCtl,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white70),
                        decoration: InputDecoration(
                          labelText: 'Email (change via account settings)',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.02),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white70),
                            onPressed: () {
                              // open a dialog or flow for email change (not implemented here)
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email change requires re-authentication. Use "Change Email" flow.'))); 
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: _saving ? const SizedBox(width:16, height:16, child:CircularProgressIndicator(color: Colors.white, strokeWidth:2)) : const Icon(Icons.save),
                        label: Text(_saving ? 'Saving...' : 'Save & Upload Photo'),
                        onPressed: _saving ? null : () => _uploadImageAndSaveAll(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.deepPurpleAccent,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // preview quick open
                    OutlinedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePreviewPage())),
                      child: const Text('Live Preview'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        side: BorderSide(color: Colors.white.withOpacity(0.12)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // live preview panel (small)
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live (local) preview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundImage: _localImage != null ? FileImage(_localImage!) : null,
                          child: _localImage == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(_nameCtl.text.isNotEmpty ? _nameCtl.text : 'Your name', style: const TextStyle(color: Colors.white)),
                        subtitle: Text(_designationCtl.text.isNotEmpty ? _designationCtl.text : 'Designation', style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(height: 8),
                      Text(_lifeMotoCtl.text.isNotEmpty ? _lifeMotoCtl.text : 'Life motto preview', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
// ---------------------------
// FINAL EDIT PROFILE PAGE
// Compatible with LinkedIn-style ProfilePreviewPage
// With: website + profileUrl + proper preview navigation
// ---------------------------
/*
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_card/screens/profile_preview_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // TEXT CONTROLLERS ----------------------------------------------------------
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _designationCtl = TextEditingController();
  final _lifeMotoCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _websiteCtl = TextEditingController();
  final _profileUrlCtl = TextEditingController();

  // VALIDATION
  String? _nameError;
  String? _phoneError;
  String? _lifeMotoError;

  // IMAGE
  File? _localImage;

  // STATE
  bool _loading = true;
  bool _saving = false;
  Timer? _debounceTimer;

  // FIREBASE
  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  String get _uid => _auth.currentUser!.uid;
  DocumentReference<Map<String, dynamic>> get _docRef =>
      _fire.collection('users').doc(_uid);

  // INIT ----------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadInitial();

    // AUTO-SAVE DEBOUNCE
    for (final ctl in [
      _nameCtl,
      _phoneCtl,
      _designationCtl,
      _lifeMotoCtl,
      _websiteCtl,
      _profileUrlCtl,
    ]) {
      ctl.addListener(_onFieldChanged);
    }
  }

  // LOAD EXISTING FIRESTORE DATA ---------------------------------------------
  Future<void> _loadInitial() async {
    try {
      final snap = await _docRef.get();
      final data = snap.data() ?? {};

      _nameCtl.text = data['name'] ?? '';
      _phoneCtl.text = data['phone'] ?? '';
      _designationCtl.text = data['designation'] ?? '';
      _lifeMotoCtl.text = data['life_motto'] ?? '';
      _emailCtl.text = _auth.currentUser?.email ?? data['email'] ?? '';
      _websiteCtl.text = data['website'] ?? '';
      _profileUrlCtl.text = data['profileUrl'] ?? '';
    } catch (e) {
      debugPrint("Initial load failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ON FIELD CHANGE → TRIGGER DEBOUNCE SAVE -----------------------------------
  void _onFieldChanged() {
    setState(() {
      _nameError = null;
      _phoneError = null;
      _lifeMotoError = null;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _autoSave();
    });
  }

  // AUTO SAVE ----------------------------------------------------------------
  Future<void> _autoSave() async {
    if (!_validateForSave(autoSave: true)) return;

    try {
      await _docRef.set({
        'name': _nameCtl.text.trim(),
        'phone': _phoneCtl.text.trim(),
        'designation': _designationCtl.text.trim(),
        'life_motto': _lifeMotoCtl.text.trim(),
        'email': _emailCtl.text.trim(),
        'website': _websiteCtl.text.trim(),
        'profileUrl': _profileUrlCtl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Auto-save failed: $e");
    }
  }

  // VALIDATION ---------------------------------------------------------------
  bool _validateForSave({bool autoSave = false}) {
    final name = _nameCtl.text.trim();
    final phone = _phoneCtl.text.trim();
    final moto = _lifeMotoCtl.text.trim();

    bool ok = true;

    if (name.isEmpty) {
      _nameError = 'Name is required';
      ok = false;
    } else {
      _nameError = null;
    }

    if (phone.isNotEmpty &&
        phone.replaceAll(RegExp(r'\D'), '').length < 10) {
      _phoneError = 'Invalid phone number';
      ok = false;
    } else {
      _phoneError = null;
    }

    if (moto.length > 120) {
      _lifeMotoError = 'Max 120 characters';
      ok = false;
    } else {
      _lifeMotoError = null;
    }

    if (!autoSave) setState(() {});
    return ok;
  }

  // PICK IMAGE ---------------------------------------------------------------
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _localImage = File(picked.path));
  }

  // SAVE + UPLOAD IMAGE ------------------------------------------------------
  Future<void> _uploadImageAndSaveAll() async {
    if (!_validateForSave()) return;

    setState(() => _saving = true);

    try {
      String? photoUrl;

      if (_localImage != null) {
        final ref =
            FirebaseStorage.instance.ref('profile_photos/$_uid.jpg');
        final uploadTask = await ref.putFile(_localImage!);
        photoUrl = await uploadTask.ref.getDownloadURL();
      }

      await _docRef.set({
        'name': _nameCtl.text.trim(),
        'phone': _phoneCtl.text.trim(),
        'designation': _designationCtl.text.trim(),
        'life_motto': _lifeMotoCtl.text.trim(),
        'email': _emailCtl.text.trim(),
        'website': _websiteCtl.text.trim(),
        'profileUrl': _profileUrlCtl.text.trim(),
        if (photoUrl != null) 'photo': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Profile saved")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Save failed: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // GLASS CARD ---------------------------------------------------------------
  Widget _glass({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // CLEANUP ---------------------------------------------------------------
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _designationCtl.dispose();
    _lifeMotoCtl.dispose();
    _emailCtl.dispose();
    _websiteCtl.dispose();
    _profileUrlCtl.dispose();
    super.dispose();
  }

  // UI -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePreviewPage(
                    name: _nameCtl.text.trim(),
                    title: _designationCtl.text.trim(),
                    about: _lifeMotoCtl.text.trim(),
                    //avatarUrl: "", // live Firestore fetch inside preview
                    avatarUrl: _profileUrlCtl.text.trim(),

                    email: _emailCtl.text.trim(),
                    phone: _phoneCtl.text.trim(),
                    website: _websiteCtl.text.trim(),
                    profileUrl: _profileUrlCtl.text.trim(),
                  ),
                ),
              );
            },
          )
        ],
      ),

      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.shade900,
                  Colors.teal.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // MAIN CONTENT
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              children: [
                // AVATAR HEADER -------------------------------------------------
                _glass(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: _localImage != null
                              ? FileImage(_localImage!)
                              : null,
                          child: _localImage == null
                              ? const Icon(Icons.person, size: 44)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameCtl.text.isNotEmpty
                                  ? _nameCtl.text
                                  : "Your name",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _designationCtl.text.isNotEmpty
                                  ? _designationCtl.text
                                  : "Designation",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // FORM ---------------------------------------------------------
                _glass(
                  child: Column(
                    children: [
                      // NAME
                      TextField(
                        controller: _nameCtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          errorText: _nameError,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // DESIGNATION
                      TextField(
                        controller: _designationCtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Designation",
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ABOUT / MOTO
                      TextField(
                        maxLines: 2,
                        controller: _lifeMotoCtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "About / Short bio",
                          errorText: _lifeMotoError,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),

                      // PHONE
                      TextField(
                        controller: _phoneCtl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Phone",
                          errorText: _phoneError,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // WEBSITE
                      TextField(
                        controller: _websiteCtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Website / Portfolio",
                          prefixIcon: Icon(Icons.language),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // PROFILE URL (for QR)
                      TextField(
                        controller: _profileUrlCtl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Public profile URL (for QR code)",
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // EMAIL (readonly)
                      TextField(
                        controller: _emailCtl,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white70),
                        decoration: const InputDecoration(
                          labelText: "Email (read-only)",
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // BUTTONS ---------------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: _saving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ))
                            : const Icon(Icons.save),
                        label: Text(_saving ? "Saving..." : "Save"),
                        onPressed: _saving ? null : _uploadImageAndSaveAll,
                      ),
                    ),
                    const SizedBox(width: 14),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfilePreviewPage(
                              name: _nameCtl.text.trim(),
                              title: _designationCtl.text.trim(),
                              about: _lifeMotoCtl.text.trim(),
                              avatarUrl: "",
                              email: _emailCtl.text.trim(),
                              phone: _phoneCtl.text.trim(),
                              website: _websiteCtl.text.trim(),
                              profileUrl: _profileUrlCtl.text.trim(),
                            ),
                          ),
                        );
                      },
                      child: const Text("Preview"),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

*/// lib/screens/edit_profile_page.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'profile_preview_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // CONTROLLERS ----------------------------------------------------------
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _designationCtl = TextEditingController();
  final _lifeMotoCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _websiteCtl = TextEditingController();
  final _profileUrlCtl = TextEditingController();

  // ERROR LABELS
  String? _nameError;
  String? _phoneError;
  String? _mottoError;

  // STATE
  File? _localImage;
  bool _loading = true;
  bool _saving = false;
  Timer? _debounce;

  // FIREBASE
  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  String get uid => _auth.currentUser!.uid;
  DocumentReference<Map<String, dynamic>> get userDoc =>
      _fire.collection('users').doc(uid);

  // INIT -----------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadData();

    for (final ctl in [
      _nameCtl,
      _phoneCtl,
      _designationCtl,
      _lifeMotoCtl,
      _websiteCtl,
      _profileUrlCtl,
    ]) {
      ctl.addListener(_onFieldChange);
    }
  }

  // FETCH USER DATA ------------------------------------------------------
  Future<void> _loadData() async {
    try {
      final snap = await userDoc.get();
      final d = snap.data() ?? {};

      _nameCtl.text = d['name'] ?? '';
      _phoneCtl.text = d['phone'] ?? '';
      _designationCtl.text = d['designation'] ?? '';
      _lifeMotoCtl.text = d['life_motto'] ?? '';
      _emailCtl.text = d['email'] ?? _auth.currentUser?.email ?? '';
      _websiteCtl.text = d['website'] ?? '';
      _profileUrlCtl.text = d['profileUrl'] ?? '';
      // load existing photo into _localImage is intentionally not done,
      // preview reads network image from Firestore 'photo' field.
    } catch (e) {
      debugPrint("Load failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // AUTO SAVE ------------------------------------------------------------
  void _onFieldChange() {
    setState(() {
      _nameError = null;
      _phoneError = null;
      _mottoError = null;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () => _autoSave());
  }

  Future<void> _autoSave() async {
    if (!_validate(autoSave: true)) return;

    try {
      await userDoc.set({
        "name": _nameCtl.text.trim(),
        "phone": _phoneCtl.text.trim(),
        "designation": _designationCtl.text.trim(),
        "life_motto": _lifeMotoCtl.text.trim(),
        "email": _emailCtl.text.trim(),
        "website": _websiteCtl.text.trim(),
        "profileUrl": _profileUrlCtl.text.trim(),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("AUTO SAVE FAILED → $e");
    }
  }

  // VALIDATION -----------------------------------------------------------
  bool _validate({bool autoSave = false}) {
    bool ok = true;

    if (_nameCtl.text.trim().isEmpty) {
      _nameError = "Name required";
      ok = false;
    } else {
      _nameError = null;
    }

    final p = _phoneCtl.text.replaceAll(RegExp(r'\D'), '');
    if (p.isNotEmpty && p.length < 10) {
      _phoneError = "Invalid phone";
      ok = false;
    } else {
      _phoneError = null;
    }

    if (_lifeMotoCtl.text.length > 120) {
      _mottoError = "Max 120 characters";
      ok = false;
    } else {
      _mottoError = null;
    }

    if (!autoSave) setState(() {});
    return ok;
  }

  // IMAGE PICK -----------------------------------------------------------
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() => _localImage = File(picked.path));
    }
  }

  // SAVE PROFILE ---------------------------------------------------------
  Future<void> _saveProfile() async {
    if (!_validate()) return;

    setState(() => _saving = true);

    try {
      String? photoUrl;

      if (_localImage != null) {
        final ref = FirebaseStorage.instance.ref("profile_photos/$uid.jpg");
        await ref.putFile(_localImage!);
        photoUrl = await ref.getDownloadURL();
      }

      await userDoc.set({
        "name": _nameCtl.text.trim(),
        "phone": _phoneCtl.text.trim(),
        "designation": _designationCtl.text.trim(),
        "life_motto": _lifeMotoCtl.text.trim(),
        "email": _emailCtl.text.trim(),
        "website": _websiteCtl.text.trim(),
        "profileUrl": _profileUrlCtl.text.trim(),
        if (photoUrl != null) "photo": photoUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Profile saved successfully")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // GLASS CONTAINER ------------------------------------------------------
  Widget glass({required Widget child, EdgeInsets? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  // UI -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: () {
              // OPEN preview page (no parameters) — preview reads Firestore directly
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePreviewPage()),
              );
            },
          )
        ],
      ),

      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade900,
                  Colors.teal.shade700,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar Card
                glass(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white24,
                          backgroundImage: _localImage != null
                              ? FileImage(_localImage!)
                              : null,
                          child: _localImage == null
                              ? const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 40)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameCtl.text.isEmpty
                                  ? "Your Name"
                                  : _nameCtl.text,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _designationCtl.text.isEmpty
                                  ? "Designation"
                                  : _designationCtl.text,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // Form Card
                const SizedBox(height: 16),
                glass(
                  child: Column(
                    children: [
                      _field("Full Name", _nameCtl, error: _nameError),
                      _field("Designation", _designationCtl),
                      _field("Life Motto", _lifeMotoCtl,
                          maxLines: 2, error: _mottoError),
                      _field("Phone", _phoneCtl,
                          keyboard: TextInputType.phone,
                          error: _phoneError),
                      _field("Website", _websiteCtl),
                      _field("Public Profile URL (QR)", _profileUrlCtl),
                      _field("Email (read-only)", _emailCtl, readOnly: true),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: _saving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.save),
                        label: Text(_saving ? "Saving..." : "Save"),
                        onPressed: _saving ? null : _saveProfile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      child: const Text("Preview"),
                      onPressed: () {
                        // OPEN preview page (no parameters)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfilePreviewPage()),
                        );
                      },
                    )
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Text Field Builder
  Widget _field(
    String label,
    TextEditingController ctl, {
    bool readOnly = false,
    String? error,
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctl,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _designationCtl.dispose();
    _lifeMotoCtl.dispose();
    _emailCtl.dispose();
    _websiteCtl.dispose();
    _profileUrlCtl.dispose();
    super.dispose();
  }
}
