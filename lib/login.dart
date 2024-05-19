import 'package:flutter/material.dart';
import 'news_feed_page.dart';
import 'register.dart';
import 'package:alemar_realty/database_helper.dart';

class Login extends StatefulWidget {
  final VoidCallback onLogin;

  const Login({super.key, required this.onLogin});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  void _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text;
      final password = passwordController.text;
      final user = await DatabaseHelper.instance.getUser(email);
      if (user != null && user['password'] == password) {
        // Login successful, navigate to NewsFeedPage with logged-in user information
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewsFeedPage(
              name: user['name'],
              profilePicturePath: user['profilePicture'], profilePicUrl: '',
              user: {},
              // Pass any other necessary user information here
            ),
          ),
        );
      } else {
        // Login failed, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  void _onRegisterPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alemar Realty'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Image.asset(
                    'images/ALEMAR.png', // Path to your logo image
                    height: 200, // Adjust the height as needed
                  ),
                ),
                _buildEmailField(),
                _buildPasswordField(),
                _buildButtonRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextFormField(
        controller: emailController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Email",
        ),
        validator: _validateEmail,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Password",
        ),
        validator: _validatePassword,
      ),
    );
  }

  Widget _buildButtonRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _onLoginPressed,
            child: const Text("Login"),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _onRegisterPressed,
            child: const Text("Register"),
          ),
        ],
      ),
    );
  }
}
