import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'profile_page.dart';
import 'profile_state.dart';
import 'database_helper.dart';
import 'theme_notifier.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({
    Key? key,
    required this.name,
    required this.profilePicturePath,
    required String profilePicUrl,
    required Map<String, dynamic> user,
  }) : super(key: key);

  final String name;
  final String? profilePicturePath;

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  List<Map<String, dynamic>> posts = [];
  final TextEditingController postController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _retrievePosts();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final profileState = Provider.of<ProfileState>(context, listen: false);
    final user = await DatabaseHelper.instance.getUser(profileState.name);
    if (user != null) {
      profileState.updateProfilePicturePath(user['profilePicturePath']);
    }
  }

  Future<void> _retrievePosts() async {
    final postsFromDB = await DatabaseHelper.instance.getPosts();
    setState(() {
      posts.clear();
      posts.addAll(postsFromDB);
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Login(
          onLogin: () {},
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final post = {
        'id': DateTime.now().millisecondsSinceEpoch, // Convert id to int
        'text': postController.text,
        'image': pickedFile.path,
        'comments': [], // Add the new comment as a string
      };
      await DatabaseHelper.instance.insertPost(post);
      setState(() {
        posts.add(post);
        postController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileState, ThemeNotifier>(
      builder: (context, profileState, themeNotifier, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Alemar Realty'),
            actions: [
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundImage: profileState.profilePicturePath != null
                      ? FileImage(File(profileState.profilePicturePath!))
                      : const AssetImage('images/profile_pic.jpg')
                          as ImageProvider,
                  radius: 16,
                ),
                onSelected: (value) {
                  if (value == 'Profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(userId: ''),
                      ),
                    );
                  } else if (value == 'Logout') {
                    _logout();
                  } else if (value == 'Dark Mode') {
                    themeNotifier.setDarkMode();
                  } else if (value == 'Light Mode') {
                    themeNotifier.setLightMode();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    'Profile',
                    'Logout',
                    themeNotifier.isDarkMode ? 'Light Mode' : 'Dark Mode'
                  ].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: postController,
                        decoration: const InputDecoration(
                          hintText: 'What\'s on your mind?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: _pickImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        if (postController.text.isNotEmpty) {
                          final post = {
                            'text': postController.text,
                            'image': null,
                            'comments': <String>[],
                          };
                          await DatabaseHelper.instance.insertPost(post);
                          setState(() {
                            posts.add(post);
                            postController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return _buildPostCard(context, profileState, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostCard(
      BuildContext context, ProfileState profileState, int index) {
    if (index < 0 || index >= posts.length || posts[index] == null) {
      return Container();
    }

    final post = posts[index];

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: profileState.profilePicturePath != null
                      ? FileImage(File(profileState.profilePicturePath!))
                      : const AssetImage('images/profile_pic.jpg')
                          as ImageProvider,
                  radius: 16,
                ),
                const SizedBox(width: 8),
                Text(profileState.name),
              ],
            ),
            const SizedBox(height: 8),
            if (post['image'] != null && post['image'] is String)
              Image.file(
                File(post['image']),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 8),
            Text(post['text']),
            const Divider(),
            Column(
              children: [
                ...post['comments']
                    .map<Widget>((comment) => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: profileState.profilePicturePath !=
                                    null
                                ? FileImage(
                                    File(profileState.profilePicturePath!))
                                : const AssetImage('images/profile_pic.jpg'),
                            radius: 16,
                          ),
                          title: Text(profileState.name),
                          subtitle: Text(comment.toString()),
                        ))
                    .toList(),
              ],
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Add a comment',
                border: InputBorder.none,
              ),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  if (post['comments'] == null) {
                    post['comments'] = <String>[];
                  }
                  post['comments'].add(value);
                  await DatabaseHelper.instance.updatePost(post);
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
