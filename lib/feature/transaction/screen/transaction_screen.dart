import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main/widget/school_type_filter_widget.dart';
import '../controller/student_fee_controller.dart';
import '../controller/teacher_salary_controller.dart';
import '../model/student_fee_model.dart';
import '../model/teacher_salary_model.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TeacherSalaryController teacherController = Get.find<TeacherSalaryController>();
  final StudentFeeController studentController = Get.find<StudentFeeController>();

  final _searchController = TextEditingController();

  bool _showRightPanel = false;
  bool _isAddingTransaction = false;
  bool _showHistory = false;

  // Toggle state: 0 = Teacher, 1 = Student
  int _selectedTab = 0;

  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Expanded(
              flex: _showRightPanel ? 5 : 8,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  Expanded(
                    child: _selectedTab == 0
                        ? _buildTeacherList()
                        : _buildStudentList(),
                  ),
                ],
              ),
            ),
            Container(
              width: 480,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                border: Border(left: BorderSide(color: Colors.grey[200]!, width: 1)),
              ),
              child: _showRightPanel
                  ? (_isAddingTransaction
                  ? _buildAddTransactionPanel()
                  : _showHistory
                  ? _buildHistoryPanel()
                  : _buildViewPanel())
                  : _buildEmptyRightPanel(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTeacherList() {
    if (teacherController.isLoading.value) return const Center(child: CircularProgressIndicator());
    if (teacherController.filteredList.isEmpty) return _buildEmptyState('No Teachers Found');

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: teacherController.filteredList.length,
      itemBuilder: (context, index) => _buildTeacherCard(teacherController.filteredList[index]),
    );
  }

  Widget _buildStudentList() {
    if (studentController.isLoading.value) return const Center(child: CircularProgressIndicator());
    if (studentController.filteredList.isEmpty) return _buildEmptyState('No Students Found');

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: studentController.filteredList.length,
      itemBuilder: (context, index) => _buildStudentCard(studentController.filteredList[index]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: _selectedTab == 0 ? Colors.green[50] : Colors.teal[50],
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Icon(
                    _selectedTab == 0 ? Icons.account_balance_wallet : Icons.school,
                    color: _selectedTab == 0 ? Colors.green[700] : Colors.teal[700],
                    size: 20
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _selectedTab == 0 ? 'Teacher Salary' : 'Student Fees',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  Text(
                      '${_selectedTab == 0 ? teacherController.filteredList.length : studentController.filteredList.length} records found',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // 🔥 Toggle Button (Teacher vs Student)
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Teacher', 0),
                    _buildTabButton('Student', 1),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SchoolTypeFilterWidget(
                compact: true,
                value: _selectedTab == 0 ? teacherController.selectedSchool.value : studentController.selectedSchool.value,
                onChanged: (school) {
                  if (_selectedTab == 0) {
                    teacherController.setSelectedSchool(school);
                  } else {
                    studentController.setSelectedSchool(school);
                  }
                  setState(() => _showRightPanel = false);
                },
              ),
              if (_showRightPanel)
                IconButton(
                  onPressed: () => setState(() {
                    _showRightPanel = false;
                    _isAddingTransaction = false;
                    _showHistory = false;
                    if (_selectedTab == 0) teacherController.selectedTeacher.value = null;
                    if (_selectedTab == 1) studentController.selectedStudent.value = null;
                  }),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _showRightPanel = false;
          _isAddingTransaction = false;
          _showHistory = false;
        });
        _searchController.clear();
        if (index == 0) teacherController.searchQuery.value = '';
        if (index == 1) studentController.searchQuery.value = '';
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)] : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Container(
        height: 38,
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            if (_selectedTab == 0) teacherController.searchQuery.value = value;
            if (_selectedTab == 1) studentController.searchQuery.value = value;
          },
          decoration: InputDecoration(
            hintText: 'Search by name or ID...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  // ================= TEACHER UI =================

  Widget _buildTeacherCard(TeacherSalaryModel teacher) {
    final isSelected = teacherController.selectedTeacher.value?.id == teacher.id;
    final summary = teacher.transaction;

    return GestureDetector(
      onTap: () {
        teacherController.selectedTeacher.value = teacher;
        teacherController.loadHistory(teacher.id);
        setState(() {
          _showRightPanel = true;
          _isAddingTransaction = false;
          _showHistory = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.blue[300]! : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue[100],
              backgroundImage: teacher.teacherProfile != null ? NetworkImage(teacher.teacherProfile!) : null,
              child: teacher.teacherProfile == null
                  ? Text('${teacher.firstName.isNotEmpty ? teacher.firstName[0] : ''}${teacher.lastName.isNotEmpty ? teacher.lastName[0] : ''}'.toUpperCase(), style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${teacher.firstName} ${teacher.lastName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('ID: ${teacher.teacherIdCard ?? "N/A"} • ${teacher.schoolName ?? "N/A"}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
            if (summary != null)
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: summary.status == 'Paid' ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      summary.status,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: summary.status == 'Paid' ? Colors.green[700] : Colors.orange[700]),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('₹${summary.pending.toStringAsFixed(0)} Pending', style: TextStyle(fontSize: 11, color: Colors.red[400], fontWeight: FontWeight.w600)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ================= STUDENT UI =================

  Widget _buildStudentCard(StudentFeeModel student) {
    final isSelected = studentController.selectedStudent.value?.id == student.id;
    final summary = student.feeSummary;

    return GestureDetector(
      onTap: () {
        studentController.selectedStudent.value = student;
        studentController.loadHistory(student.id);
        setState(() {
          _showRightPanel = true;
          _isAddingTransaction = false;
          _showHistory = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.teal[300]! : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.teal[100],
              backgroundImage: student.studentProfile != null ? NetworkImage(student.studentProfile!) : null,
              child: student.studentProfile == null
                  ? Text('${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}'.toUpperCase(), style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${student.firstName} ${student.lastName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('Class: ${student.studentClass} • ID: ${student.studentIdCard ?? "N/A"}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
            if (summary != null)
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: summary.status == 'Paid' ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      summary.status,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: summary.status == 'Paid' ? Colors.green[700] : Colors.red[700]),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('₹${summary.pending.toStringAsFixed(0)} Pending', style: TextStyle(fontSize: 11, color: Colors.red[400], fontWeight: FontWeight.w600)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ================= COMMON DETAILS UI =================

  Widget _buildViewPanel() {
    if (_selectedTab == 0) {
      final teacher = teacherController.selectedTeacher.value;
      if (teacher == null) return const SizedBox();
      final summary = teacher.transaction;

      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue[100],
                backgroundImage: teacher.teacherProfile != null ? NetworkImage(teacher.teacherProfile!) : null,
                child: teacher.teacherProfile == null
                    ? Text('${teacher.firstName.isNotEmpty ? teacher.firstName[0] : ''}${teacher.lastName.isNotEmpty ? teacher.lastName[0] : ''}'.toUpperCase(), style: TextStyle(fontSize: 18, color: Colors.blue[700], fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${teacher.firstName} ${teacher.lastName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(teacher.schoolName ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow('ID Card', teacher.teacherIdCard ?? 'N/A'),
          _buildDetailRow('Base Salary', '₹${teacher.salary}'),
          if (summary != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[100]!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Month Summary (${_months[summary.month - 1]} ${summary.year})', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem('Total Paid', '₹${summary.totalPaid.toStringAsFixed(0)}', Colors.green),
                      _buildSummaryItem('Pending', '₹${summary.pending.toStringAsFixed(0)}', Colors.red),
                      _buildSummaryItem('Status', summary.status, summary.status == 'Paid' ? Colors.green : Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _amountController.clear();
                    _remarksController.clear();
                    setState(() { _isAddingTransaction = true; _showHistory = false; });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Pay Salary'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    teacherController.loadHistory(teacher.id);
                    setState(() { _showHistory = true; _isAddingTransaction = false; });
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      final student = studentController.selectedStudent.value;
      if (student == null) return const SizedBox();
      final summary = student.feeSummary;

      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.teal[100],
                backgroundImage: student.studentProfile != null ? NetworkImage(student.studentProfile!) : null,
                child: student.studentProfile == null
                    ? Text('${student.firstName.isNotEmpty ? student.firstName[0] : ''}${student.lastName.isNotEmpty ? student.lastName[0] : ''}'.toUpperCase(), style: TextStyle(fontSize: 18, color: Colors.teal[700], fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${student.firstName} ${student.lastName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(student.schoolName ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow('ID Card', student.studentIdCard ?? 'N/A'),
          _buildDetailRow('Class', student.studentClass),
          if (summary != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal[100]!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fee Summary', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem('Total Fee', '₹${summary.totalFee.toStringAsFixed(0)}', Colors.black87),
                      _buildSummaryItem('Paid', '₹${summary.totalPaid.toStringAsFixed(0)}', Colors.green),
                      _buildSummaryItem('Pending', '₹${summary.pending.toStringAsFixed(0)}', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _amountController.clear();
                    _remarksController.clear();
                    setState(() { _isAddingTransaction = true; _showHistory = false; });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Pay Fee'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    studentController.loadHistory(student.id);
                    setState(() { _showHistory = true; _isAddingTransaction = false; });
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildAddTransactionPanel() {
    final isTeacher = _selectedTab == 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Icon(Icons.payments, color: isTeacher ? Colors.green[700] : Colors.teal[700]),
            const SizedBox(width: 8),
            Text(isTeacher ? 'Pay Salary' : 'Collect Fee', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder(), isDense: true),
        ),
        const SizedBox(height: 16),

        // Month/Year only for Teacher
        if (isTeacher) ...[
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder(), isDense: true),
                  items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_months[i]))),
                  onChanged: (val) => setState(() => _selectedMonth = val!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder(), isDense: true),
                  items: List.generate(5, (i) => DropdownMenuItem(value: 2024 + i, child: Text('${2024 + i}'))),
                  onChanged: (val) => setState(() => _selectedYear = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        TextField(
          controller: _remarksController,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Remarks (Optional)', border: OutlineInputBorder(), isDense: true),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _isAddingTransaction = false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() => ElevatedButton(
                onPressed: (isTeacher ? teacherController.isSubmitting.value : studentController.isSubmitting.value)
                    ? null
                    : () async {
                  final amount = double.tryParse(_amountController.text);
                  if (amount == null || amount <= 0) {
                    Get.snackbar('Error', 'Enter a valid amount');
                    return;
                  }

                  if (isTeacher) {
                    final success = await teacherController.addTransaction(
                      teacherId: teacherController.selectedTeacher.value!.id,
                      amount: amount,
                      month: _selectedMonth,
                      year: _selectedYear,
                      remarks: _remarksController.text.trim(),
                    );
                    if (success) setState(() => _isAddingTransaction = false);
                  } else {
                    final success = await studentController.addTransaction(
                      studentId: studentController.selectedStudent.value!.id,
                      amount: amount,
                      remarks: _remarksController.text.trim(),
                    );
                    if (success) setState(() => _isAddingTransaction = false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: isTeacher ? Colors.green[700] : Colors.teal[700], foregroundColor: Colors.white),
                child: (isTeacher ? teacherController.isSubmitting.value : studentController.isSubmitting.value)
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit'),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryPanel() {
    final isTeacher = _selectedTab == 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showHistory = false),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text(
                isTeacher ? 'Transaction History' : 'Payment History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (isTeacher ? teacherController.isLoadingHistory.value : studentController.isLoadingHistory.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // 🔥 FIX: dynamic list create karein taaki properties access ho sakein
            List<dynamic> historyList = isTeacher
                ? teacherController.historyList.toList()
                : studentController.historyList.toList();

            if (historyList.isEmpty) {
              return const Center(child: Text('No transactions found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final tx = historyList[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    ),
                    title: Text('₹${tx.amountPaid}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      isTeacher
                          ? '${_months[(tx.month as int) - 1]} ${tx.year}\n${tx.remarks != null && tx.remarks!.isNotEmpty ? tx.remarks! : "No remarks"}'
                          : '${tx.paymentDate.toString().split("T").first}\n${tx.remarks != null && tx.remarks!.isNotEmpty ? tx.remarks! : "No remarks"}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Delete",
                          middleText: "Are you sure you want to delete this transaction?",
                          textConfirm: "Yes",
                          textCancel: "No",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          onConfirm: () {
                            if (isTeacher) {
                              teacherController.deleteTransaction(
                                  teacherController.selectedTeacher.value!.id, tx.id as int);
                            } else {
                              studentController.deleteTransaction(
                                  studentController.selectedStudent.value!.id, tx.id as int);
                            }
                            Get.back();
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.money_off, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildEmptyRightPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Select a record to view details', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600], fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}