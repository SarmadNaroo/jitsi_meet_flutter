import 'package:flutter/material.dart';
import 'package:jitsi_flutter_app/services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<dynamic> _users = [];
  String _errorMessage = '';

  List<dynamic> get users => _users;
  String get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    try {
      final response = await _apiService.get('/api/users');
      if (response.statusCode == 200) {
        _users = response.data;
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load users. Status code: ${response.statusCode}';
        _users = [];
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch users: $e';
      _users = [];
    }
    notifyListeners();
  }
}
