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
/*import 'dart:typed_data';
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

*/
/*import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
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
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>? ?? {};

        final photo = data["photo"] ?? "";
        final name = data["name"] ?? widget.name;
        final title = data["designation"] ?? widget.title;
        final about = data["life_motto"] ?? widget.about;
        final email = data["email"] ?? widget.email;
        final phone = data["phone"] ?? widget.phone;
        final website = data["website"] ?? widget.website;
        final profileUrl = data["profileUrl"] ?? widget.profileUrl;

        return Scaffold(
          appBar: AppBar(title: const Text("Profile Preview")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ---------------- AVATAR ----------------
                CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      photo.isNotEmpty ? NetworkImage(photo) : null,
                  child: photo.isEmpty
                      ? const Icon(Icons.person, size: 55)
                      : null,
                ),
                const SizedBox(height: 16),

                // ---------------- NAME ----------------
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),

                // ---------------- TITLE ----------------
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 17, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // ---------------- CONTACT INFO ----------------
                Wrap(
                  spacing: 20,
                  children: [
                    if (email.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email, size: 18),
                          const SizedBox(width: 6),
                          Text(email),
                        ],
                      ),
                    if (phone.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone, size: 18),
                          const SizedBox(width: 6),
                          Text(phone),
                        ],
                      ),
                    if (website.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 18),
                          const SizedBox(width: 6),
                          Text(website),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // ---------------- ABOUT ----------------
                Text(
                  about,
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // ---------------- QR CODE ----------------
                if (profileUrl.isNotEmpty)
                  Column(
                    children: [
                      QrImageView(data: profileUrl, size: 150),
                      const SizedBox(height: 8),
                      const Text("Shareable QR Profile",
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
              ],
            ),
          ),

          // ---------------- BOTTOM BUTTONS ----------------
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final pdf = await _buildPdf(name, title, about, email,
                        phone, website, profileUrl, photo);
                    await Printing.layoutPdf(onLayout: (_) => pdf);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Export PDF"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- PDF GENERATOR ----------------
  Future<Uint8List> _buildPdf(String name, String title, String about,
      String email, String phone, String website, String url, String photoUrl) async {
    final pdf = pw.Document();

    pw.ImageProvider? avatar;
    if (photoUrl.isNotEmpty) {
      final bytes = await NetworkAssetBundle(Uri.parse(photoUrl))
          .load(photoUrl);
      avatar = pw.MemoryImage(bytes.buffer.asUint8List());
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            if (avatar != null)
              pw.Container(
                width: 110,
                height: 110,
                child: pw.ClipOval(child: pw.Image(avatar!)),
              ),
            pw.SizedBox(height: 16),

            pw.Text(name,
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text(title),
            pw.SizedBox(height: 16),

            pw.Text(about, textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 20),

            pw.Text("Email: $email"),
            pw.Text("Phone: $phone"),
            pw.Text("Website: $website"),

            if (url.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.BarcodeWidget(
                data: url,
                width: 120,
                height: 120,
                barcode: pw.Barcode.qrCode(),
              ),
            ]
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
*/
// lib/screens/profile_preview_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePreviewPage extends StatefulWidget {
  const ProfilePreviewPage({super.key});

  @override
  State<ProfilePreviewPage> createState() => _ProfilePreviewPageState();
}

class _ProfilePreviewPageState extends State<ProfilePreviewPage>
    with SingleTickerProviderStateMixin {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ===================== Utilities =====================

  Future<Uint8List?> _loadNetworkImageBytes(String url) async {
    try {
      if (url.isEmpty) return null;
      final bundle = NetworkAssetBundle(Uri.parse(url));
      final data = await bundle.load(url);
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _generatePdfBytes({
    required String name,
    required String title,
    required String about,
    required String email,
    required String phone,
    required String website,
    required String profileUrl,
    required String photoUrl,
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? avatarImage;
    if (photoUrl.isNotEmpty) {
      final bytes = await _loadNetworkImageBytes(photoUrl);
      if (bytes != null) {
        avatarImage = pw.MemoryImage(bytes);
      }
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (avatarImage != null)
                  pw.Container(
                    width: 120,
                    height: 120,
                    child: pw.ClipOval(child: pw.Image(avatarImage)),
                  ),
                pw.SizedBox(height: 12),
                pw.Text(name,
                    style:
                        pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(title, style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 14),
                pw.Text(about, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 18),
                if (email.isNotEmpty) pw.Text("Email: $email"),
                if (phone.isNotEmpty) pw.Text("Phone: $phone"),
                if (website.isNotEmpty) pw.Text("Website: $website"),
                pw.SizedBox(height: 16),
                if (profileUrl.isNotEmpty)
                  pw.BarcodeWidget(
                    data: profileUrl,
                    width: 120,
                    height: 120,
                    barcode: pw.Barcode.qrCode(),
                  )
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<File> _createVCardFile({
    required String name,
    required String email,
    required String phone,
    required String website,
  }) async {
    final vcf = StringBuffer();
    vcf.writeln('BEGIN:VCARD');
    vcf.writeln('VERSION:3.0');
    vcf.writeln('FN:$name');
    if (phone.isNotEmpty) vcf.writeln('TEL;TYPE=CELL:$phone');
    if (email.isNotEmpty) vcf.writeln('EMAIL:$email');
    if (website.isNotEmpty) vcf.writeln('URL:$website');
    vcf.writeln('END:VCARD');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/profile_$uid.vcf');
    await file.writeAsString(vcf.toString(), flush: true);
    return file;
  }

  // ===================== Sharing Methods =====================

  Future<void> _shareLink(String? profileUrl) async {
    if (profileUrl == null || profileUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No public profile link to share.')));
      return;
    }
    await Share.share('Check my profile: $profileUrl');
  }

  Future<void> _sharePdf(Map<String, dynamic> data) async {
    try {
      final bytes = await _generatePdfBytes(
        name: data['name'] ?? '',
        title: data['designation'] ?? '',
        about: data['life_motto'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        website: data['website'] ?? '',
        profileUrl: data['profileUrl'] ?? '',
        photoUrl: data['photo'] ?? '',
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/profile_card_$uid.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([XFile(file.path)], text: 'My profile');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF share failed: $e')));
    }
  }

  Future<void> _shareImageFromCard() async {
    try {
      final pngBytes = await _screenshotController.capture(pixelRatio: 2.5);
      if (pngBytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not capture image')));
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/profile_card_$uid.png');
      await file.writeAsBytes(pngBytes, flush: true);
      await Share.shareXFiles([XFile(file.path)], text: 'My profile card');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image share failed: $e')));
    }
  }

  Future<void> _shareVCard(Map<String, dynamic> data) async {
    try {
      final file = await _createVCardFile(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        website: data['website'] ?? '',
      );
      await Share.shareXFiles([XFile(file.path)], text: 'Contact vCard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('vCard share failed: $e')));
    }
  }

  Future<void> _whatsAppShare(String message) async {
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/?text=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp not available')));
    }
  }

  // ===================== UI =====================

  void _openShareSheet(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                Center(child: Container(height: 4, width: 50, color: Colors.grey[300])),
                const SizedBox(height: 12),
                Center(child: Text('Share Profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                const SizedBox(height: 18),

                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _shareTile(icon: Icons.link, label: 'Link', onTap: () {
                    Navigator.pop(context);
                    _shareLink(data['profileUrl']);
                  }),
                  _shareTile(icon: Icons.picture_as_pdf, label: 'PDF', onTap: () {
                    Navigator.pop(context);
                    _sharePdf(data);
                  }),
                  _shareTile(icon: Icons.image, label: 'Image', onTap: () {
                    Navigator.pop(context);
                    _shareImageFromCard();
                  }),
                ]),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _shareTile(icon: Icons.contact_page, label: 'vCard', onTap: () {
                    Navigator.pop(context);
                    _shareVCard(data);
                  }),
                  _shareTile(
                    // use FontAwesome whatsapp icon via iconWidget
                    iconWidget: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                    label: 'WhatsApp',
                    onTap: () {
                      Navigator.pop(context);
                      final message = '📇 ${data['name'] ?? ''}\n📧 ${data['email'] ?? ''}\n📞 ${data['phone'] ?? ''}\n${data['profileUrl'] ?? ''}';
                      _whatsAppShare(message);
                    },
                  ),
                  _shareTile(icon: Icons.more_horiz, label: 'More', onTap: () {
                    Navigator.pop(context);
                    final message = '📇 ${data['name'] ?? ''}\n📧 ${data['email'] ?? ''}\n📞 ${data['phone'] ?? ''}\n${data['profileUrl'] ?? ''}';
                    Share.share(message);
                  }),
                ]),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // updated helper supports either IconData or a custom Widget (iconWidget)
  Widget _shareTile({
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.blue.shade50,
          child: iconWidget ??
              Icon(
                icon,
                color: Colors.blueAccent,
              ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final data = snap.data?.data() ?? {};

        final photo = (data['photo'] as String?) ?? '';
        final name = (data['name'] as String?) ?? '';
        final title = (data['designation'] as String?) ?? '';
        final about = (data['life_motto'] as String?) ?? '';
        final email = (data['email'] as String?) ?? '';
        final phone = (data['phone'] as String?) ?? '';
        final website = (data['website'] as String?) ?? '';
        final profileUrl = (data['profileUrl'] as String?) ?? '';

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _openShareSheet(context, data),
              )
            ],
          ),
          body: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade600, Colors.pink.shade300, Colors.orange.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      width: 360,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.85)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 14, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // top row with avatar + badges
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // avatar
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade200, width: 2),
                                ),
                                child: ClipOval(
                                  child: photo.isNotEmpty
                                      ? CachedNetworkImage(imageUrl: photo, fit: BoxFit.cover, errorWidget: (_,__,___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.person, size: 40)))
                                      : Container(color: Colors.grey.shade200, child: const Icon(Icons.person, size: 40)),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // name & tags
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(title, style: TextStyle(color: Colors.grey.shade700)),
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      if (website.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                          child: Row(children: [const Icon(Icons.language, size: 14), const SizedBox(width: 6), Text('Website', style: TextStyle(fontSize: 12))]),
                                        ),
                                      const SizedBox(width: 8),
                                      if (profileUrl.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                          child: Row(children: [const Icon(Icons.qr_code, size: 14), const SizedBox(width: 6), Text('Profile Link', style: TextStyle(fontSize: 12))]),
                                        ),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // about
                          if (about.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(about, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 1.4)),
                            ),

                          const SizedBox(height: 8),

                          // contact row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _infoChip(icon: Icons.email, label: email),
                              _infoChip(icon: Icons.phone, label: phone),
                              _infoChip(icon: Icons.share, label: profileUrl.isNotEmpty ? 'Link' : ''),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // QR preview
                          if (profileUrl.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                              child: QrImageView(data: profileUrl, size: 120),
                            ),

                          const SizedBox(height: 12),

                          // actions row inside card
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text('Download PDF'),
                                  onPressed: () async => _sharePdf(data),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.image),
                                label: const Text('Share Image'),
                                onPressed: _shareImageFromCard,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(height: 6),
        SizedBox(width: 90, child: Text(label.isNotEmpty ? label : '—', textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
