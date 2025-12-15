// lib/screens/diary/diary_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final user = FirebaseAuth.instance.currentUser!;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Diary"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDiarySheet(),
        icon: const Icon(Icons.edit),
        label: const Text("New Entry"),
      ),

      body: Column(
        children: [
          // 📅 Calendar Header
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(0.12),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2021),
              lastDay: DateTime.utc(2035),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),

          // 📖 Entries
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('diary')
                  .where(
                    'date',
                    isGreaterThanOrEqualTo:
                        Timestamp.fromDate(DateTime(
                      _selectedDay.year,
                      _selectedDay.month,
                      _selectedDay.day,
                    )),
                    isLessThan:
                        Timestamp.fromDate(DateTime(
                      _selectedDay.year,
                      _selectedDay.month,
                      _selectedDay.day + 1,
                    )),
                  )
                  .orderBy('date', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No diary entry for this day ✨",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: snapshot.data!.docs.map((doc) {
                    return _diaryCard(
                      doc.id,
                      doc['title'],
                      doc['content'],
                      (doc.data() as Map<String, dynamic>)['mood'] ?? "🙂",
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🧾 Modern Diary Card
  Widget _diaryCard(
    String id,
    String title,
    String content,
    String mood,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.08),
            Theme.of(context).colorScheme.primary.withOpacity(0.02),
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(mood, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton(
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text("Edit")),
                  PopupMenuItem(value: 'delete', child: Text("Delete")),
                ],
                onSelected: (v) {
                  if (v == 'edit') {
                    _openDiarySheet(
                      docId: id,
                      oldTitle: title,
                      oldContent: content,
                      oldMood: mood,
                    );
                  } else {
                    _deleteEntry(id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ✍️ Bottom Sheet Editor
  void _openDiarySheet({
    String? docId,
    String? oldTitle,
    String? oldContent,
    String? oldMood,
  }) {
    final titleCtrl = TextEditingController(text: oldTitle);
    final contentCtrl = TextEditingController(text: oldContent);
    String mood = oldMood ?? "🙂";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Write your thoughts ✨",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Mood selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["😄", "😊", "😐", "😔", "😡"].map((m) {
                return IconButton(
                  onPressed: () => setState(() => mood = m),
                  icon: Text(m, style: const TextStyle(fontSize: 26)),
                );
              }).toList(),
            ),

            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "Your thoughts"),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                final ref = FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('diary');

                if (docId == null) {
                  await ref.add({
                    'title': titleCtrl.text,
                    'content': contentCtrl.text,
                    'mood': mood,
                    'date': Timestamp.fromDate(_selectedDay),
                    'createdAt': Timestamp.now(),
                  });
                } else {
                  await ref.doc(docId).update({
                    'title': titleCtrl.text,
                    'content': contentCtrl.text,
                    'mood': mood,
                  });
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save Entry"),
            ),
          ],
        ),
      ),
    );
  }

  // 🗑 Delete
  Future<void> _deleteEntry(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('diary')
        .doc(id)
        .delete();
  }
}
