import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Providers/AuthProvider.dart';

import 'package:social_media_app/Services/StorageService.dart';

import 'package:social_media_app/Widgets/CustomTextField.dart';

import '../../Services/FireStoreServices.dart';
import '../../Widgets/ImagePicker.dart';
import '../Main App/HomeScreen.dart'; // Apna custom textfield

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Yeh function image select karne ke liye bottom sheet kholega
  void _selectImage() {
    showImagePicker(context, (image) {
      if (image != null) {
        setState(() {
          _image = image;
        });
      }
    });
  }

  // Profile save karne ka poora logic yahan hai
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a profile picture.'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String uid = authProvider.user!.uid;
      String email = authProvider.user!.email!;

      try {
        // STEP 1: Image ko Firebase Storage par upload karo
        String profilePicUrl = await StorageService().uploadImageToStorage('profilePics', _image!, false);

        // STEP 2: Saari details ko Firestore main save karo
        String res = await FireStoreService().createUserProfile(
          uid: uid,
          email: email,
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          profilePicUrl: profilePicUrl,
        );

        if (mounted && res == "success") {
          // Success hone par HomeScreen par jao
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res), backgroundColor: Colors.red));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: CupertinoColors.activeGreen,
        title: const Text(
          "Complete Your Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Just one last step!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(_image!),
                      )
                          : const CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage('https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'),
                      ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: _selectImage, // Image select karne ka button
                          icon: const Icon(Icons.add_a_photo, color: CupertinoColors.activeGreen,),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _nameController,
                  hintText: "Full Name (e.g., Ali Ahmed)",
                  icon: Icons.person_outline,
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                CustomTextField(
                  controller: _usernameController,
                  hintText: "Username (e.g., ali_ahmed123)",
                  icon: Icons.alternate_email,
                  validator: (value) {
                    if(value!.isEmpty) return 'Please enter a username';
                    if(value.contains(' ')) return 'Username cannot contain spaces';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CupertinoColors.activeGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save & Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}