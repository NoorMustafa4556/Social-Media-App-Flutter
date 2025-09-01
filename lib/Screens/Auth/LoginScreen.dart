import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/Providers/AuthProvider.dart';
import 'package:social_media_app/Providers/UserProvider.dart';
import 'package:social_media_app/Screens/Auth/CompleteProfileScreen.dart';
import 'package:social_media_app/Screens/Auth/SignUpScreen.dart';

import 'package:social_media_app/Widgets/CustomTextField.dart';

import '../Main App/HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- NAYA FUNCTION YAHAN HAI: Forgot Password Dialog ---
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Reset Password"),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter your registered email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (resetEmailController.text.trim().isNotEmpty) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  bool success = await authProvider.sendPasswordResetEmail(resetEmailController.text.trim());

                  Navigator.of(context).pop(); // Dialog band karo

                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Password reset link has been sent to your email."),
                        backgroundColor: Colors.green,
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(authProvider.errorMessage ?? "Failed to send link. Please check the email."),
                        backgroundColor: Colors.red,
                      ));
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: CupertinoColors.activeGreen),
              child: const Text("Send Link", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      bool isLoginSuccess = await authProvider.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted && isLoginSuccess) {
        String uid = authProvider.user!.uid;
        bool profileExists = await userProvider.checkAndSetUser(uid);
        if (mounted) {
          if (profileExists) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
          } else {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CompleteProfileScreen()), (route) => false);
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Login Failed."),
            backgroundColor: Colors.red,
          ),
        );
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
        title: const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.login, size: 80, color: CupertinoColors.activeGreen),
                    const SizedBox(height: 20),
                    const Text("Welcome Back!", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: _emailController,
                      hintText: "Enter your Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter your email' : null,
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: "Enter your Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter your password' : null,
                    ),

                    // --- NAYA WIDGET YAHAN HAI ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: CupertinoColors.activeGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // --- WIDGET YAHAN TAK ---

                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CupertinoColors.activeGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                          child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.activeGreen)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}