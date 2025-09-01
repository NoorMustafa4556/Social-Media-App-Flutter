import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart'; // iske liye 'uuid' package add karna parega: flutter pub add uuid

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Function to upload an image to Firebase Storage
  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost) async {
    // childName will be 'profilePics' or 'posts'
    // isPost will decide if we need a unique ID for each post image

    // Create a reference to the location you want to upload to
    Reference ref = _storage.ref().child(childName).child(Uuid().v1()); // v1 for time-based UUID

    // Upload the file
    UploadTask uploadTask = ref.putData(file);

    // Get the download URL
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }
}