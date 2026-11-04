import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../../main/model/school_type_model.dart';
import '../model/student_fee_model.dart';
import '../repository/student_fee_repository.dart';

class StudentFeeController extends GetxController {
  final StudentFeeRepository _repository = StudentFeeRepository();

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var isLoadingHistory = false.obs;

  var feeList = <StudentFeeModel>[].obs;

  // 🔥 Yahan History List ka type properly define kiya gaya hai
  var historyList = <FeeHistoryModel>[].obs;

  var selectedStudent = Rxn<StudentFeeModel>();
  var searchQuery = ''.obs;

  // 🔥 selectedSchool aur setSelectedSchool add kiya gaya hai
  var selectedSchool = Rxn<SchoolTypeModel>();

  @override
  void onInit() {
    super.onInit();
    fetchFeeList();
  }

  List<StudentFeeModel> get filteredList {
    if (searchQuery.value.isEmpty) return feeList;
    final q = searchQuery.value.toLowerCase();
    return feeList.where((t) =>
    '${t.firstName} ${t.lastName}'.toLowerCase().contains(q) ||
        (t.studentIdCard ?? '').toLowerCase().contains(q)
    ).toList();
  }

  Future<void> fetchFeeList() async {
    try {
      isLoading.value = true;
      final schoolId = selectedSchool.value?.id;
      final data = await _repository.getFeeList(schoolId: schoolId);
      feeList.assignAll(data);
    } catch (e) {
      FlutterToast.error(e.toString().replaceAll("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedSchool(SchoolTypeModel? school) {
    selectedSchool.value = school;
    fetchFeeList();
  }

  Future<void> loadHistory(int studentId) async {
    try {
      isLoadingHistory.value = true;
      final data = await _repository.getHistory(studentId);
      historyList.assignAll(data);
    } catch (e) {
      FlutterToast.error(e.toString().replaceAll("Exception: ", ""));
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<bool> addTransaction({
    required int studentId,
    required double amount,
    String? remarks,
  }) async {
    try {
      isSubmitting.value = true;
      await _repository.createTransaction(studentId, amount, remarks);
      FlutterToast.success('Fee submitted successfully');

      await fetchFeeList();
      await loadHistory(studentId);

      final updated = feeList.firstWhereOrNull((t) => t.id == studentId);
      if (updated != null) selectedStudent.value = updated;

      return true;
    } catch (e) {
      FlutterToast.error(e.toString().replaceAll("Exception: ", ""));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteTransaction(int studentId, int transactionId) async {
    try {
      await _repository.deleteTransaction(studentId, transactionId);
      FlutterToast.success('Transaction deleted successfully');

      await fetchFeeList();
      await loadHistory(studentId);

      final updated = feeList.firstWhereOrNull((t) => t.id == studentId);
      if (updated != null) selectedStudent.value = updated;
    } catch (e) {
      FlutterToast.error(e.toString().replaceAll("Exception: ", ""));
    }
  }
}