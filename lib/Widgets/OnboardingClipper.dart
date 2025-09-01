import 'package:flutter/material.dart';

class OnboardingClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Path top-left se shuru hota hai
    path.moveTo(0, 0); // Thora neeche se shuru karein taake ajeeb na lage

    // Center main curve banayein
    path.quadraticBezierTo(size.width / 2, 0, size.width, 40);

    // Baaki shape ko complete karein
    path.lineTo(size.width, size.height); // Right bottom
    path.lineTo(0, size.height); // Left bottom
    path.close(); // Path ko wapis shuruaat se jor dein

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}