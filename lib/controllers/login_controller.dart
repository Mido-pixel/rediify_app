import 'package:flutter/material.dart';

// --- Login State Enum ---
enum LoginState { idle, loading, success, error }

// --- Login Controller ---
class LoginController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginState _state = LoginState.idle;
  String? _errorMessage;
  bool _obscurePassword = true;

  // --- Getters ---
  LoginState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _state == LoginState.loading;

  // --- Toggle Password Visibility ---
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // --- Validate Inputs ---
  String? _validateEmail(String email) {
    if (email.isEmpty) return "Email cannot be empty";
    if (!email.contains('@') || !email.contains('.')) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return "Password cannot be empty";
    if (password.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  // --- Login Logic ---
  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validate
    final emailError = _validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      _state = LoginState.error;
      notifyListeners();
      return false;
    }

    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      _errorMessage = passwordError;
      _state = LoginState.error;
      notifyListeners();
      return false;
    }

    // Simulate loading
    _state = LoginState.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // ✅ Hardcoded credentials check
    // 👇 Replace this with your real API/Firebase call later
    if (email == "user@rediify.com" && password == "password123") {
      _state = LoginState.success;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Invalid email or password";
      _state = LoginState.error;
      notifyListeners();
      return false;
    }
  }

  // --- Clear Errors ---
  void clearError() {
    _errorMessage = null;
    _state = LoginState.idle;
    notifyListeners();
  }

  // --- Reset ---
  void reset() {
    emailController.clear();
    passwordController.clear();
    _state = LoginState.idle;
    _errorMessage = null;
    _obscurePassword = true;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}