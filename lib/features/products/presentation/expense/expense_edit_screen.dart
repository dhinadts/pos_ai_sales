import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/expence/expence_service_riverpod.dart';
import 'package:pos_ai_sales/core/models/expense.dart';
import 'package:pos_ai_sales/features/products/presentation/Widgets/text_box.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final UuidValue expenseId;
  final String mode;
  const EditExpenseScreen({
    super.key,
    required this.expenseId,
    required this.mode,
  });

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl; //  "Employee Salary");
  late TextEditingController noteCtrl; //  "Salary");
  late TextEditingController amountCtrl; //  "10000");
  late TextEditingController dateCtrl; //  "2020-03-27");
  late TextEditingController timeCtrl; //  "11:30 PM");

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: "Employee Salary");
    noteCtrl = TextEditingController(text: "Salary");
    amountCtrl = TextEditingController(text: "10000");
    dateCtrl = TextEditingController(text: "2020-03-27");
    timeCtrl = TextEditingController(text: "11:30 PM");

    if (widget.mode == "edit") {
      _loadCustomer();
    }
  }

  Future<void> _loadCustomer() async {
    final c = await ref
        .read(ExpenseRepoProvider)
        .byId(widget.expenseId.toString());
    if (c != null) {
      nameCtrl.text = c.name ?? 'Empl Sal';

      noteCtrl.text = c.note ?? "Salary";
      amountCtrl.text = c.amount?.toString() ?? "0.0";
      dateCtrl.text = c.date ?? "2020-03-27";
      timeCtrl.text = c.time ?? "11:30 PM";
    }
  }

  Future<void> _save() async {
    final repo = ref.read(ExpenseRepoProvider);

    final data = Expense(
      expenseId: widget.expenseId,
      name: nameCtrl.text,
      note: noteCtrl.text,
      amount: double.tryParse(amountCtrl.text) ?? 0.0,
      date: dateCtrl.text,
      time: timeCtrl.text,
      // imagePath: null,
      lastModified: DateTime.now(),
    );

    if (widget.mode == "edit") {
      await repo.update(data);
    } else {
      await repo.save(data);
    }

    ref.invalidate(ExpenseListProvider); // refresh list screen
    context.go('/expenses');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/expenses'); // go to home
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mode == 'add' ? "Add Expense" : "Edit Expense"),
          backgroundColor: const Color(0xff00B4F0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.go('/expenses'),
            // FIX: go_router pop
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Expense Name"),
              const SizedBox(height: 8),
              EditableFieldBox(value: "Expense Name", controller: nameCtrl),
              const SizedBox(height: 16),

              const Text("Expense Note (if any)"),
              const SizedBox(height: 8),
              EditableFieldBox(
                value: "Expense Note",
                controller: noteCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              const Text("Expense Amount"),
              const SizedBox(height: 8),
              EditableFieldBox(
                value: "Amount",
                controller: amountCtrl,
                fieldType: FieldType.decimal,
              ),
              const SizedBox(height: 16),

              const Text("Expense Date"),
              const SizedBox(height: 8),
              EditableFieldBox(value: "Date", controller: dateCtrl),
              const SizedBox(height: 16),

              const Text("Expense Time"),
              const SizedBox(height: 8),
              EditableFieldBox(value: "Time", controller: timeCtrl),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00B4F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _save,
                  child: Text(widget.mode == 'add' ? 'Add' : 'Edit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
