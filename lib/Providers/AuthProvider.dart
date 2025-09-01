import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // <-- YEH HAI ASAL CHANGE
import 'package:flutter/material.dart';
import 'package:social_media_app/Services/AuthService.dart';

import '../Services/FireStoreServices.dart';


class AuthProvider with ChangeNotifier {
  // Services ki instances banayenge taake unke functions use kar sakein
  final AuthService _authService = AuthService();
  final FireStoreService _fireStoreService = FireStoreService(); // Aage kaam aayega

  // State variables (yeh data UI main show hoga)
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  // Getters (UI in getters ke zariye data access karega)
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  // Constructor - jab provider banega to yeh check karega ke user pehle se logged in to nahi
  AuthProvider() {
    _user = _authService.currentUser;
  }

  // --- Functions jo UI se call honge ---

  // User Sign Up Function
  Future<bool> signUpUser({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // AuthService se response haasil karein
    String response = await _authService.signUpWithEmailPassword(email, password);

    if (response == "Success") {
      // Kamyab hone par user ki details haasil karein
      _user = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return true; // Kamyabi ka signal
    } else {
      // Agar error message aaya hai to usay state main save karein
      _errorMessage = response;
      _isLoading = false;
      notifyListeners();
      return false; // Nakami ka signal
    }
  }

  // User Login Function
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String response = await _authService.loginWithEmailPassword(email, password);

    if (response == "Success") {
      _user = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // User Sign Out Function
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null; // User state ko null kar do
    notifyListeners(); // UI ko update kardo
  }
  // AuthProvider.dart ke andar

// Handle password change logic
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (result != "success") {
      _errorMessage = result;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }
  // Send Password Reset Email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String res = await _authService.sendPasswordResetEmail(email);

    _isLoading = false;
    if (res == "success") {
      notifyListeners();
      return true;
    } else {
      _errorMessage = res;
      notifyListeners();
      return false;
    }
  }
}