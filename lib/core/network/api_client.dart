import 'package:dio/dio.dart';

class ApiClient {

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://suwidhaa-backend.onrender.com/api/",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

}