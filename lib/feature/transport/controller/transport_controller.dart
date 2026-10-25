import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widget/flutter_toast.dart';
import '../../main/controller/school_type_controller.dart';
import '../../main/model/school_type_model.dart';
import '../model/transport_model.dart';
import '../repository/transport_repository.dart';

class TransportController extends GetxController {
  final TransportRepository _repository = TransportRepository();
  final SchoolTypeController schoolController = Get.find<SchoolTypeController>();

  // ============ STATE ============
  final RxList<TransportModel> transports = <TransportModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // UI State
  final RxBool showRightPanel = false.obs;
  final Rx<TransportModel?> selectedTransport = Rx<TransportModel?>(null);
  final RxBool isAddingNew = false.obs;
  final RxBool isEditing = false.obs;

  // ============ FORM STATE (Transport) ============
  final vehicleNumberController = TextEditingController();
  final driverNameController = TextEditingController();
  final driverNumberController = TextEditingController();
  final capacityController = TextEditingController();
  final routeNameController = TextEditingController();

  // ============ FORM STATE (Student Assignment) ============
  final addressController = TextEditingController();
  final pickupTimeController = TextEditingController();
  final dropTimeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // ✅ Listen to School Changes (All or Specific)
    ever(schoolController.selectedSchoolType, (SchoolTypeModel? school) {
      // Agar school select hai toh schoolId pass hoga, warna null (All)
      loadTransports(school?.id);
    });

    // Initial Load
    loadTransports(schoolController.selectedSchoolType.value?.id);
  }

  @override
  void onClose() {
    vehicleNumberController.dispose();
    driverNameController.dispose();
    driverNumberController.dispose();
    capacityController.dispose();
    routeNameController.dispose();
    addressController.dispose();
    pickupTimeController.dispose();
    dropTimeController.dispose();
    super.onClose();
  }

  // ============ GETTERS ============
  List<TransportModel> get filteredTransports {
    var filtered = transports.toList();
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((t) =>
      t.vehicleNumber.toLowerCase().contains(query) ||
          t.driverName.toLowerCase().contains(query)).toList();
    }
    return filtered;
  }

  // ============ API CALLS ============

  // ✅ Nullable schoolId (null means All)
  Future<void> loadTransports(int? schoolId) async {
    try {
      isLoading.value = true;
      final result = await _repository.getTransports(schoolId: schoolId);
      transports.assignAll(result);
    } catch (e) {
      FlutterToast.error('Failed to load transports');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveTransport() async {
    if (vehicleNumberController.text.trim().isEmpty || driverNameController.text.trim().isEmpty) {
      FlutterToast.warning('Vehicle Number and Driver Name are required');
      return;
    }

    final currentSchool = schoolController.selectedSchoolType.value;
    if (currentSchool == null) {
      FlutterToast.warning('Please select a specific school to add a transport');
      return;
    }

    try {
      isLoading.value = true;
      final data = {
        'school_id': currentSchool.id,
        'vehicle_number': vehicleNumberController.text.trim(),
        'driver_name': driverNameController.text.trim(),
        'driver_number': driverNumberController.text.trim(),
        'capacity': capacityController.text.trim(),
        'route_name': routeNameController.text.trim(),
      };

      if (isEditing.value && selectedTransport.value != null) {
        await _repository.updateTransport(selectedTransport.value!.id, data);
        FlutterToast.success('Transport updated!');
      } else {
        await _repository.createTransport(data);
        FlutterToast.success('Transport created!');
      }

      await loadTransports(currentSchool.id);
      _resetAndClose();
    } catch (e) {
      FlutterToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTransport(TransportModel transport) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Transport'),
        content: Text('Are you sure you want to delete ${transport.vehicleNumber}?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              isLoading.value = true;
              final success = await _repository.deleteTransport(transport.id);
              if (success) {
                final currentSchoolId = schoolController.selectedSchoolType.value?.id;
                await loadTransports(currentSchoolId);
                FlutterToast.success('Deleted successfully');
              } else {
                FlutterToast.error('Failed to delete');
              }
              isLoading.value = false;
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ✅ Added Address, Pickup, Drop parameters
  Future<void> addStudentToTransport({
    required int transportId,
    required int studentId,
    String? address,
    String? pickupTime,
    String? dropTime,
  }) async {
    final success = await _repository.addStudent(
      transportId,
      studentId,
      address: address,
      pickupTime: pickupTime,
      dropTime: dropTime,
    );
    if (success) {
      final currentSchoolId = schoolController.selectedSchoolType.value?.id;
      await loadTransports(currentSchoolId);

      // Refresh selected transport to show new student
      final updated = transports.firstWhereOrNull((t) => t.id == transportId);
      if (updated != null) selectedTransport.value = updated;

      FlutterToast.success('Student added successfully');
    } else {
      FlutterToast.error('Failed to add student');
    }
  }

  Future<void> removeStudentFromTransport(int transportId, int studentId) async {
    final success = await _repository.removeStudent(transportId, studentId);
    if (success) {
      final currentSchoolId = schoolController.selectedSchoolType.value?.id;
      await loadTransports(currentSchoolId);

      final updated = transports.firstWhereOrNull((t) => t.id == transportId);
      if (updated != null) selectedTransport.value = updated;

      FlutterToast.success('Student removed successfully');
    } else {
      FlutterToast.error('Failed to remove student');
    }
  }

  // ============ UI METHODS ============
  void setSearchQuery(String query) => searchQuery.value = query;

  void selectTransport(TransportModel transport) {
    selectedTransport.value = transport;
    showRightPanel.value = true;
    isAddingNew.value = false;
    isEditing.value = false;
  }

  void startAddNew() {
    if (schoolController.selectedSchoolType.value == null) {
      FlutterToast.warning('Please select a specific school first (All Schools is not allowed for adding)');
      return;
    }
    _resetForm();
    isAddingNew.value = true;
    isEditing.value = false;
    selectedTransport.value = null;
    showRightPanel.value = true;
  }

  void startEditing(TransportModel transport) {
    selectedTransport.value = transport;
    vehicleNumberController.text = transport.vehicleNumber;
    driverNameController.text = transport.driverName;
    driverNumberController.text = transport.driverNumber;
    capacityController.text = transport.capacity ?? '';
    routeNameController.text = transport.routeName ?? '';

    isEditing.value = true;
    isAddingNew.value = false;
    showRightPanel.value = true;
  }

  void closeRightPanel() {
    showRightPanel.value = false;
    selectedTransport.value = null;
    isAddingNew.value = false;
    isEditing.value = false;
    _resetForm();
  }

  void _resetAndClose() {
    _resetForm();
    showRightPanel.value = false;
    isAddingNew.value = false;
    isEditing.value = false;
  }

  void _resetForm() {
    vehicleNumberController.clear();
    driverNameController.clear();
    driverNumberController.clear();
    capacityController.clear();
    routeNameController.clear();
    addressController.clear();
    pickupTimeController.clear();
    dropTimeController.clear();
  }
}