import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
  final String imageUrl;
  final String? heroTag; // Hero animation ke liye (optional)

  const ImageViewScreen({super.key, required this.imageUrl, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Semi-transparent background
      backgroundColor: Colors.black.withOpacity(0.8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Back button ko white karega
      ),
      body: Center(
        child: Hero(
          // Hero tag same hona chahiye taake animation kaam kare
          tag: heroTag ?? imageUrl,
          child: InteractiveViewer( // Yeh zoom in/out ki functionality deta hai
            panEnabled: false, // Pan ko disable rakhein
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain, // Poori image dikhaye
              // Image load hotay waqt loader dikhayein
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}