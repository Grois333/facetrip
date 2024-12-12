import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageAPI{
  final Reference _storageReference = FirebaseStorage.instance.ref();

  Future<UploadTask> uploadFile(String path, File image){
    // path, directory where to save
    // image, real file to store
    return Future.value(_storageReference.child(path).putFile(image));
  }
}