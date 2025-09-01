import 'package:flutter/cupertino.dart'; // CupertinoColors.activeGreen ke liye
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget { // Stateful widget banaya
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // Yeh variable password ko show/hide karne ke liye use hoga
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    // Agar field password type ki hai, to shuru main hide rakho
    _isObscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: widget.controller, // widget. use karenge stateful main
        obscureText: _isObscure, // Ab is variable se control hoga
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: CupertinoColors.activeGreen),
          hintText: widget.hintText,
          // SuffixIcon yahan add hoga
          suffixIcon: widget.isPassword // Sirf password fields ke liye eye icon dikhao
              ? IconButton(
            icon: Icon(
              _isObscure ? Icons.visibility_off : Icons.visibility, // Icon change hoga
              color: CupertinoColors.activeGreen,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure; // State ko toggle karo
              });
            },
          )
              : null, // Agar password field nahi hai to koi suffix icon nahi
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: CupertinoColors.activeGreen, width: 2.5),
          ),
        ),
      ),
    );
  }
}