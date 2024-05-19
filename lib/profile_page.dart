import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alemar_realty/profile_state.dart';
import 'package:provider/provider.dart';
import 'package:alemar_realty/database_helper.dart';
import 'news_feed_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required String userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  String sex = 'Male';
  XFile? pickedFile;

  @override
  void initState() {
    super.initState();
    final profileState = Provider.of<ProfileState>(context, listen: false);
    nameController.text = profileState.name;
    sex = profileState.sex;
    // Ensure user is initialized
    profileState.user ??= {
      'id': 'default_id',
      'name': profileState.name,
      'email': 'default_email',
      'password': 'default_password',
      'profilePicturePath': profileState.profilePicturePath,
    };
  }

  @override
  Widget build(BuildContext context) {
    final profileState = Provider.of<ProfileState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _buildProfileImage(profileState),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickImage(context),
              child: const Text('Change Profile Picture'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: sex,
              items: ['Male', 'Female', 'Other']
                  .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  sex = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Sex',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveProfile(context, profileState),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadProfilePicture() async {
    final profileState = Provider.of<ProfileState>(context, listen: false);
    final user = await DatabaseHelper.instance.getUser(profileState.name);
    if (user != null) {
      profileState.updateUser(user);
      if (user['profilePicturePath'] != null) {
        profileState.updateProfilePicturePath(user['profilePicturePath']);
      }
    }
  }

  ImageProvider _buildProfileImage(ProfileState profileState) {
    if (pickedFile != null) {
      return FileImage(File(pickedFile!.path));
    } else if (profileState.profilePicturePath != null) {
      return AssetImage(profileState.profilePicturePath!);
    } else {
      return AssetImage(profileState.sex == 'Male'
          ? 'images/default_man.jpg'
          : profileState.sex == 'Female'
              ? 'images/default_woman.jpg'
              : 'images/profile_pic.jpg');
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        pickedFile = pickedImage;
      });
      final profileState = Provider.of<ProfileState>(context, listen: false);
      profileState.updateProfilePicture(pickedFile!.path);
    }
  }

  void _saveProfile(BuildContext context, ProfileState profileState) {
    final newProfilePicturePath =
        pickedFile?.path ?? profileState.profilePicturePath;
    final user = profileState.user;
    if (user != null) {
      profileState.updateProfile(
        nameController.text,
        sex,
        newProfilePicturePath,
      );
      DatabaseHelper.instance.updateUser({
        'id': user['id'],
        'name': nameController.text,
        'email': user['email'],
        'password': user['password'],
        'profilePicturePath': newProfilePicturePath,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User not found'),
        ),
      );
    }
  }
}
