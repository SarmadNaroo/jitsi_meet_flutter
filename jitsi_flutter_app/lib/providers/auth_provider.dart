import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jitsi_flutter_app/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  String? _token;
  String? _userId;
  String? _username;
  String? _email;
  String? _status;

  String? get token => _token;
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  String? get status => _status;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    _token = await _storage.read(key: 'token');
    _userId = await _storage.read(key: 'userId');
    _username = await _storage.read(key: 'username');
    _email = await _storage.read(key: 'email');
    _status = await _storage.read(key: 'status');
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'username': username,
        'password': password,
      });
      final data = response.data;
      _token = data['token'];
      _userId = data['userId'];
      _username = data['username'];
      _email = data['email'];
      _status = data['status'];

      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'userId', value: _userId);
      await _storage.write(key: 'username', value: _username);
      await _storage.write(key: 'email', value: _email);
      await _storage.write(key: 'status', value: _status);

      notifyListeners();
      return true;
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _username = null;
    _email = null;
    _status = null;

    await _storage.deleteAll();
    notifyListeners();
  }
}
