import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

// ============ ENUMS ============
enum FeeFilter { all, paid, partial, pending, overdue }

enum SchoolFilter { all, schoolA, schoolB }

// ============ MAIN SCREEN ============
class FeeScreen extends StatefulWidget {
  const FeeScreen({super.key});

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  // ============ STATE ============
  List<Map<String, dynamic>> _feeRecords = [];
  FeeFilter _currentFilter = FeeFilter.all;
  SchoolFilter _currentSchoolFilter = SchoolFilter.all;
  String _searchQuery = '';
  bool _showRightPanel = false;
  Map<String, dynamic>? _selectedRecord;
  bool _isEditing = false;
  bool _isAddingNew = false;
  String _selectedCategory = 'Students';

  // ============ FORM CONTROLLERS ============
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _paidController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ============ FORM STATE ============
  String _selectedClassForm = 'LKG';
  String _selectedPaymentMode = 'Cash';
  String _selectedCategoryForm = 'Students';
  String _selectedExpenseType = 'Maintenance';
  String _selectedSchoolForm = 'School A';
  File? _imageFile;

  // ============ CONSTANTS ============
  final List<String> _categoryList = ['Students', 'Teachers', 'School Fund'];
  final List<String> _schoolList = ['School A', 'School B'];
  final List<String> _classList = [
    'LKG',
    'UKG',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
    '11th',
    '12th',
  ];
  final List<String> _paymentModeList = [
    'Cash',
    'Online',
    'Cheque',
    'Bank Transfer',
    'UPI',
    'Card',
  ];
  final List<String> _expenseTypeList = [
    'Maintenance',
    'Utilities',
    'Staff Salary',
    'Student Activities',
    'Infrastructure',
    'Technology',
    'Transport',
    'Food Services',
    'Sports',
    'Cultural Events',
    'Administrative',
    'Other',
  ];

  final Map<String, int> _classFees = {
    'LKG': 25000,
    'UKG': 28000,
    '1st': 30000,
    '2nd': 32000,
    '3rd': 35000,
    '4th': 38000,
    '5th': 40000,
    '6th': 42000,
    '7th': 45000,
    '8th': 48000,
    '9th': 50000,
    '10th': 55000,
    '11th': 60000,
    '12th': 65000,
  };

  final Map<String, int> _teacherSalaries = {
    'Primary Teacher': 25000,
    'Secondary Teacher': 35000,
    'Senior Secondary Teacher': 45000,
    'Head Teacher': 55000,
    'Assistant Teacher': 20000,
    'Special Educator': 30000,
    'Physical Education Teacher': 28000,
    'Art Teacher': 25000,
    'Music Teacher': 25000,
    'Computer Teacher': 32000,
  };

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _amountController.dispose();
    _paidController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============ SAMPLE DATA ============
  void _loadSampleData() {
    _feeRecords = [
      // ===== School A - Students =====
      {
        'id': 'F001',
        'name': 'Aarav Sharma',
        'fatherName': 'Mr. Rajesh Sharma',
        'motherName': 'Mrs. Sunita Sharma',
        'category': 'Students',
        'class': 'LKG',
        'totalFee': 25000,
        'paid': 25000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-01',
        'paymentMode': 'Online',
        'transactionId': 'TXN123456',
        'school': 'School A',
        'photo': null,
      },
      {
        'id': 'F002',
        'name': 'Ishita Singh',
        'fatherName': 'Mr. Rajesh Singh',
        'motherName': 'Mrs. Kavita Singh',
        'category': 'Students',
        'class': 'LKG',
        'totalFee': 25000,
        'paid': 15000,
        'due': 10000,
        'status': 'Partial',
        'date': '2024-12-05',
        'paymentMode': 'Cash',
        'transactionId': 'TXN789012',
        'school': 'School A',
        'photo': null,
      },
      {
        'id': 'F003',
        'name': 'Arjun Mehta',
        'fatherName': 'Mr. Amit Mehta',
        'motherName': 'Mrs. Priya Mehta',
        'category': 'Students',
        'class': 'UKG',
        'totalFee': 28000,
        'paid': 0,
        'due': 28000,
        'status': 'Pending',
        'date': '2024-12-10',
        'paymentMode': '-',
        'transactionId': '-',
        'school': 'School A',
        'photo': null,
      },
      {
        'id': 'F004',
        'name': 'Kavya Nair',
        'fatherName': 'Mr. Suresh Nair',
        'motherName': 'Mrs. Meena Nair',
        'category': 'Students',
        'class': '1st',
        'totalFee': 30000,
        'paid': 30000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-02',
        'paymentMode': 'UPI',
        'transactionId': 'UPI345678',
        'school': 'School A',
        'photo': null,
      },
      {
        'id': 'F005',
        'name': 'Rohan Verma',
        'fatherName': 'Mr. Sunil Verma',
        'motherName': 'Mrs. Anjali Verma',
        'category': 'Students',
        'class': '2nd',
        'totalFee': 32000,
        'paid': 16000,
        'due': 16000,
        'status': 'Partial',
        'date': '2024-12-08',
        'paymentMode': 'Cheque',
        'transactionId': 'CHQ901234',
        'school': 'School A',
        'photo': null,
      },

      // ===== School A - Teachers =====
      {
        'id': 'F006',
        'name': 'Dr. Priya Sharma',
        'fatherName': 'Science',
        'motherName': 'M.Sc.',
        'category': 'Teachers',
        'class': 'All',
        'designation': 'Head Teacher',
        'totalFee': 55000,
        'paid': 55000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-01',
        'paymentMode': 'Bank Transfer',
        'transactionId': 'BT001',
        'school': 'School A',
        'photo': null,
      },
      {
        'id': 'F007',
        'name': 'Mr. Suresh Kumar',
        'fatherName': 'Mathematics',
        'motherName': 'B.Ed',
        'category': 'Teachers',
        'class': 'All',
        'designation': 'Secondary Teacher',
        'totalFee': 35000,
        'paid': 25000,
        'due': 10000,
        'status': 'Partial',
        'date': '2024-12-05',
        'paymentMode': 'Cash',
        'transactionId': '-',
        'school': 'School A',
        'photo': null,
      },

      // ===== School A - School Fund =====
      {
        'id': 'F008',
        'name': 'Building Maintenance',
        'fatherName': 'School A',
        'motherName': 'Infrastructure',
        'category': 'School Fund',
        'class': 'All',
        'expenseType': 'Maintenance',
        'totalFee': 50000,
        'paid': 50000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-01',
        'paymentMode': 'Bank Transfer',
        'transactionId': 'BTF001',
        'school': 'School A',
        'photo': null,
        'description': 'Annual building maintenance',
      },

      // ===== School B - Students =====
      {
        'id': 'F009',
        'name': 'Priya Patel',
        'fatherName': 'Mr. Sanjay Patel',
        'motherName': 'Mrs. Meena Patel',
        'category': 'Students',
        'class': 'LKG',
        'totalFee': 25000,
        'paid': 25000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-03',
        'paymentMode': 'Online',
        'transactionId': 'TXN567890',
        'school': 'School B',
        'photo': null,
      },
      {
        'id': 'F010',
        'name': 'Anjali Gupta',
        'fatherName': 'Dr. Anil Gupta',
        'motherName': 'Mrs. Kavita Gupta',
        'category': 'Students',
        'class': '3rd',
        'totalFee': 35000,
        'paid': 25000,
        'due': 10000,
        'status': 'Partial',
        'date': '2024-12-09',
        'paymentMode': 'Cash',
        'transactionId': '-',
        'school': 'School B',
        'photo': null,
      },
      {
        'id': 'F011',
        'name': 'Vikram Kumar',
        'fatherName': 'Mr. Suresh Kumar',
        'motherName': 'Mrs. Radha Kumar',
        'category': 'Students',
        'class': '1st',
        'totalFee': 30000,
        'paid': 30000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-04',
        'paymentMode': 'Bank Transfer',
        'transactionId': 'BT111222',
        'school': 'School B',
        'photo': null,
      },

      // ===== School B - Teachers =====
      {
        'id': 'F012',
        'name': 'Dr. Anil Gupta',
        'fatherName': 'Physics',
        'motherName': 'Ph.D.',
        'category': 'Teachers',
        'class': 'All',
        'designation': 'Senior Secondary Teacher',
        'totalFee': 45000,
        'paid': 45000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-02',
        'paymentMode': 'UPI',
        'transactionId': 'UPI002',
        'school': 'School B',
        'photo': null,
      },
      {
        'id': 'F013',
        'name': 'Mrs. Meera Singh',
        'fatherName': 'English',
        'motherName': 'M.A.',
        'category': 'Teachers',
        'class': 'All',
        'designation': 'Primary Teacher',
        'totalFee': 25000,
        'paid': 20000,
        'due': 5000,
        'status': 'Partial',
        'date': '2024-12-06',
        'paymentMode': 'Cash',
        'transactionId': '-',
        'school': 'School B',
        'photo': null,
      },

      // ===== School B - School Fund =====
      {
        'id': 'F014',
        'name': 'Computer Lab Upgrade',
        'fatherName': 'School B',
        'motherName': 'Technology',
        'category': 'School Fund',
        'class': 'All',
        'expenseType': 'Technology',
        'totalFee': 75000,
        'paid': 75000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-03',
        'paymentMode': 'Bank Transfer',
        'transactionId': 'BTF002',
        'school': 'School B',
        'photo': null,
        'description': 'Computer lab upgrade with 20 new systems',
      },
      {
        'id': 'F015',
        'name': 'Sports Equipment',
        'fatherName': 'School B',
        'motherName': 'Sports',
        'category': 'School Fund',
        'class': 'All',
        'expenseType': 'Sports',
        'totalFee': 30000,
        'paid': 15000,
        'due': 15000,
        'status': 'Partial',
        'date': '2024-12-10',
        'paymentMode': 'Cheque',
        'transactionId': 'CHQ003',
        'school': 'School B',
        'photo': null,
        'description': 'Cricket and football equipment',
      },
    ];
  }

  // ============ GETTERS ============
  List<Map<String, dynamic>> get _filteredRecords {
    var filtered = _feeRecords
        .where((record) => record['category'] == _selectedCategory)
        .toList();

    // School Filter - Single filter applied here
    if (_currentSchoolFilter == SchoolFilter.schoolA) {
      filtered = filtered
          .where((record) => record['school'] == 'School A')
          .toList();
    } else if (_currentSchoolFilter == SchoolFilter.schoolB) {
      filtered = filtered
          .where((record) => record['school'] == 'School B')
          .toList();
    }

    // Status Filter
    if (_currentFilter != FeeFilter.all) {
      filtered = filtered.where((record) {
        if (_currentFilter == FeeFilter.paid) return record['status'] == 'Paid';
        if (_currentFilter == FeeFilter.partial)
          return record['status'] == 'Partial';
        if (_currentFilter == FeeFilter.pending)
          return record['status'] == 'Pending';
        return record['status'] == 'Overdue';
      }).toList();
    }

    // Search Filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (record) =>
        record['name'].toLowerCase().contains(
          _searchQuery.toLowerCase(),
        ) ||
            record['id'].toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            record['class'].toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            record['school'].toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
      )
          .toList();
    }

    return filtered;
  }

  int get _totalRecords =>
      _feeRecords.where((r) => r['category'] == _selectedCategory).length;

  int get _paidRecords => _feeRecords
      .where(
        (r) =>
    r['category'] == _selectedCategory &&
        r['status'] == 'Paid' &&
        (_currentSchoolFilter == SchoolFilter.all ||
            r['school'] == _getSchoolFilterValue()),
  )
      .length;

  int get _partialRecords => _feeRecords
      .where(
        (r) =>
    r['category'] == _selectedCategory &&
        r['status'] == 'Partial' &&
        (_currentSchoolFilter == SchoolFilter.all ||
            r['school'] == _getSchoolFilterValue()),
  )
      .length;

  int get _pendingRecords => _feeRecords
      .where(
        (r) =>
    r['category'] == _selectedCategory &&
        r['status'] == 'Pending' &&
        (_currentSchoolFilter == SchoolFilter.all ||
            r['school'] == _getSchoolFilterValue()),
  )
      .length;

  String _getSchoolFilterValue() {
    if (_currentSchoolFilter == SchoolFilter.schoolA) return 'School A';
    if (_currentSchoolFilter == SchoolFilter.schoolB) return 'School B';
    return '';
  }

  Map<String, dynamic> _getStats() {
    final data = _feeRecords
        .where(
          (i) =>
      i['category'] == _selectedCategory &&
          (_currentSchoolFilter == SchoolFilter.all ||
              i['school'] == _getSchoolFilterValue()),
    )
        .toList();
    int total = 0, paid = 0, due = 0;
    for (var item in data) {
      total += item['totalFee'] as int;
      paid += item['paid'] as int;
      due += item['due'] as int;
    }
    return {'count': data.length, 'total': total, 'paid': paid, 'due': due};
  }

  Map<String, int> _getSchoolWiseStats() {
    Map<String, int> stats = {};
    final data = _feeRecords
        .where((i) => i['category'] == _selectedCategory)
        .toList();
    for (var record in data) {
      final school = record['school'] ?? 'Unknown';
      stats[school] = (stats[school] ?? 0) + 1;
    }
    return stats;
  }

  // ============ FORM METHODS ============
  void _resetForm() {
    _nameController.clear();
    _fatherNameController.clear();
    _motherNameController.clear();
    _amountController.clear();
    _paidController.clear();
    _dateController.clear();
    _descriptionController.clear();
    _selectedClassForm = 'LKG';
    _selectedPaymentMode = 'Cash';
    _selectedCategoryForm = _selectedCategory;
    _selectedExpenseType = 'Maintenance';
    _selectedSchoolForm = 'School A';
    _imageFile = null;
  }

  void _loadRecordToForm(Map<String, dynamic> record) {
    _nameController.text = record['name'] ?? '';
    _fatherNameController.text = record['fatherName'] ?? '';
    _motherNameController.text = record['motherName'] ?? '';
    _amountController.text = record['totalFee'].toString();
    _paidController.text = record['paid'].toString();
    _dateController.text = record['date'] ?? '';
    _descriptionController.text = record['description'] ?? '';
    _selectedCategoryForm = record['category'] ?? 'Students';
    _selectedClassForm = record['class'] != 'All' ? record['class'] : 'LKG';
    _selectedPaymentMode = record['paymentMode'] != '-'
        ? record['paymentMode']
        : 'Cash';
    _selectedExpenseType = record['expenseType'] ?? 'Maintenance';
    _selectedSchoolForm = record['school'] ?? 'School A';
    _imageFile = record['photo'] != null ? File(record['photo']) : null;
  }

  Map<String, dynamic> _createRecordFromForm(String id) {
    final totalFee = int.parse(
      _amountController.text.trim().isEmpty
          ? '0'
          : _amountController.text.trim(),
    );
    final paid = int.parse(
      _paidController.text.trim().isEmpty ? '0' : _paidController.text.trim(),
    );
    final due = totalFee - paid;
    String status = 'Pending';
    if (due == 0)
      status = 'Paid';
    else if (paid > 0 && due > 0)
      status = 'Partial';
    else if (due < 0)
      status = 'Overdue';

    return {
      'id': id,
      'name': _nameController.text.trim(),
      'fatherName': _fatherNameController.text.trim(),
      'motherName': _motherNameController.text.trim(),
      'category': _selectedCategoryForm,
      'class': _selectedCategoryForm == 'Students' ? _selectedClassForm : 'All',
      'totalFee': totalFee,
      'paid': paid,
      'due': due,
      'status': status,
      'date': _dateController.text.trim().isNotEmpty
          ? _dateController.text.trim()
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'paymentMode': paid > 0 ? _selectedPaymentMode : '-',
      'transactionId': paid > 0
          ? 'TXN${DateTime.now().millisecondsSinceEpoch}'
          : '-',
      'school': _selectedSchoolForm,
      'photo': _imageFile?.path,
      'designation': _selectedCategoryForm == 'Teachers'
          ? _selectedClassForm
          : null,
      'expenseType': _selectedCategoryForm == 'School Fund'
          ? _selectedExpenseType
          : null,
      'description': _descriptionController.text.trim(),
    };
  }

  // ============ CRUD OPERATIONS ============
  void _addRecord() {
    if (!_formKey.currentState!.validate()) return;
    if (_amountController.text.trim().isEmpty) {
      _showSnackbar('Please enter the amount', Colors.orange);
      return;
    }

    final newRecord = _createRecordFromForm(
      'F${(_feeRecords.length + 1).toString().padLeft(3, '0')}',
    );

    setState(() {
      _feeRecords.add(newRecord);
      _showRightPanel = false;
      _isAddingNew = false;
      _resetForm();
    });

    _showSnackbar('Record added successfully!', Colors.green);
  }

  void _updateRecord() {
    if (!_formKey.currentState!.validate()) return;
    if (_amountController.text.trim().isEmpty) {
      _showSnackbar('Please enter the amount', Colors.orange);
      return;
    }

    final updatedRecord = _createRecordFromForm(_selectedRecord!['id']);
    final index = _feeRecords.indexWhere(
          (r) => r['id'] == _selectedRecord!['id'],
    );

    if (index != -1) {
      setState(() {
        _feeRecords[index] = updatedRecord;
        _selectedRecord = updatedRecord;
        _isEditing = false;
        _resetForm();
      });
      _showSnackbar('Record updated successfully!', Colors.blue);
    }
  }

  void _deleteRecord(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete ${record['name']}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _feeRecords.removeWhere((r) => r['id'] == record['id']);
                if (_selectedRecord?['id'] == record['id']) {
                  _showRightPanel = false;
                  _selectedRecord = null;
                }
              });
              _showSnackbar('Record deleted successfully!', Colors.red);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ============ IMAGE PICKER USING FILE_PICKER ============
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Check if file size is reasonable (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          _showSnackbar('Image size too large. Please select an image under 5MB.', Colors.orange);
          return;
        }
        String? filePath = file.path;
        if (filePath != null) {
          setState(() {
            _imageFile = File(filePath);
          });
          _showSnackbar('Image uploaded successfully!', Colors.green);
        } else {
          _showSnackbar('Failed to get image file path', Colors.red);
        }
      }
    } catch (e) {
      _showSnackbar('Error picking image: ${e.toString()}', Colors.red);
    }
  }

  // ============ HELPERS ============
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Partial':
        return Colors.orange;
      case 'Pending':
        return Colors.red;
      case 'Overdue':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Students':
        return Colors.blue;
      case 'Teachers':
        return Colors.orange;
      case 'School Fund':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getSchoolColor(String school) {
    switch (school) {
      case 'School A':
        return Colors.blue;
      case 'School B':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Students':
        return '🎓';
      case 'Teachers':
        return '👨‍🏫';
      case 'School Fund':
        return '🏦';
      default:
        return '📊';
    }
  }

  String _formatCurrency(int amount) {
    return '₹${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    final stats = _getStats();
    final schoolStats = _getSchoolWiseStats();

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Panel - Record List
            Expanded(
              flex: _showRightPanel ? 5 : 8,
              child: Column(
                children: [
                  _buildHeader(stats, schoolStats),
                  _buildFilterSearchBar(),
                  Expanded(
                    child: _filteredRecords.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        return _buildRecordCard(_filteredRecords[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Right Panel
            Container(
              width: 480,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  left: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: _showRightPanel
                  ? (_isAddingNew
                  ? _buildAddPanel()
                  : _isEditing
                  ? _buildEditPanel()
                  : _buildViewPanel())
                  : _buildEmptyRightPanel(stats),
            ),
          ],
        ),
      ),
    );
  }

  // ============ EMPTY RIGHT PANEL ============
  Widget _buildEmptyRightPanel(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _getCategoryColor(_selectedCategory).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                _getCategoryIcon(_selectedCategory),
                style: const TextStyle(fontSize: 60),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Record Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a record from the list or create a new one',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              '💰 ${_formatCurrency(stats['total'])} Total Amount',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEmptyStatCard(
                  icon: Icons.check_circle,
                  label: 'Paid',
                  count: _paidRecords,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.pending,
                  label: 'Partial',
                  count: _partialRecords,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildEmptyStatCard(
                  icon: Icons.warning,
                  label: 'Pending',
                  count: _pendingRecords,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _resetForm();
                setState(() {
                  _isAddingNew = true;
                  _isEditing = false;
                  _selectedRecord = null;
                  _showRightPanel = true;
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ============ HEADER ============
  Widget _buildHeader(
      Map<String, dynamic> stats,
      Map<String, int> schoolStats,
      ) {
    final schoolFilterLabel = _currentSchoolFilter == SchoolFilter.all
        ? 'All Schools'
        : _currentSchoolFilter == SchoolFilter.schoolA
        ? 'School A'
        : 'School B';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
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
                  color: _getCategoryColor(_selectedCategory).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getCategoryIcon(_selectedCategory),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedCategory Management',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${_filteredRecords.length} records found',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 14,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatCurrency(stats['paid']),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pending, size: 14, color: Colors.red[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatCurrency(stats['due']),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!_showRightPanel || !_isAddingNew)
                ElevatedButton.icon(
                  onPressed: () {
                    _resetForm();
                    setState(() {
                      _isAddingNew = true;
                      _isEditing = false;
                      _selectedRecord = null;
                      _showRightPanel = true;
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              if (_showRightPanel)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedRecord = null;
                      _isEditing = false;
                      _isAddingNew = false;
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ FILTER AND SEARCH ============
  Widget _buildFilterSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Column(
        spacing: 10,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SchoolFilter>(
                    value: _currentSchoolFilter,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    items: [
                      const DropdownMenuItem(
                        value: SchoolFilter.all,
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Text('All Schools'),
                          ],
                        ),
                      ),
                      const DropdownMenuItem(
                        value: SchoolFilter.schoolA,
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 16, color: Colors.blue),
                            SizedBox(width: 6),
                            Text('School A'),
                          ],
                        ),
                      ),
                      const DropdownMenuItem(
                        value: SchoolFilter.schoolB,
                        child: Row(
                          children: [
                            Icon(Icons.school, size: 16, color: Colors.green),
                            SizedBox(width: 6),
                            Text('School B'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _currentSchoolFilter = value!;
                        _selectedRecord = null;
                        _showRightPanel = false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Category Dropdown
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    icon: Icon(Icons.category, color: Colors.grey[600], size: 18),
                    items: _categoryList.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Text(_getCategoryIcon(category)),
                            const SizedBox(width: 4),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                        _searchQuery = '';
                        _currentFilter = FeeFilter.all;
                        _selectedRecord = null;
                        _showRightPanel = false;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Search
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search records...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

            ],
          ),

          Row(
            children: [
              _buildFilterChip('All', FeeFilter.all),
              const SizedBox(width: 4),
              _buildFilterChip('Paid', FeeFilter.paid),
              const SizedBox(width: 4),
              _buildFilterChip('Partial', FeeFilter.partial),
              const SizedBox(width: 4),
              _buildFilterChip('Pending', FeeFilter.pending),
              const SizedBox(width: 4),
              _buildFilterChip('Overdue', FeeFilter.overdue),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, FeeFilter filter) {
    final isSelected = _currentFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _getStatusColor(label) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _getStatusColor(label) : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // ============ RECORD CARD ============
  Widget _buildRecordCard(Map<String, dynamic> record) {
    final isSelected = _selectedRecord?['id'] == record['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(record['category']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getCategoryIcon(record['category']),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedRecord = record;
                  _showRightPanel = true;
                  _isEditing = false;
                  _isAddingNew = false;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            record['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          record['status'],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(record['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      _buildInfoText(Icons.school, record['school']),
                      _buildInfoText(Icons.class_, record['class']),
                      _buildInfoText(
                        Icons.attach_money,
                        _formatCurrency(record['totalFee']),
                      ),
                      if (record['due'] > 0)
                        _buildInfoText(
                          Icons.pending,
                          'Due: ${_formatCurrency(record['due'])}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {
                    _loadRecordToForm(record);
                    setState(() {
                      _selectedRecord = record;
                      _isEditing = true;
                      _isAddingNew = false;
                      _showRightPanel = true;
                    });
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.blue[700],
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () => _deleteRecord(record),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red[400],
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ============ EMPTY STATE ============
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No Records Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _resetForm();
              setState(() {
                _isAddingNew = true;
                _isEditing = false;
                _selectedRecord = null;
                _showRightPanel = true;
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ============ VIEW PANEL ============
  Widget _buildViewPanel() {
    if (_selectedRecord == null) return const SizedBox();

    final record = _selectedRecord!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(record['category']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getCategoryIcon(record['category']),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getSchoolColor(
                              record['school'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getSchoolColor(
                                record['school'],
                              ).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.school,
                                size: 12,
                                color: _getSchoolColor(record['school']),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                record['school'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getSchoolColor(record['school']),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              record['status'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            record['status'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(record['status']),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            record['id'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Payment Info
          _buildDetailRow(
            '🏫 School',
            record['school'],
            color: _getSchoolColor(record['school']),
            isBold: true,
          ),
          _buildDetailRow(
            '💰 Total Fee',
            _formatCurrency(record['totalFee']),
            isBold: true,
          ),
          _buildDetailRow(
            '✅ Paid',
            _formatCurrency(record['paid']),
            color: Colors.green,
          ),
          _buildDetailRow(
            '📌 Due',
            _formatCurrency(record['due']),
            color: Colors.red,
            isBold: true,
          ),
          _buildDetailRow(
            '📊 Status',
            record['status'],
            color: _getStatusColor(record['status']),
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // Personal Info
          _buildDetailRow('📛 Name', record['name']),
          _buildDetailRow('📚 Category', record['category']),
          _buildDetailRow('🏫 Class', record['class']),

          if (record['category'] == 'Students') ...[
            _buildDetailRow('👨 Father', record['fatherName'] ?? 'N/A'),
            _buildDetailRow('👩 Mother', record['motherName'] ?? 'N/A'),
          ],
          if (record['category'] == 'Teachers') ...[
            _buildDetailRow('📌 Designation', record['designation'] ?? 'N/A'),
            _buildDetailRow('📚 Department', record['fatherName'] ?? 'N/A'),
          ],
          if (record['category'] == 'School Fund') ...[
            _buildDetailRow('📋 Expense Type', record['expenseType'] ?? 'N/A'),
            if (record['description'] != null &&
                record['description']!.isNotEmpty)
              _buildDetailRow('📝 Description', record['description']),
          ],

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          _buildDetailRow('💳 Payment Mode', record['paymentMode']),
          _buildDetailRow('📅 Date', record['date'] ?? 'N/A'),
          if (record['transactionId'] != '-')
            _buildDetailRow('🆔 Transaction ID', record['transactionId']),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _selectedRecord = null;
                    });
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _loadRecordToForm(record);
                    setState(() {
                      _isEditing = true;
                      _isAddingNew = false;
                    });
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteRecord(record),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label,
      String value, {
        Color? color,
        bool isBold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: color ?? Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ ADD PANEL ============
  Widget _buildAddPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Add New ${_selectedCategoryForm}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormFields(isAdding: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showRightPanel = false;
                      _isAddingNew = false;
                      _resetForm();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Record',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ EDIT PANEL ============
  Widget _buildEditPanel() {
    if (_selectedRecord == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Edit ${_selectedRecord!['category']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormFields(isAdding: false),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ FORM FIELDS ============
  Widget _buildFormFields({required bool isAdding}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Upload
        Align(alignment: Alignment.center, child: _buildPhotoUpload()),
        const SizedBox(height: 16),

        // School Selection
        _buildDropdownField('School', _selectedSchoolForm, _schoolList, (
            value,
            ) {
          setState(() {
            _selectedSchoolForm = value!;
          });
        }),
        const SizedBox(height: 8),

        // Name
        _buildFormTextField(
          _nameController,
          'Name',
          Icons.person_outline,
          required: true,
        ),
        const SizedBox(height: 8),

        if (_selectedCategoryForm != 'School Fund') ...[
          _buildFormTextField(
            _fatherNameController,
            'Father Name',
            Icons.person_outline,
            required: true,
          ),
          const SizedBox(height: 8),
          _buildFormTextField(
            _motherNameController,
            'Mother Name',
            Icons.person_outline,
            required: true,
          ),
          const SizedBox(height: 8),
        ],

        // Category Dropdown
        _buildDropdownField('Category', _selectedCategoryForm, _categoryList, (
            value,
            ) {
          setState(() {
            _selectedCategoryForm = value!;
            _amountController.clear();
            _paidController.clear();
          });
        }),
        const SizedBox(height: 8),

        // Class/Designation based on category
        if (_selectedCategoryForm == 'Students')
          _buildDropdownField('Class', _selectedClassForm, _classList, (value) {
            setState(() {
              _selectedClassForm = value!;
              _amountController.text = _classFees[_selectedClassForm]
                  .toString();
            });
          }),
        if (_selectedCategoryForm == 'Teachers')
          _buildDropdownField(
            'Designation',
            _selectedClassForm,
            _teacherSalaries.keys.toList(),
                (value) {
              setState(() {
                _selectedClassForm = value!;
                _amountController.text = _teacherSalaries[_selectedClassForm]
                    .toString();
              });
            },
          ),
        if (_selectedCategoryForm == 'School Fund')
          _buildDropdownField(
            'Expense Type',
            _selectedExpenseType,
            _expenseTypeList,
                (value) {
              setState(() => _selectedExpenseType = value!);
            },
          ),
        const SizedBox(height: 8),

        // Amount Fields
        _buildFormTextField(
          _amountController,
          'Total Amount',
          Icons.attach_money,
          required: true,
          enabled:
          _selectedCategoryForm != 'Students' &&
              _selectedCategoryForm != 'Teachers',
        ),
        const SizedBox(height: 8),
        _buildFormTextField(
          _paidController,
          'Paid Amount',
          Icons.check_circle,
          required: true,
        ),
        const SizedBox(height: 8),

        // Payment Mode
        _buildDropdownField(
          'Payment Mode',
          _selectedPaymentMode,
          _paymentModeList,
              (value) {
            setState(() => _selectedPaymentMode = value!);
          },
        ),
        const SizedBox(height: 8),

        // Date
        _buildFormTextField(
          _dateController,
          'Date',
          Icons.calendar_today,
          hint: 'YYYY-MM-DD',
          required: true,
        ),
        const SizedBox(height: 8),

        if (_selectedCategoryForm == 'School Fund')
          _buildFormTextField(
            _descriptionController,
            'Description',
            Icons.description,
            maxLines: 2,
          ),
      ],
    );
  }

  Widget _buildFormTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        String? hint,
        int maxLines = 1,
        bool required = false,
        bool enabled = true,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      validator: required
          ? (v) => v?.trim().isEmpty ?? true ? '$label is required' : null
          : null,
    );
  }

  Widget _buildDropdownField(
      String label,
      String value,
      List<String> items,
      Function(String?) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 13)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_imageFile!, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.blue[700], size: 24),
            const SizedBox(height: 2),
            Text(
              'Upload Photo',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}