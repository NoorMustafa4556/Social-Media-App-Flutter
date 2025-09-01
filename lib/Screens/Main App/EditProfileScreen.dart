import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Providers/AuthProvider.dart';
import 'package:social_media_app/Providers/UserProvider.dart';
import 'package:social_media_app/Widgets/CustomTextField.dart';
import 'package:social_media_app/Widgets/ImagePicker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  Uint8List? _image;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Validation ke liye form key

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    _nameController = TextEditingController(text: user.name);
    _usernameController = TextEditingController(text: user.username);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _selectImage() {
    showImagePicker(context, (image) {
      if (image != null) {
        setState(() { _image = image; });
      }
    });
  }

  void _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Agar form valid nahi hai to aage na barho
    }

    setState(() { _isLoading = true; });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool success = await userProvider.updateUserData(
      uid: userProvider.user!.uid,
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      newImage: _image,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update profile.")));
      }
    }
    setState(() { _isLoading = false; });
  }

  // --- PASSWORD CHANGE DIALOG FUNCTION ---
  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: dialogFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(controller: oldPasswordController, hintText: 'Old Password', icon: Icons.lock_outline, isPassword: true, validator: (v) => v!.isEmpty ? 'Required' : null),
                  CustomTextField(controller: newPasswordController, hintText: 'New Password', icon: Icons.lock, isPassword: true, validator: (v) => v!.length < 6 ? 'Min 6 characters' : null),
                  CustomTextField(controller: confirmPasswordController, hintText: 'Confirm New Password', icon: Icons.lock, isPassword: true, validator: (v) => v != newPasswordController.text ? 'Passwords do not match' : null),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
            ElevatedButton(
              child: const Text('Change'),
              onPressed: () async {
                if (dialogFormKey.currentState!.validate()) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  String result = await authProvider.changePassword(
                    currentPassword: oldPasswordController.text,
                    newPassword: newPasswordController.text,
                  );

                  if (context.mounted) {
                    if (result == 'Success') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Colors.green));
                      Navigator.of(ctx).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: Colors.red));
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: CupertinoColors.activeGreen,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isLoading ? null : _handleUpdateProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form( // Form widget add kia hai
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage: _image != null ? MemoryImage(_image!) as ImageProvider : NetworkImage(user.profilePicUrl),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: _selectImage,
                        icon: const Icon(Icons.add_a_photo, color: CupertinoColors.activeGreen),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                controller: _nameController,
                hintText: "Full Name",
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
              ),
              CustomTextField(
                controller: _usernameController,
                hintText: "Username",
                icon: Icons.alternate_email,
                validator: (v) => v!.isEmpty ? 'Username cannot be empty' : null,
              ),
              // Email (Read-Only)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(text: user.email),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    enabled: false,
                  ),
                ),
              ),
              const Divider(height: 30),
              // Change Password Button
              ListTile(
                leading: const Icon(Icons.vpn_key_outlined, color: CupertinoColors.activeGreen),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showChangePasswordDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}