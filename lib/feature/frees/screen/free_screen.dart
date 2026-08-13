import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class FeeScreen extends StatefulWidget {
  const FeeScreen({super.key});

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  // ============ STATE ============
  String searchQuery = '';
  String selectedSchool = 'School A';
  String selectedCategory = 'Students';
  String selectedClass = 'All';
  String selectedStatus = 'All';
  Map<String, dynamic>? selectedItem;
  bool _isAdding = false;
  bool _isLoading = false;
  int _currentPage = 0;
  final int _itemsPerPage = 8;
  File? _imageFile;
  String _selectedView = 'list';
  int _selectedTabIndex = 0;

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
  String _selectedSchoolForm = 'School A';
  String _selectedCategoryForm = 'Students';
  String _selectedExpenseType = 'Maintenance';

  // ============ CONSTANTS ============
  final List<String> _schoolList = ['School A', 'School B'];
  final List<String> _categoryList = ['Students', 'Teachers', 'School Fund'];
  final List<String> _classList = [
    'All', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th', '5th',
    '6th', '7th', '8th', '9th', '10th', '11th', '12th'
  ];
  final List<String> _statusList = ['All', 'Paid', 'Partial', 'Pending', 'Overdue'];
  final List<String> _paymentModeList = ['Cash', 'Online', 'Cheque', 'Bank Transfer', 'UPI', 'Card'];
  final List<String> _expenseTypeList = [
    'Maintenance', 'Utilities', 'Staff Salary', 'Student Activities',
    'Infrastructure', 'Technology', 'Transport', 'Food Services',
    'Sports', 'Cultural Events', 'Administrative', 'Other'
  ];

  // ============ CLASS FEE STRUCTURE ============
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

  // ============ SCHOOL DATA ============
  List<Map<String, dynamic>> _schoolAData = [];
  List<Map<String, dynamic>> _schoolBData = [];

  List<Map<String, dynamic>> get _currentData {
    return selectedSchool == 'School A' ? _schoolAData : _schoolBData;
  }

  // ============ INIT DATA ============
  void _initData() {
    _schoolAData = [
      // Students
      {
        'id': 'SA-STU001',
        'name': 'Aarav Sharma',
        'fatherName': 'Mr. Rajesh Sharma',
        'motherName': 'Mrs. Sunita Sharma',
        'school': 'School A',
        'category': 'Students',
        'class': 'LKG',
        'totalFee': 25000,
        'paid': 25000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-01',
        'paymentMode': 'Online',
        'transactionId': 'TXN123456',
        'color': '#4CAF50',
        'photo': null,
      },
      {
        'id': 'SA-STU002',
        'name': 'Ishita Singh',
        'fatherName': 'Mr. Rajesh Singh',
        'motherName': 'Mrs. Kavita Singh',
        'school': 'School A',
        'category': 'Students',
        'class': 'LKG',
        'totalFee': 25000,
        'paid': 15000,
        'due': 10000,
        'status': 'Partial',
        'date': '2024-12-05',
        'paymentMode': 'Cash',
        'transactionId': 'TXN789012',
        'color': '#FF9800',
        'photo': null,
      },
      {
        'id': 'SA-STU003',
        'name': 'Arjun Mehta',
        'fatherName': 'Mr. Amit Mehta',
        'motherName': 'Mrs. Priya Mehta',
        'school': 'School A',
        'category': 'Students',
        'class': 'UKG',
        'totalFee': 28000,
        'paid': 0,
        'due': 28000,
        'status': 'Pending',
        'date': '2024-12-10',
        'paymentMode': '-',
        'transactionId': '-',
        'color': '#F44336',
        'photo': null,
      },
      {
        'id': 'SA-STU004',
        'name': 'Kavya Nair',
        'fatherName': 'Mr. Suresh Nair',
        'motherName': 'Mrs. Meena Nair',
        'school': 'School A',
        'category': 'Students',
        'class': '1st',
        'totalFee': 30000,
        'paid': 30000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-02',
        'paymentMode': 'UPI',
        'transactionId': 'UPI345678',
        'color': '#4CAF50',
        'photo': null,
      },
      {
        'id': 'SA-STU005',
        'name': 'Rohan Verma',
        'fatherName': 'Mr. Sunil Verma',
        'motherName': 'Mrs. Anjali Verma',
        'school': 'School A',
        'category': 'Students',
        'class': '2nd',
        'totalFee': 32000,
        'paid': 16000,
        'due': 16000,
        'status': 'Partial',
        'date': '2024-12-08',
        'paymentMode': 'Cheque',
        'transactionId': 'CHQ901234',
        'color': '#FF9800',
        'photo': null,
      },
      // Teachers
      {
        'id': 'SA-TCH001',
        'name': 'Dr. Priya Sharma',
        'fatherName': 'Science',
        'motherName': 'M.Sc.',
        'school': 'School A',
        'category': 'Teachers',
        'designation': 'Head Teacher',
        'class': 'All',
        'totalFee': 55000,
        'paid': 55000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-01',
        'paymentMode': 'Bank Transfer',
        'transactionId': 'BT001',
        'color': '#2196F3',
        'photo': null,
      },
      {
        'id': 'SA-TCH002',
        'name': 'Mr. Suresh Kumar',
        'fatherName': 'Mathematics',
        'motherName': 'B.Ed',
        'school': 'School A',
        'category': 'Teachers',
        'designation': 'Secondary Teacher',
        'class': 'All',
        'totalFee': 35000,
        'paid': 25000,
        'due': 10000,
        'status': 'Partial',
        'date': '2024-12-05',
        'paymentMode': 'Cash',
        'transactionId': '-',
        'color': '#FF9800',
        'photo': null,
      },
      // School Fund
      {
        'id': 'SA-FND001',
        'name': 'Building Maintenance',
        'fatherName': 'School A',
        'motherName': 'Infrastructure',
        'school': 'School A',
        'category': 'School Fund',
        'expenseType': 'Maintenance',
        'class': 'All',
        'totalFee': 50000,
        'paid': 50000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-01',
        'paymentMode': 'Bank Transfer',
        'transactionId': 'BTF001',
        'color': '#9C27B0',
        'photo': null,
        'description': 'Annual building maintenance',
      },
    ];

    _schoolBData = [
      // Students
      {
        'id': 'SB-STU001',
        'name': 'Priya Patel',
        'fatherName': 'Mr. Sanjay Patel',
        'motherName': 'Mrs. Meena Patel',
        'school': 'School B',
        'category': 'Students',
        'class': 'LKG',
        'totalFee': 25000,
        'paid': 25000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-03',
        'paymentMode': 'Online',
        'transactionId': 'TXN567890',
        'color': '#4CAF50',
        'photo': null,
      },
      {
        'id': 'SB-STU002',
        'name': 'Vikram Kumar',
        'fatherName': 'Mr. Suresh Kumar',
        'motherName': 'Mrs. Radha Kumar',
        'school': 'School B',
        'category': 'Students',
        'class': '1st',
        'totalFee': 30000,
        'paid': 30000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-04',
        'paymentMode': 'Bank Transfer',
        'transactionId': 'BT111222',
        'color': '#4CAF50',
        'photo': null,
      },
      {
        'id': 'SB-STU003',
        'name': 'Anjali Gupta',
        'fatherName': 'Dr. Anil Gupta',
        'motherName': 'Mrs. Kavita Gupta',
        'school': 'School B',
        'category': 'Students',
        'class': '3rd',
        'totalFee': 35000,
        'paid': 25000,
        'due': 10000,
        'status': 'Partial',
        'date': '2024-12-09',
        'paymentMode': 'Cash',
        'transactionId': '-',
        'color': '#FF9800',
        'photo': null,
      },
      // Teachers
      {
        'id': 'SB-TCH001',
        'name': 'Dr. Anil Gupta',
        'fatherName': 'Physics',
        'motherName': 'Ph.D.',
        'school': 'School B',
        'category': 'Teachers',
        'designation': 'Senior Secondary Teacher',
        'class': 'All',
        'totalFee': 45000,
        'paid': 45000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-02',
        'paymentMode': 'UPI',
        'transactionId': 'UPI002',
        'color': '#2196F3',
        'photo': null,
      },
      // School Fund
      {
        'id': 'SB-FND001',
        'name': 'Computer Lab Upgrade',
        'fatherName': 'School B',
        'motherName': 'Technology',
        'school': 'School B',
        'category': 'School Fund',
        'expenseType': 'Technology',
        'class': 'All',
        'totalFee': 75000,
        'paid': 75000,
        'due': 0,
        'status': 'Paid',
        'date': '2024-12-03',
        'paymentMode': 'Bank Transfer',
        'transactionId': 'BTF002',
        'color': '#9C27B0',
        'photo': null,
        'description': 'Computer lab upgrade',
      },
    ];
  }

  // ============ GETTERS ============
  List<Map<String, dynamic>> get _filteredItems {
    final data = _currentData;
    return data.where((item) {
      final search = searchQuery.toLowerCase();
      final matchesSearch = item['name'].toLowerCase().contains(search) ||
          item['id'].toLowerCase().contains(search);
      final matchesCategory = item['category'] == selectedCategory;
      final matchesClass = selectedClass == 'All' || item['class'] == selectedClass;
      final matchesStatus = selectedStatus == 'All' || item['status'] == selectedStatus;
      return matchesSearch && matchesCategory && matchesClass && matchesStatus;
    }).toList();
  }

  List<Map<String, dynamic>> get _paginatedItems {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage) > _filteredItems.length
        ? _filteredItems.length
        : start + _itemsPerPage;
    return _filteredItems.sublist(start, end);
  }

  int get _totalPages => _filteredItems.isEmpty ? 1 : (_filteredItems.length / _itemsPerPage).ceil();

  // ============ STATS ============
  Map<String, dynamic> _getStats() {
    final data = _currentData.where((i) => i['category'] == selectedCategory).toList();
    int total = 0, paid = 0, due = 0;
    for (var item in data) {
      total += item['totalFee'] as int;
      paid += item['paid'] as int;
      due += item['due'] as int;
    }
    return {
      'count': data.length,
      'total': total,
      'paid': paid,
      'due': due,
      'paidCount': data.where((i) => i['status'] == 'Paid').length,
      'partialCount': data.where((i) => i['status'] == 'Partial').length,
      'pendingCount': data.where((i) => i['status'] == 'Pending' || i['status'] == 'Overdue').length,
    };
  }

  Map<String, int> _getClassWiseStats() {
    final data = _currentData.where((i) => i['category'] == 'Students').toList();
    Map<String, int> stats = {};
    for (var cls in _classList.where((c) => c != 'All')) {
      final count = data.where((s) => s['class'] == cls).length;
      if (count > 0) stats[cls] = count;
    }
    return stats;
  }

  // ============ LIFECYCLE ============
  @override
  void initState() {
    super.initState();
    _initData();
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

  // ============ CRUD ============
  void _clearForm() {
    _nameController.clear();
    _fatherNameController.clear();
    _motherNameController.clear();
    _amountController.clear();
    _paidController.clear();
    _dateController.clear();
    _descriptionController.clear();
    _selectedClassForm = 'LKG';
    _selectedPaymentMode = 'Cash';
    _selectedSchoolForm = selectedSchool;
    _selectedCategoryForm = selectedCategory;
    _selectedExpenseType = 'Maintenance';
    _imageFile = null;
    _formKey.currentState?.reset();
  }

  void _addItem() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        int totalFee = 0;
        if (_selectedCategoryForm == 'Students') {
          totalFee = _classFees[_selectedClassForm] ?? 0;
        } else if (_selectedCategoryForm == 'Teachers') {
          totalFee = int.parse(_amountController.text.trim() == '' ? '0' : _amountController.text.trim());
        } else {
          totalFee = int.parse(_amountController.text.trim() == '' ? '0' : _amountController.text.trim());
        }

        final paid = int.parse(_paidController.text.trim() == '' ? '0' : _paidController.text.trim());
        final due = totalFee - paid;
        String status = 'Pending';
        if (due == 0) status = 'Paid';
        else if (paid > 0 && due > 0) status = 'Partial';

        final prefix = _selectedSchoolForm == 'School A' ? 'SA' : 'SB';
        final catPrefix = _selectedCategoryForm == 'Students' ? 'STU' :
        _selectedCategoryForm == 'Teachers' ? 'TCH' : 'FND';
        final data = _selectedSchoolForm == 'School A' ? _schoolAData : _schoolBData;
        final count = data.where((i) => i['id'].startsWith('$prefix-$catPrefix')).length;

        final newItem = {
          'id': '$prefix-$catPrefix${(count + 1).toString().padLeft(3, '0')}',
          'name': _nameController.text.trim(),
          'fatherName': _fatherNameController.text.trim(),
          'motherName': _motherNameController.text.trim(),
          'school': _selectedSchoolForm,
          'category': _selectedCategoryForm,
          'class': _selectedCategoryForm == 'Students' ? _selectedClassForm : 'All',
          'totalFee': totalFee,
          'paid': paid,
          'due': due,
          'status': status,
          'date': _dateController.text.trim().isNotEmpty ? _dateController.text.trim() : DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'paymentMode': paid > 0 ? _selectedPaymentMode : '-',
          'transactionId': paid > 0 ? 'TXN${DateTime.now().millisecondsSinceEpoch}' : '-',
          'color': '#${(data.length % 8 + 1).toString().padLeft(6, '0')}',
          'photo': _imageFile?.path,
          'designation': _selectedCategoryForm == 'Teachers' ? _selectedClassForm : null,
          'expenseType': _selectedCategoryForm == 'School Fund' ? _selectedExpenseType : null,
          'description': _descriptionController.text.trim(),
        };

        if (_selectedSchoolForm == 'School A') {
          _schoolAData.insert(0, newItem);
        } else {
          _schoolBData.insert(0, newItem);
        }

        _isAdding = false;
        _clearForm();
        _isLoading = false;
        _showSnackbar('Record added successfully!', Colors.green);
      });
    });
  }

  void _updateItem(Map<String, dynamic> item) {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        int totalFee = item['totalFee'];
        if (_selectedCategoryForm == 'Students') {
          totalFee = _classFees[_selectedClassForm] ?? item['totalFee'];
        } else {
          final amount = int.parse(_amountController.text.trim() == '' ? '0' : _amountController.text.trim());
          totalFee = amount > 0 ? amount : item['totalFee'];
        }

        final paid = int.parse(_paidController.text.trim() == '' ? item['paid'].toString() : _paidController.text.trim());
        final due = totalFee - paid;
        String status = 'Pending';
        if (due == 0) status = 'Paid';
        else if (paid > 0 && due > 0) status = 'Partial';

        final updatedItem = {
          ...item,
          'name': _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : item['name'],
          'fatherName': _fatherNameController.text.trim().isNotEmpty ? _fatherNameController.text.trim() : item['fatherName'],
          'motherName': _motherNameController.text.trim().isNotEmpty ? _motherNameController.text.trim() : item['motherName'],
          'class': _selectedCategoryForm == 'Students' ? _selectedClassForm : 'All',
          'totalFee': totalFee,
          'paid': paid,
          'due': due,
          'status': status,
          'date': _dateController.text.trim().isNotEmpty ? _dateController.text.trim() : item['date'],
          'paymentMode': paid > 0 ? _selectedPaymentMode : '-',
          'photo': _imageFile?.path ?? item['photo'],
          'designation': _selectedCategoryForm == 'Teachers' ? _selectedClassForm : item['designation'],
          'expenseType': _selectedCategoryForm == 'School Fund' ? _selectedExpenseType : item['expenseType'],
          'description': _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : item['description'],
        };

        if (selectedSchool == 'School A') {
          final index = _schoolAData.indexWhere((i) => i['id'] == item['id']);
          if (index != -1) _schoolAData[index] = updatedItem;
        } else {
          final index = _schoolBData.indexWhere((i) => i['id'] == item['id']);
          if (index != -1) _schoolBData[index] = updatedItem;
        }

        _isAdding = false;
        _clearForm();
        _isLoading = false;
        _showSnackbar('Record updated successfully!', Colors.blue);
      });
    });
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete ${item['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (selectedSchool == 'School A') {
                  _schoolAData.removeWhere((i) => i['id'] == item['id']);
                } else {
                  _schoolBData.removeWhere((i) => i['id'] == item['id']);
                }
                selectedItem = null;
                _showSnackbar('Record deleted!', Colors.red);
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editItem(Map<String, dynamic> item) {
    _nameController.text = item['name'];
    _fatherNameController.text = item['fatherName'] ?? '';
    _motherNameController.text = item['motherName'] ?? '';
    _selectedSchoolForm = item['school'];
    _selectedCategoryForm = item['category'];
    _selectedClassForm = item['class'] != 'All' ? item['class'] : 'LKG';
    _amountController.text = item['totalFee'].toString();
    _paidController.text = item['paid'].toString();
    _dateController.text = item['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedPaymentMode = item['paymentMode'] != '-' ? item['paymentMode'] : 'Cash';
    _selectedExpenseType = item['expenseType'] ?? 'Maintenance';
    _descriptionController.text = item['description'] ?? '';
    _imageFile = item['photo'] != null ? File(item['photo']) : null;
    setState(() {
      _isAdding = true;
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid': return const Color(0xFF10B981);
      case 'Partial': return const Color(0xFFF59E0B);
      case 'Pending': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Paid': return Icons.check_circle;
      case 'Partial': return Icons.pending;
      case 'Pending': return Icons.warning;
      default: return Icons.help;
    }
  }

  String _formatCurrency(int amount) {
    return '₹${amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Students': return const Color(0xFF3B82F6);
      case 'Teachers': return const Color(0xFFF59E0B);
      case 'School Fund': return const Color(0xFF8B5CF6);
      default: return Colors.grey;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Students': return '🎓';
      case 'Teachers': return '👨‍🏫';
      case 'School Fund': return '🏦';
      default: return '📊';
    }
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    final stats = _getStats();
    final classStats = _getClassWiseStats();
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: isMobile
            ? _buildMobileLayout(stats, classStats)
            : _buildDesktopLayout(stats, classStats),
      ),
    );
  }

  // ============ DESKTOP LAYOUT ============
  Widget _buildDesktopLayout(Map<String, dynamic> stats, Map<String, int> classStats) {
    return Row(
      children: [
        // Left Sidebar
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildSidebar(),
        ),
        const SizedBox(width: 16),

        // Main Content
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildDashboardHeader(),
              const SizedBox(height: 16),
              _buildStatsGrid(stats),
              const SizedBox(height: 16),
              _buildFilterBar(classStats),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildContent(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Right Panel - Details
        Container(
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isAdding
              ? _buildForm()
              : selectedItem != null
              ? _buildDetailsPanel(selectedItem!)
              : _buildEmptyDetails(),
        ),
      ],
    );
  }

  // ============ MOBILE LAYOUT ============
  Widget _buildMobileLayout(Map<String, dynamic> stats, Map<String, int> classStats) {
    return Column(
      children: [
        _buildMobileHeader(),
        const SizedBox(height: 12),
        _buildStatsGrid(stats),
        const SizedBox(height: 12),
        _buildFilterBar(classStats),
        const SizedBox(height: 12),
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : _buildContent(),
        ),
        if (selectedItem != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected: ${selectedItem!['name']}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  onPressed: () => _showMobileDetails(),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showMobileDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: _buildDetailsPanel(selectedItem!),
          );
        },
      ),
    );
  }

  // ============ SIDEBAR ============
  Widget _buildSidebar() {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.dashboard, 'label': 'Dashboard'},
      {'icon': Icons.people, 'label': 'Students'},
      {'icon': Icons.school, 'label': 'Teachers'},
      {'icon': Icons.account_balance, 'label': 'Fund'},
      {'icon': Icons.settings, 'label': 'Settings'},
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.school,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 32),
            ...items.map((item) => _buildSidebarItem(item)),
          ],
        ),
        Column(
          children: [
            _buildSidebarItem({'icon': Icons.logout, 'label': 'Logout'}),
            const SizedBox(height: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebarItem(Map<String, dynamic> item) {
    final isSelected = item['label'] == selectedCategory ||
        (item['label'] == 'Dashboard' && selectedCategory == 'Students');
    final iconColor = isSelected ? const Color(0xFF3B82F6) : Colors.grey[400];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {
          if (item['label'] == 'Students') {
            setState(() => selectedCategory = 'Students');
          } else if (item['label'] == 'Teachers') {
            setState(() => selectedCategory = 'Teachers');
          } else if (item['label'] == 'Fund') {
            setState(() => selectedCategory = 'School Fund');
          }
        },
        icon: Icon(item['icon'], color: iconColor, size: 24),
        tooltip: item['label'],
      ),
    );
  }

  // ============ HEADER ============
  Widget _buildDashboardHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 ${selectedSchool} Dashboard',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage ${selectedCategory.toLowerCase()} records',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.school, color: Color(0xFF3B82F6), size: 18),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSchool,
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                    items: _schoolList.map((school) {
                      return DropdownMenuItem(
                        value: school,
                        child: Text(school),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSchool = value!;
                        selectedItem = null;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isAdding = true;
                _clearForm();
                selectedItem = null;
              });
            },
            icon: const Icon(Icons.add, size: 20),
            label: Text('Add ${selectedCategory == 'Students' ? 'Student' : selectedCategory == 'Teachers' ? 'Teacher' : 'Expense'}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 ${selectedSchool}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                selectedCategory,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedSchool,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              items: _schoolList.map((school) {
                return DropdownMenuItem(
                  value: school,
                  child: Text(school),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSchool = value!;
                  selectedItem = null;
                  _currentPage = 0;
                });
              },
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isAdding = true;
                _clearForm();
                selectedItem = null;
              });
            },
            icon: const Icon(Icons.add, color: Color(0xFF3B82F6)),
          ),
        ],
      ),
    );
  }

  // ============ STATS GRID ============
  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Row(
      children: [
        _buildStatCard(
          'Total ${selectedCategory}',
          stats['count'].toString(),
          Icons.people,
          const Color(0xFF3B82F6),
          'total',
        ),
        _buildStatCard(
          'Total Amount',
          _formatCurrency(stats['total']),
          Icons.attach_money,
          const Color(0xFF8B5CF6),
          'amount',
        ),
        _buildStatCard(
          'Collected',
          _formatCurrency(stats['paid']),
          Icons.check_circle,
          const Color(0xFF10B981),
          'collected',
        ),
        _buildStatCard(
          'Pending',
          _formatCurrency(stats['due']),
          Icons.pending,
          const Color(0xFFEF4444),
          'pending',
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String type) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ FILTER BAR ============
  Widget _buildFilterBar(Map<String, int> classStats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tabs
          Row(
            children: [
              ..._categoryList.map((category) {
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                      selectedItem = null;
                      _currentPage = 0;
                      selectedClass = 'All';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _getCategoryColor(category) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getCategoryIcon(category),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _currentData.where((i) => i['category'] == category).length.toString(),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const Spacer(),
              // View toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildViewToggle(Icons.list, 'list'),
                    _buildViewToggle(Icons.grid_view, 'grid'),
                  ],
                ),
              ),
            ],
          ),
          if (selectedCategory == 'Students' && classStats.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildClassChip('All', classStats.values.reduce((a, b) => a + b)),
                ...classStats.entries.map((entry) =>
                    _buildClassChip(entry.key, entry.value)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      _currentPage = 0;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search ${selectedCategory.toLowerCase()}...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    filled: true,
                    fillColor: Colors.grey[50],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    icon: Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
                    items: _statusList.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, String view) {
    final isSelected = _selectedView == view;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = view),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ] : [],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildClassChip(String className, int count) {
    final isSelected = selectedClass == className;
    return GestureDetector(
      onTap: () => setState(() {
        selectedClass = isSelected ? 'All' : className;
        _currentPage = 0;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[200]!,
          ),
        ),
        child: Text(
          '${className == 'All' ? '📚 All' : className} ($count)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // ============ CONTENT ============
  Widget _buildContent() {
    return _selectedView == 'list'
        ? _buildListView()
        : _buildGridView();
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _paginatedItems.length,
      itemBuilder: (context, index) {
        final item = _paginatedItems[index];
        final isSelected = selectedItem?['id'] == item['id'];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              setState(() {
                selectedItem = item;
                if (_isAdding) {
                  _isAdding = false;
                  _clearForm();
                }
              });
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(item['category']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getCategoryIcon(item['category']),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Row(
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(item['status']),
                        color: _getStatusColor(item['status']),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(item['status']),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['class'] != 'All' ? 'Class ${item['class']}' : '',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatCurrency(item['totalFee']),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['id'],
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
                if (item['due'] > 0)
                  Text(
                    'Due: ${_formatCurrency(item['due'])}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: _paginatedItems.length,
      itemBuilder: (context, index) {
        final item = _paginatedItems[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedItem = item;
              if (_isAdding) {
                _isAdding = false;
                _clearForm();
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item['category']).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _getCategoryIcon(item['category']),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item['status'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(item['status']),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(item['totalFee']),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============ DETAILS PANEL ============
  Widget _buildDetailsPanel(Map<String, dynamic> item) {
    final color = const Color(0xFF3B82F6);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getCategoryColor(item['category']),
                _getCategoryColor(item['category']).withOpacity(0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCategoryIcon(item['category']),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['category']} • ${item['school']}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () => _editItem(item),
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => _deleteItem(item),
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('ID', item['id']),
                _buildDetailRow('Class', item['class']),
                _buildDetailRow('Status', item['status'], color: _getStatusColor(item['status'])),
                const Divider(),
                _buildDetailRow('Total Fee', _formatCurrency(item['totalFee']), isBold: true),
                _buildDetailRow('Paid', _formatCurrency(item['paid']), color: Colors.green),
                _buildDetailRow('Due', _formatCurrency(item['due']), color: Colors.red, isBold: true),
                const Divider(),
                if (item['category'] == 'Students') ...[
                  _buildDetailRow('Father', item['fatherName'] ?? 'N/A'),
                  _buildDetailRow('Mother', item['motherName'] ?? 'N/A'),
                ],
                if (item['category'] == 'Teachers') ...[
                  _buildDetailRow('Designation', item['designation'] ?? 'N/A'),
                  _buildDetailRow('Department', item['fatherName'] ?? 'N/A'),
                ],
                if (item['category'] == 'School Fund') ...[
                  _buildDetailRow('Expense Type', item['expenseType'] ?? 'N/A'),
                  _buildDetailRow('Description', item['description'] ?? 'No description'),
                ],
                const Divider(),
                _buildDetailRow('Payment Mode', item['paymentMode']),
                _buildDetailRow('Date', item['date'] ?? 'N/A'),
                if (item['transactionId'] != '-')
                  _buildDetailRow('Transaction ID', item['transactionId']),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ EMPTY STATES ============
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${selectedCategory.toLowerCase()} found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDetails() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getCategoryColor(selectedCategory).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              _getCategoryIcon(selectedCategory),
              style: const TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an item',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click on any ${selectedCategory.toLowerCase()} to view details',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ============ FORM ============
  Widget _buildForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getCategoryColor(_selectedCategoryForm).withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(_selectedCategoryForm),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getCategoryIcon(_selectedCategoryForm),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedItem != null ? 'Edit $_selectedCategoryForm' : 'Add $_selectedCategoryForm',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isAdding = false;
                    _clearForm();
                  });
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: _buildPhotoUpload(),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField('Name', _nameController, true),
                  if (_selectedCategoryForm != 'School Fund') ...[
                    _buildFormField('Father Name', _fatherNameController, true),
                    _buildFormField('Mother Name', _motherNameController, true),
                  ],
                  _buildDropdownField('Category', _selectedCategoryForm, _categoryList, (v) {
                    setState(() {
                      _selectedCategoryForm = v!;
                      _amountController.clear();
                      _paidController.clear();
                    });
                  }),
                  if (_selectedCategoryForm == 'Students')
                    _buildDropdownField('Class', _selectedClassForm,
                        _classList.where((c) => c != 'All').toList(), (v) {
                          setState(() {
                            _selectedClassForm = v!;
                            _amountController.text = _classFees[_selectedClassForm].toString();
                          });
                        }),
                  if (_selectedCategoryForm == 'Teachers')
                    _buildDropdownField('Designation', _selectedClassForm,
                        _teacherSalaries.keys.toList(), (v) {
                          setState(() {
                            _selectedClassForm = v!;
                            _amountController.text = _teacherSalaries[_selectedClassForm].toString();
                          });
                        }),
                  if (_selectedCategoryForm == 'School Fund')
                    _buildDropdownField('Expense Type', _selectedExpenseType, _expenseTypeList, (v) {
                      setState(() => _selectedExpenseType = v!);
                    }),
                  _buildFormField('Total Amount', _amountController, true,
                      enabled: _selectedCategoryForm == 'Students' || _selectedCategoryForm == 'Teachers'),
                  _buildFormField('Paid Amount', _paidController, true, keyboardType: TextInputType.number),
                  _buildDropdownField('Payment Mode', _selectedPaymentMode, _paymentModeList, (v) {
                    setState(() => _selectedPaymentMode = v!);
                  }),
                  _buildFormField('Date', _dateController, true, hintText: 'YYYY-MM-DD'),
                  if (_selectedCategoryForm == 'School Fund')
                    _buildFormField('Description', _descriptionController, false, maxLines: 2),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isAdding = false;
                              _clearForm();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: selectedItem != null
                              ? () => _updateItem(selectedItem!)
                              : _addItem,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: _getCategoryColor(_selectedCategoryForm),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            selectedItem != null ? 'Update' : 'Save',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, bool required,
      {bool enabled = true, int maxLines = 1, TextInputType? keyboardType, String? hintText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
          filled: true,
          fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        ),
        validator: required
            ? (v) => v?.trim().isEmpty ?? true ? '$label is required' : null
            : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 500,
          maxHeight: 500,
          imageQuality: 80,
        );
        if (picked != null) {
          setState(() => _imageFile = File(picked.path));
        }
      },
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: _imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_imageFile!, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              color: Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Upload Photo',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}