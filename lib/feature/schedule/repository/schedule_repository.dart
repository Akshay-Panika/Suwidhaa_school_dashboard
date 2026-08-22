import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import '../../../core/network/api_client.dart';
import '../../../core/network/api_urls.dart';
import '../model/schedule_model.dart';

class ScheduleRepository {
  final Dio dio = ApiClient.dio;

  // GET all schedules
  Future<List<ScheduleApiModel>> getSchedules() async {
    try {
      final response = await dio.get(ApiUrls.scheduleList);
      print('📡 GET Schedules Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = ScheduleListResponse.fromJson(response.data);
        return result.data;
      }
      return [];
    } catch (e) {
      print('❌ GET Schedules Error: $e');
      return [];
    }
  }

  // GET single schedule
  Future<ScheduleApiModel?> getSchedule(int id) async {
    try {
      final response = await dio.get('${ApiUrls.scheduleDetail}$id/');
      print('📡 GET Schedule $id Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          return ScheduleApiModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('❌ GET Schedule Error: $e');
      return null;
    }
  }

  // POST create schedule with multipart for files
  Future<ScheduleApiModel?> createSchedule(
      Map<String, dynamic> data,
      File? bannerImage,
      File? pdfFile,
      Uint8List? bannerImageBytes,
      Uint8List? pdfFileBytes,
      ) async {
    try {
      final formData = FormData();

      // Add text fields - Convert arrays and maps to JSON strings
      data.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            formData.fields.add(MapEntry(key, jsonEncode(value)));
          } else if (value is Map) {
            // For event_details - send as JSON string
            formData.fields.add(MapEntry(key, jsonEncode(value)));
          } else {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        }
      });

      // Add banner image - Handle both web and mobile
      if (kIsWeb) {
        if (bannerImageBytes != null) {
          formData.files.add(
            MapEntry(
              'banner_image',
              MultipartFile.fromBytes(
                bannerImageBytes,
                filename: 'banner_image.png',
              ),
            ),
          );
          print('📡 Banner Image Bytes Added (Web)');
        }
      } else {
        if (bannerImage != null && await bannerImage.exists()) {
          formData.files.add(
            MapEntry(
              'banner_image',
              await MultipartFile.fromFile(
                bannerImage.path,
                filename: bannerImage.path.split('/').last,
              ),
            ),
          );
          print('📡 Banner Image File: ${bannerImage.path}');
        }
      }

      // Add PDF file - Handle both web and mobile
      if (kIsWeb) {
        if (pdfFileBytes != null) {
          formData.files.add(
            MapEntry(
              'pdf_file',
              MultipartFile.fromBytes(
                pdfFileBytes,
                filename: 'pdf_file.pdf',
              ),
            ),
          );
          print('📡 PDF Bytes Added (Web)');
        }
      } else {
        if (pdfFile != null && await pdfFile.exists()) {
          formData.files.add(
            MapEntry(
              'pdf_file',
              await MultipartFile.fromFile(
                pdfFile.path,
                filename: pdfFile.path.split('/').last,
              ),
            ),
          );
          print('📡 PDF File: ${pdfFile.path}');
        }
      }

      print('📡 POST Create Schedule Fields: ${formData.fields}');
      print('📡 POST Create Schedule Files: ${formData.files.length}');

      final response = await dio.post(
        ApiUrls.scheduleCreate,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('📡 POST Create Schedule Response: ${response.statusCode}');
      print('📡 POST Create Schedule Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'];
        if (responseData != null) {
          return ScheduleApiModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('❌ POST Create Schedule Error: $e');
      if (e is DioException && e.response != null) {
        print('❌ Response Data: ${e.response?.data}');
      }
      return null;
    }
  }

  // PUT update schedule with multipart for files
  Future<ScheduleApiModel?> updateSchedule(
      int id,
      Map<String, dynamic> data,
      File? bannerImage,
      File? pdfFile,
      Uint8List? bannerImageBytes,
      Uint8List? pdfFileBytes,
      ) async {
    try {
      final formData = FormData();

      // Add text fields - Convert arrays and maps to JSON strings
      data.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            formData.fields.add(MapEntry(key, jsonEncode(value)));
          } else if (value is Map) {
            formData.fields.add(MapEntry(key, jsonEncode(value)));
          } else {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        }
      });

      // Add banner image - Handle both web and mobile
      if (kIsWeb) {
        if (bannerImageBytes != null) {
          formData.files.add(
            MapEntry(
              'banner_image',
              MultipartFile.fromBytes(
                bannerImageBytes,
                filename: 'banner_image.png',
              ),
            ),
          );
          print('📡 Banner Image Bytes Added (Web)');
        }
      } else {
        if (bannerImage != null && await bannerImage.exists()) {
          formData.files.add(
            MapEntry(
              'banner_image',
              await MultipartFile.fromFile(
                bannerImage.path,
                filename: bannerImage.path.split('/').last,
              ),
            ),
          );
          print('📡 Banner Image File: ${bannerImage.path}');
        }
      }

      // Add PDF file - Handle both web and mobile
      if (kIsWeb) {
        if (pdfFileBytes != null) {
          formData.files.add(
            MapEntry(
              'pdf_file',
              MultipartFile.fromBytes(
                pdfFileBytes,
                filename: 'pdf_file.pdf',
              ),
            ),
          );
          print('📡 PDF Bytes Added (Web)');
        }
      } else {
        if (pdfFile != null && await pdfFile.exists()) {
          formData.files.add(
            MapEntry(
              'pdf_file',
              await MultipartFile.fromFile(
                pdfFile.path,
                filename: pdfFile.path.split('/').last,
              ),
            ),
          );
          print('📡 PDF File: ${pdfFile.path}');
        }
      }

      print('📡 PUT Update Schedule $id Fields: ${formData.fields}');
      print('📡 PUT Update Schedule $id Files: ${formData.files.length}');

      final response = await dio.put(
        '${ApiUrls.scheduleDetail}$id/',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('📡 PUT Update Schedule Response: ${response.statusCode}');
      print('📡 PUT Update Schedule Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        if (responseData != null) {
          return ScheduleApiModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('❌ PUT Update Schedule Error: $e');
      if (e is DioException && e.response != null) {
        print('❌ Response Data: ${e.response?.data}');
      }
      return null;
    }
  }

  // DELETE schedule
  Future<bool> deleteSchedule(int id) async {
    try {
      final response = await dio.delete('${ApiUrls.scheduleDetail}$id/');
      print('📡 DELETE Schedule $id Response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ DELETE Schedule Error: $e');
      return false;
    }
  }
}