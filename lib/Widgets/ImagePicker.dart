import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Function jo image pick karke Uint8List (raw data) return karega
Future<dynamic> pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file != null) {
    return await _file.readAsBytes();
  }

  // Agar user ne koi image select nahi ki
  print('No image selected.');
  return null;
}

// Function jo user ko option dega (Camera ya Gallery)
void showImagePicker(BuildContext context, Function(dynamic) onImagePicked) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                dynamic img = await pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
                if (img != null) {
                  onImagePicked(img);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () async {
                dynamic img = await pickImage(ImageSource.camera);
                Navigator.of(context).pop();
                if (img != null) {
                  onImagePicked(img);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}