import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreedToTerms = false;
  String? errorMessage;
  String? successMessage;

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── Validators ─────────────────────────────────────────────
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().length < 3) return 'At least 3 characters';
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Only letters, numbers and underscores';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Include an uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include a number';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  // ── Toggle Visibility ──────────────────────────────────────
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void toggleTerms(bool? value) {
    agreedToTerms = value ?? false;
    notifyListeners();
  }

  // ── Sign Up ────────────────────────────────────────────────
  Future<void> signUp(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (!agreedToTerms) {
      errorMessage = 'Please agree to the Terms & Conditions';
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // 1. Create auth user
      final authResponse = await _supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (authResponse.user == null) {
        throw Exception('Sign up failed. Please try again.');
      }

      // 2. Create profile row
      await _supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      successMessage = 'Account created! Please check your email to verify.';
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/login');
    } on AuthException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Dispose ────────────────────────────────────────────────
  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}