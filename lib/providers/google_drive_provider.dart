import 'package:flutter/material.dart';
import 'package:flutter_netflix_responsive_ui/google_auth_repository.dart';

class GoogleDriveProvider extends ChangeNotifier {
  GoogleAuthRepository _googleDrive = GoogleAuthRepository();

  GoogleAuthRepository get googleDrive => _googleDrive;

  set googleDrive(GoogleAuthRepository newGoogleDrive) {
    _googleDrive = newGoogleDrive;
    notifyListeners();
  }
}
