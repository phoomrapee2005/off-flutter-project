import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  final ApiService _apiService = ApiService();
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<String?> register(User user) async {
    try {
      _error = null;
      debugPrint('AuthProvider: Attempting to register user: ${user.username}');

      final taken = await _apiService.isUsernameTaken(user.username);
      if (taken) {
        _error = 'Username is already taken';
        notifyListeners();
        return _error;
      }

      final success = await _apiService.registerUser(user);
      if (success) {
        debugPrint('AuthProvider: Registration successful');
        return null;
      } else {
        _error = 'Registration failed on server';
        notifyListeners();
        return _error;
      }
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return _error;
    } catch (e) {
      _error = 'An unexpected error occurred';
      notifyListeners();
      return _error;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _error = null;
      debugPrint('AuthProvider: Attempting login for username: $username');

      final user = await _apiService.loginUser(username, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }

      _error = 'Invalid username or password';
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
