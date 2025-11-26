import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GoalsPage extends StatefulWidget {
  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final titleCtl = TextEditingController();
  final descCtl = TextEditingController();

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> addGoal() async {
    final t = titleCtl.text.trim();
    final d = descCtl.text.trim();
    if (t.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .add({
      'title': t,
      'description': d,
      'createdAt': Timestamp.now(),
    });

    titleCtl.clear();
    descCtl.clear();
  }

  Future<void> editGoal(String id, String oldTitle, String oldDesc) async {
    titleCtl.text = oldTitle;
    descCtl.text = oldDesc;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Goal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtl, decoration: const InputDecoration(hintText: "Title")),
            const SizedBox(height: 10),
            TextField(controller: descCtl, decoration: const InputDecoration(hintText: "Description")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('goals')
                  .doc(id)
                  .update({
                'title': titleCtl.text.trim(),
                'description': descCtl.text.trim(),
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<void> deleteGoal(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Goals"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: titleCtl,
                  decoration: const InputDecoration(
                    hintText: "Goal Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtl,
                  decoration: const InputDecoration(
                    hintText: "Goal Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addGoal,
                  child: const Text("Add Goal"),
                )
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('goals')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snap.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No goals added yet", style: TextStyle(fontSize: 18)),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i];
                    return Card(
                      child: ListTile(
                        title: Text(data['title']),
                        subtitle: Text(data['description']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => editGoal(
                                      data.id,
                                      data['title'],
                                      data['description'],
                                    )),
                            IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteGoal(data.id)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
