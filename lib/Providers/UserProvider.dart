import 'dart:typed_data'; // Uint8List ke liye zaroori
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fAuth; // Name conflict se bachne ke liye
import 'package:flutter/material.dart';
import 'package:social_media_app/Models/UserModel.dart';

import 'package:social_media_app/Services/StorageService.dart';

import '../Services/FireStoreServices.dart'; // StorageService ke liye zaroori

class UserProvider with ChangeNotifier {
  UserModel? _userModel;
  final FireStoreService _fireStoreService = FireStoreService();

  // Public getter taake UI isko safely access kar sake
  UserModel? get user => _userModel;

  /// Yeh function LoginScreen se call hota hai.
  /// Yeh check karta hai ke user ki profile bani hui hai ya nahi.
  /// Agar bani hai, to data fetch karke 'true' return karta hai.
  Future<bool> checkAndSetUser(String uid) async {
    DocumentSnapshot? snap = await _fireStoreService.getUserDetails(uid);
    if (snap != null && snap.exists) {
      _userModel = UserModel.fromSnap(snap);
      notifyListeners();
      return true; // Profile exists
    }
    return false; // Profile does not exist
  }

  /// Yeh function SplashScreen se call ho sakta hai.
  /// Yeh pehle se logged-in user ki details Firestore se fetch karke
  /// provider main set karta hai taake poori app use kar sake.
  Future<void> refreshUser(fAuth.User currentUser) async {
    try {
      DocumentSnapshot? snap = await _fireStoreService.getUserDetails(currentUser.uid);
      if (snap != null && snap.exists) {
        _userModel = UserModel.fromSnap(snap);
      } else {
        _userModel = null;
      }
      notifyListeners();
    } catch (e) {
      print("[USER_PROVIDER] ERROR in refreshUser: ${e.toString()}");
    }
  }

  /// Yeh function EditProfileScreen se call hota hai.
  /// Yeh user ki details (naam, username, aur optional image) ko update karta hai.
  Future<bool> updateUserData({
    required String uid,
    required String name,
    required String username,
    Uint8List? newImage, // Nayi image optional hai
  }) async {
    try {
      // Agar _userModel null hai to aage na barho
      if (_userModel == null) return false;

      String profilePicUrl = _userModel!.profilePicUrl; // Pehle purani URL le lo

      // Step 1: Agar user ne nayi image di hai, to usko upload karke nayi URL get karo
      if (newImage != null) {
        profilePicUrl = await StorageService().uploadImageToStorage('profilePics', newImage, false);
      }

      // Step 2: Data ka Map banao jo update karna hai
      Map<String, dynamic> updatedData = {
        'name': name,
        'username': username,
        'profilePicUrl': profilePicUrl,
      };

      // Step 3: Service ko call karke data Firestore main update karo
      String res = await _fireStoreService.updateUserProfile(uid, updatedData);

      if (res == "success") {
        // Step 4: Local state (provider ka data) bhi update karo taake UI foran refresh ho
        _userModel!.name = name;
        _userModel!.username = username;
        _userModel!.profilePicUrl = profilePicUrl;
        notifyListeners(); // UI ko batao ke data change ho gaya hai
        return true;
      }
      return false; // Agar Firestore main update fail ho jaye
    } catch (e) {
      print("[USER_PROVIDER] ERROR in updateUserData: ${e.toString()}");
      return false;
    }
  }
  // UserProvider.dart ke andar yeh function add karein

  Future<void> followUser(String followUid) async {
    try {
      if (_userModel == null) return;
      String myUid = _userModel!.uid;

      // Local state ko foran update karo taake UI fast respond kare
      if (_userModel!.following.contains(followUid)) {
        _userModel!.following.remove(followUid);
      } else {
        _userModel!.following.add(followUid);
      }
      notifyListeners(); // UI ko foran update kardo

      // Ab backend main changes karo
      await _fireStoreService.followUser(myUid, followUid);

    } catch (e) {
      print(e.toString());
    }
  }
}