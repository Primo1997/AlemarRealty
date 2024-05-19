import 'package:flutter/material.dart';

class ProfileState with ChangeNotifier {
  late String _name;
  late String _sex;
  String? _profilePicturePath;
  Map<String, dynamic>? user;

  ProfileState(this._name, this._sex, this._profilePicturePath, {this.user});

  String get name => _name;
  String get sex => _sex;
  String? get profilePicturePath => _profilePicturePath;

  void updateProfile(String name, String sex, String? profilePicturePath) {
    _name = name;
    _sex = sex;
    _profilePicturePath = profilePicturePath;
    notifyListeners();
  }

  void updateProfilePicture(String imagePath) {
    _profilePicturePath = imagePath;
    notifyListeners();
  }

  void setProfilePicturePath(String path) {
    _profilePicturePath = path;
    notifyListeners();
  }

  void updateProfilePicturePath(String? profilePicturePath) {
    if (profilePicturePath != null) {
      _profilePicturePath = profilePicturePath;
      notifyListeners();
    }
  }

  void setDarkMode(bool value) {
    // Add dark mode logic here if necessary
    notifyListeners();
  }

  void updateUser(Map<String, dynamic> updatedUser) {
    if (updatedUser != null) {
      user = updatedUser;
      _name = updatedUser['name'] ?? _name;
      _sex = updatedUser['sex'] ?? _sex;
      _profilePicturePath =
          updatedUser['profilePicturePath'] ?? _profilePicturePath;
      notifyListeners();
    }
  }
}
