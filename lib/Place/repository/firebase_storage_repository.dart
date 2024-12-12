import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:facetrip/User/repository/firebase_storage_api.dart';

class FirebaseStorageRepository{

  final _firebaseStorageAPI = FirebaseStorageAPI();

  Future<UploadTask> uploadFile(String path, File image){
    // path, directory where to save
    // image, real file to store
    return _firebaseStorageAPI.uploadFile(path, image);
  }

}