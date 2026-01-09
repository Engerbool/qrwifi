import 'package:flutter/foundation.dart';

/// Authentication state provider
/// TODO: Integrate with Firebase Auth after setup
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  String? _userPhotoUrl;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userPhotoUrl => _userPhotoUrl;
  String? get error => _error;

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      // TODO: Implement actual Firebase Google Sign-In
      // For now, simulate successful login for development
      await Future.delayed(const Duration(seconds: 1));

      _isAuthenticated = true;
      _userId = 'demo_user_id';
      _userEmail = 'demo@example.com';
      _userName = 'Demo User';
      _userPhotoUrl = null;

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      // TODO: Implement actual Firebase sign out
      await Future.delayed(const Duration(milliseconds: 500));

      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
      _userName = null;
      _userPhotoUrl = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  /// Check if user is already signed in
  Future<void> checkAuthState() async {
    _setLoading(true);

    try {
      // TODO: Check Firebase auth state
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, user is not authenticated by default
      _isAuthenticated = false;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
