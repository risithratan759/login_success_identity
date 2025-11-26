import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final diaryCtl = TextEditingController();
  final StorageService _storage = StorageService();
  final FirestoreService _db = FirestoreService();
  File? pickedImage;

  DateTime selectedDay = DateTime.now();

  Future<void> pickImage() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        pickedImage = File(file.path);
      });
    }
  }

  Future<void> saveEntry() async {
    if (diaryCtl.text.trim().isEmpty && pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Write something or attach image.")));
      return;
    }

    String? imageUrl;

    if (pickedImage != null) {
      imageUrl = await _storage.uploadDiaryImage(
          pickedImage!, _db.uid ?? "unknown");
    }

    await _db.addDiary({
      'text': diaryCtl.text.trim(),
      'date': selectedDay,
      'image': imageUrl,
    });

    diaryCtl.clear();
    pickedImage = null;

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Entry saved')));
  }

  Future<void> exportPDF() async {
    final pdf = pw.Document();

    final snapshot = await _db.diaryCol().orderBy('createdAt').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                DateFormat.yMMMd().format(data['date'].toDate()),
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(data['text'] ?? ''),
              pw.SizedBox(height: 8),
              if (data['image'] != null)
                pw.Text("[Image attached: ${data['image']}]"),
              pw.Divider(),
            ],
          ),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        actions: [
          IconButton(onPressed: exportPDF, icon: const Icon(Icons.picture_as_pdf))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: pickImage, child: const Icon(Icons.image)),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: (day, _) => setState(() => selectedDay = day),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: diaryCtl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Write your diary...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (pickedImage != null)
            SizedBox(height: 120, child: Image.file(pickedImage!)),
          ElevatedButton(
            onPressed: saveEntry,
            child: const Text("Save Entry"),
          ),
          const Divider(height: 20),
          Expanded(
            child: StreamBuilder(
              stream: _db.diaryCol().orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No diary entries yet"));
                }

                return ListView(
                  children: docs.map((doc) {
                    final data = doc.data();
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(data['text'] ?? ''),
                        subtitle: Text(
                          DateFormat.yMMMd().format(data['date'].toDate()),
                        ),
                        trailing: IconButton(
                            onPressed: () => _db.deleteDiary(doc.id),
                            icon: const Icon(Icons.delete, color: Colors.red)),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
