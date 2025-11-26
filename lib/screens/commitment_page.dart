import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommitmentPage extends StatefulWidget {
  @override
  State<CommitmentPage> createState() => _CommitmentPageState();
}

class _CommitmentPageState extends State<CommitmentPage> {
  final TextEditingController textCtl = TextEditingController();

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> addCommitment() async {
    final text = textCtl.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('commitments')
        .add({
      'text': text,
      'createdAt': Timestamp.now(),
    });

    textCtl.clear();
  }

  Future<void> updateCommitment(String id, String oldText) async {
    textCtl.text = oldText;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Commitment"),
        content: TextField(controller: textCtl),
        actions: [
          TextButton(
            onPressed: () async {
              final newText = textCtl.text.trim();
              if (newText.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('commitments')
                    .doc(id)
                    .update({'text': newText});
              }
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<void> deleteCommitment(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('commitments')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Daily Commitments"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: textCtl,
              decoration: InputDecoration(
                hintText: "Write your commitment",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addCommitment,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('commitments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snap.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No commitments yet", style: TextStyle(fontSize: 18)),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i];
                    return Card(
                      child: ListTile(
                        title: Text(data['text']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => updateCommitment(data.id, data['text'])),
                            IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteCommitment(data.id)),
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
