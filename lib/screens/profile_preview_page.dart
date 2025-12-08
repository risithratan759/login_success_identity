/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePreviewPage extends StatelessWidget {
  const ProfilePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Preview"),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection("users").doc(uid).get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data()!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: data["photo"] != null
                      ? NetworkImage(data["photo"])
                      : const AssetImage("assets/default.png")
                          as ImageProvider,
                ),
                const SizedBox(height: 20),

                infoRow("Name", data["name"]),
                infoRow("Email", data["email"]),
                infoRow("Phone", data["phone"]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text("$label: ",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}
*/
/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePreviewPage extends StatelessWidget {
  const ProfilePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Preview')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: docRef.get(const GetOptions(source: Source.serverAndCache)),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() ?? {};

          final photo = data['photo'] as String? ?? '';
          final name = data['name'] ?? 'No name';
          final email = data['email'] ?? user.email ?? '';
          final phone = data['phone'] ?? '';
          final designation = data['designation'] ?? '';
          final motto = data['life_motto'] ?? '';   // ⭐ FIXED FIELD NAME ⭐

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: photo.isNotEmpty
                      ? CachedNetworkImageProvider(photo)
                      : const AssetImage('assets/default.png') as ImageProvider,
                ),
                const SizedBox(height: 20),

                infoTile("Name", name),
                infoTile("Email", email),
                infoTile("Phone", phone),
                infoTile("Designation", designation),
                infoTile("Life's Motto", motto), // ⭐ WORKS NOW ⭐
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoTile(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value.isNotEmpty ? value : "Not provided",
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

*/
// lib/screens/profile/profile_preview_page.dart
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePreviewPage extends StatelessWidget {
  const ProfilePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final docStream = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Preview (Live)')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data?.data() ?? {};

          final photo = (data['photo'] as String?) ?? '';
          final name = (data['name'] as String?) ?? user.displayName ?? 'No name';
          final email = (data['email'] as String?) ?? user.email ?? '';
          final phone = (data['phone'] as String?) ?? '';
          final designation = (data['designation'] as String?) ?? '';
          final motto = (data['life_motto'] as String?) ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // top header
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.teal.shade400]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0,6))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white24,
                        backgroundImage: photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null,
                        child: photo.isEmpty ? const Icon(Icons.person, size: 44, color: Colors.white70) : null,
                      ),
                      const SizedBox(height: 10),
                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(designation.isNotEmpty ? designation : 'Designation', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // info cards
                _infoCard('Email', email),
                _infoCard('Phone', phone),
                _infoCard("Life's Motto", motto),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(child: Text(value.isNotEmpty ? value : 'Not provided')),
        ],
      ),
    );
  }
}
*/
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfilePreviewPage extends StatefulWidget {
  final String name;
  final String title;
  final String about;
  final String avatarUrl;
  final String email;
  final String phone;
  final String website;
  final String profileUrl;

  const ProfilePreviewPage({
    super.key,
    this.name = '',
    this.title = '',
    this.about = '',
    this.avatarUrl = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.profileUrl = '',
  });

  @override
  State<ProfilePreviewPage> createState() => _ProfilePreviewPageState();
}

class _ProfilePreviewPageState extends State<ProfilePreviewPage> {
  final screenshotController = ScreenshotController();

  // ----------------------- Load Network Image Safely -----------------------
  Future<Uint8List?> loadNetworkImage(String url) async {
    try {
      final uri = Uri.parse(url);
      final data = await NetworkAssetBundle(uri).load(uri.path);
      return data.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  // ----------------------- PDF GENERATOR -----------------------
  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();

    // Load avatar image
    Uint8List? avatarBytes;
    if (widget.avatarUrl.isNotEmpty) {
      avatarBytes = await loadNetworkImage(widget.avatarUrl);
    }

    // Generate QR code bytes
    Uint8List? qrBytes;
    if (widget.profileUrl.isNotEmpty) {
      final qrPainter = QrPainter(
        data: widget.profileUrl,
        version: QrVersions.auto,
        gapless: true,
      );
      final qrImageData = await qrPainter.toImageData(300);
      qrBytes = qrImageData?.buffer.asUint8List();
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Avatar
                pw.Container(
                  width: 110,
                  height: 110,
                  child: avatarBytes != null
                      ? pw.ClipOval(
                          child: pw.Image(pw.MemoryImage(avatarBytes)),
                        )
                      : pw.Center(child: pw.Text("No Image")),
                ),
                pw.SizedBox(height: 16),

                // Name & Title
                pw.Text(
                  widget.name,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(widget.title, style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 16),

                // About
                pw.Text(widget.about, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 20),

                // Social Info
                pw.Column(
                  children: [
                    if (widget.email.isNotEmpty) pw.Text("📧 ${widget.email}"),
                    if (widget.phone.isNotEmpty) pw.Text("📞 ${widget.phone}"),
                    if (widget.website.isNotEmpty)
                      pw.Text("🌐 ${widget.website}"),
                  ],
                ),
                pw.SizedBox(height: 28),

                // QR code
                if (qrBytes != null)
                  pw.Image(pw.MemoryImage(qrBytes), width: 140),
                pw.SizedBox(height: 8),
                if (qrBytes != null) pw.Text("Scan to view profile"),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // ----------------------- EXPORT PNG -----------------------
  Future<void> exportPng() async {
    try {
      final img = await screenshotController.capture();
      if (img == null) return;

      await Printing.sharePdf(
        bytes: Uint8List.fromList(img),
        filename: "profile_card.png",
      );
    } catch (e) {
      debugPrint("PNG export failed: $e");
    }
  }

  // ----------------------- MAIN UI -----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Preview")),
      body: SingleChildScrollView(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 55,
                  backgroundImage: widget.avatarUrl.isNotEmpty
                      ? NetworkImage(widget.avatarUrl)
                      : null,
                  child: widget.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 55)
                      : null,
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // Social Info
                Wrap(
                  spacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    if (widget.email.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email, size: 18),
                          const SizedBox(width: 6),
                          Text(widget.email, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    if (widget.phone.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone, size: 18),
                          const SizedBox(width: 6),
                          Text(widget.phone, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    if (widget.website.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 18),
                          const SizedBox(width: 6),
                          Text(widget.website, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // About
                Text(
                  widget.about,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),

                // QR Code
                if (widget.profileUrl.isNotEmpty)
                  QrImageView(
                    data: widget.profileUrl,
                    size: 150,
                  ),
                const SizedBox(height: 8),
                if (widget.profileUrl.isNotEmpty)
                  const Text(
                    "Shareable QR Profile",
                    style: TextStyle(color: Colors.black54),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final pdfBytes = await generatePdf();
                await Printing.layoutPdf(onLayout: (_) => pdfBytes);
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Export PDF"),
            ),
            ElevatedButton.icon(
              onPressed: exportPng,
              icon: const Icon(Icons.image),
              label: const Text("Export PNG"),
            ),
          ],
        ),
      ),
    );
  }
}

