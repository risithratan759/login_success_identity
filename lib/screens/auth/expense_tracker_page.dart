import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

enum ReportType { day, week, month, year }

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  final categories = {
    'Food': Colors.orange,
    'Travel': Colors.blue,
    'Shopping': Colors.purple,
    'Bills': Colors.red,
    'Other': Colors.green,
  };

  ReportType _reportType = ReportType.day;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // ================= FIRESTORE STREAM =================
  Stream<QuerySnapshot> get _expenseStream => FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('expenses')
      .orderBy('date', descending: true)
      .snapshots();

  // ================= ADD EXPENSE =================
  void _addExpenseDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedCategory = 'Food';
    DateTime selectedDate = DateTime.now();

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
            const Text("Add Expense",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            // Title
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),

            // Amount
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            const SizedBox(height: 10),

            // Category
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => selectedCategory = v!,
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 10),

            // Date picker
            Row(
              children: [
                const Text("Date: "),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) selectedDate = picked;
                    setState(() {});
                  },
                  child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                )
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Save Expense"),
                onPressed: () async {
                  if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('expenses')
                      .add({
                    'title': titleCtrl.text.trim(),
                    'amount': double.parse(amountCtrl.text),
                    'category': selectedCategory,
                    'date': Timestamp.fromDate(selectedDate),
                  });

                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PIE CHART =================
  Widget _buildPieChart(List<QueryDocumentSnapshot> docs) {
    final Map<String, double> totals = {};
    for (var d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final category = data['category'] ?? 'Other';
      totals[category] =
          (totals[category] ?? 0) + (data['amount'] as num).toDouble();
    }
    if (totals.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 240,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 55,
          sectionsSpace: 3,
          sections: totals.entries.map((e) {
            return PieChartSectionData(
              value: e.value,
              title: "${e.key}\n${currency.format(e.value)}",
              radius: 80,
              color: categories[e.key] ?? Colors.grey,
              titleStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ================= EXPORT CSV WITH FILTER =================
  Future<void> _exportCSVFiltered(List<QueryDocumentSnapshot> docs) async {
    final now = DateTime.now();
    List<List<dynamic>> rows = [
      ['Title', 'Amount', 'Category', 'Date']
    ];

    for (var d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      bool include = false;

      switch (_reportType) {
        case ReportType.day:
          include = DateUtils.isSameDay(date, now);
          break;
        case ReportType.week:
          include = date.isAfter(now.subtract(const Duration(days: 7)));
          break;
        case ReportType.month:
          include = date.month == now.month && date.year == now.year;
          break;
        case ReportType.year:
          include = date.year == now.year;
          break;
      }

      if (include) {
        rows.add([
          data['title'],
          data['amount'],
          data['category'] ?? 'Other',
          DateFormat('yyyy-MM-dd').format(date),
        ]);
      }
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expenses_${_reportType.name}.csv');
    await file.writeAsString(csv);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "CSV exported for ${_reportType.name} at ${file.path}")),
      );
    }
  }

  // ================= CALENDAR BASED EXPENSES =================
  Map<DateTime, List<Map<String, dynamic>>> _groupExpensesByDate(
      List<QueryDocumentSnapshot> docs) {
    final Map<DateTime, List<Map<String, dynamic>>> data = {};
    for (var d in docs) {
      final docData = d.data() as Map<String, dynamic>;
      final date = (docData['date'] as Timestamp).toDate();
      final day = DateTime(date.year, date.month, date.day);
      if (data.containsKey(day)) {
        data[day]!.add(docData);
      } else {
        data[day] = [docData];
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        centerTitle: true,
        actions: [
          PopupMenuButton<ReportType>(
            onSelected: (value) async {
              setState(() => _reportType = value);
              final snap = await _expenseStream.first;
              await _exportCSVFiltered(snap.docs);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: ReportType.day, child: Text("Export Day-wise CSV")),
              const PopupMenuItem(
                  value: ReportType.week, child: Text("Export Week-wise CSV")),
              const PopupMenuItem(
                  value: ReportType.month, child: Text("Export Month-wise CSV")),
              const PopupMenuItem(
                  value: ReportType.year, child: Text("Export Year-wise CSV")),
            ],
            icon: const Icon(Icons.file_download),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpenseDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _expenseStream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          final total = docs.fold<double>(0, (s, d) {
            final data = d.data() as Map<String, dynamic>;
            return s + (data['amount'] as num).toDouble();
          });

          final expensesByDate = _groupExpensesByDate(docs);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Spent",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(
                      currency.format(total),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pie chart
              _buildPieChart(docs),
              const Divider(height: 30),

              // Calendar
              TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final dayExpenses = expensesByDate[day] ?? [];
                    if (dayExpenses.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),

              // List of expenses for selected day
              const SizedBox(height: 10),
              if (_selectedDay != null)
                ...?expensesByDate[_selectedDay]?.map((data) {
                  final cat = data['category'] ?? 'Other';
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: categories[cat] ?? Colors.grey,
                        child:
                            const Icon(Icons.attach_money, color: Colors.white),
                      ),
                      title: Text(data['title']),
                      subtitle: Text(
                          "$cat • ${DateFormat('dd MMM yyyy').format((data['date'] as Timestamp).toDate())}"),
                      trailing: Text(currency.format(data['amount']),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
