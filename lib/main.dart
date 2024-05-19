import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_state.dart';
import 'profile_page.dart';
import 'news_feed_page.dart';
import 'login.dart';
import 'register.dart';
import 'package:alemar_realty/database_helper.dart';
import 'theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance; // Initialize the database

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProfileState('Initial Name', 'Male', null),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeNotifier(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Alemar',
          theme: themeNotifier.currentTheme,
          home: Login(
            onLogin: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewsFeedPage(
                    name: '',
                    profilePicUrl: '',
                    profilePicturePath: '',
                    user: {},
                  ),
                ),
              );
            },
          ),
          routes: {
            '/register': (context) => const RegisterPage(),
            '/profile': (context) => const ProfilePage(userId: ''),
            '/newsFeed': (context) => const NewsFeedPage(
                  name: '',
                  profilePicUrl: '',
                  profilePicturePath: '',
                  user: {},
                ),
          },
        );
      },
    );
  }
}
