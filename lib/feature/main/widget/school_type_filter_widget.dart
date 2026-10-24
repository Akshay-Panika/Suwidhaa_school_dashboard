// lib/feature/school_type/widget/school_type_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/school_type_controller.dart';
import '../model/school_type_model.dart';

class SchoolTypeFilterWidget extends StatelessWidget {
  final SchoolTypeModel? value;
  final ValueChanged<SchoolTypeModel?>? onChanged;
  final bool compact;
  final String allLabel;

  const SchoolTypeFilterWidget({
    super.key,
    this.value,
    this.onChanged,
    this.compact = true,
    this.allLabel = 'All Schools',
  });

  @override
  Widget build(BuildContext context) {
    final height = compact ? 36.0 : 48.0;
    final fontSize = compact ? 12.0 : 14.0;

    if (!Get.isRegistered<SchoolTypeController>()) {
      return _placeholder(height, fontSize, 'Loading…');
    }

    final controller = Get.find<SchoolTypeController>();

    return Obx(() {
      if (controller.isLoading.value && controller.schoolTypes.isEmpty) {
        return _placeholder(height, fontSize, 'Loading…');
      }

      if (controller.schoolTypes.isEmpty) {
        return _placeholder(height, fontSize, 'No schools');
      }

      SchoolTypeModel? current = value;
      if (current != null) {
        final match =
        controller.schoolTypes.where((s) => s.id == current!.id).toList();
        current = match.isNotEmpty ? match.first : null;
      }

      return Container(
        height: height,
        constraints: const BoxConstraints(maxWidth: 260),
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<SchoolTypeModel?>(
            value: current,
            isExpanded: true, // ✅ Make it take available width inside the container
            isDense: true,    // ✅ Reduces default padding
            style: TextStyle(fontSize: fontSize, color: Colors.black87),
            icon: Icon(Icons.school, color: Colors.grey[600], size: 18),
            hint: Align(
              alignment: Alignment.centerLeft,
              child: Text(allLabel, style: TextStyle(fontSize: fontSize)),
            ),
            items: [
              // "All Schools" option
              DropdownMenuItem<SchoolTypeModel?>(
                value: null,
                child: _buildDropdownItem(
                  iconColor: Colors.grey,
                  label: allLabel,
                  fontSize: fontSize,
                ),
              ),
              // Actual schools
              ...controller.schoolTypes.map(
                    (school) => DropdownMenuItem<SchoolTypeModel?>(
                  value: school,
                  child: _buildDropdownItem(
                    iconColor: Colors.blue,
                    label: school.schoolName,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      );
    });
  }

  // ✅ Helper to ensure all items have the exact same height and alignment
  Widget _buildDropdownItem({
    required Color iconColor,
    required String label,
    required double fontSize,
  }) {
    return SizedBox(
      height: 40, // Fixed height prevents jumping
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(double height, double fontSize, String text) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}