import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = 'http://localhost:5000'; // Replace with your backend URL
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<void> _addAuthHeader() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response> post(String path, Map<String, dynamic> data) async {
    await _addAuthHeader(); // Ensure auth header is added
    return _dio.post(path, data: data);
  }

  Future<Response> get(String path) async {
    await _addAuthHeader(); // Ensure auth header is added
    return _dio.get(path);
  }
}
