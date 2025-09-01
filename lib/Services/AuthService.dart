import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fAuth;
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up with Email and Password
  // Ab yeh String return karega. 'Success' ya error message.
  Future<String> signUpWithEmailPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Agar sign up kamyab ho to 'Success' return karein
      return "Success";
    } on FirebaseAuthException catch (e) {
      // Firebase ke specific errors ko handle karein
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      }
      // Baaki errors ke liye general message
      return e.message ?? "An error occurred during sign up.";
    } catch (e) {
      // General errors ke liye
      return e.toString();
    }
  }

  // Login with Email and Password
  // Isko bhi update kar dete hain behtari ke liye
  Future<String> loginWithEmailPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      }
      return e.message ?? "An error occurred during login.";
    } catch (e) {
      return e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  // AuthService.dart ke andar

// Change user's password
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return "No user logged in.";
      }

      // Pehle user ko re-authenticate karo
      final cred = fAuth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Agar re-authentication successful ho, to naya password set karo
      await user.updatePassword(newPassword);

      return "success";
    } on fAuth.FirebaseAuthException catch (e) {
      // Aam errors ko handle karo
      if (e.code == 'wrong-password') {
        return 'Incorrect old password.';
      } else if (e.code == 'weak-password') {
        return 'The new password is too weak.';
      }
      return e.message ?? "An unknown error occurred.";
    } catch (e) {
      return e.toString();
    }
  }

  // Yeh function check karega ke email exist karta hai ya nahi
  Future<bool> doesEmailExist(String email) async {
    try {
      final list = await _auth.fetchSignInMethodsForEmail(email);
      // Agar list khali nahi hai, to matlab email se account bana hua hai
      return list.isNotEmpty;
    } catch (error) {
      return false;
    }
  }
  // Send Password Reset Email
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "success";
    } on FirebaseAuthException catch (e) {
      // Handle errors like 'user-not-found'
      return e.message ?? "An error occurred";
    }
  }
}

extension on FirebaseAuth {
  fetchSignInMethodsForEmail(String email) {}
}