import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> checkOnboardingStatus() async {
    return await _authService.hasCompletedOnboarding();
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> signInWithGoogle() async {
  //   try {
  //     _isLoading = true;
  //     _error = null;
  //     notifyListeners();

  //     await _authService.signInWithGoogle();
  //   } catch (e) {
  //     _error = e.toString();
  //     rethrow;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> completeOnboarding() async {
    await _authService.completeOnboarding();
  }
}
