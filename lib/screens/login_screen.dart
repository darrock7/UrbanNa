import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanna/providers/report_provider.dart';
import 'package:urbanna/screens/home_screen.dart';
import 'package:urbanna/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // ignore: use_build_context_synchronously
        Provider.of<ReportProvider>(context, listen: false).currentUserId =
            userCredential.user?.uid;

        final nameSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        final name = nameSnapshot.data()?['name'] ?? 'User';

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (_) => MyHomePage(
              title: 'UrbanNa',
              name: name,
              email: email,
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        final errorMessage = switch (e.code) {
          'user-not-found' => 'No account found for that email.',
          'wrong-password' => 'Incorrect password.',
          'invalid-email' => 'Invalid email format.',
          'network-request-failed' => 'Check your internet connection.',
          'too-many-requests' => 'Too many attempts. Try again later.',
          _ => 'Login failed. (${e.code})'
        };

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  void _signup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SignupScreen(),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
            child: Image.asset(
              'assets/images/UrbanNa_Background.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'UrbanNa',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              key: const Key('emailField'),
                              controller: _emailController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration: _inputDecoration('Email'),
                              validator: (value) => value == null || !value.contains('@')
                                  ? 'Enter valid email'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('passwordField'),
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.length < 6
                                      ? 'Password must be at least 6 characters'
                                      : null,
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    key: const Key('loginButton'),
                                    onPressed: _login,
                                    icon: const Icon(Icons.login, color: Colors.white),
                                    label: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo[700],
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    key: const Key('signupButton'),
                                    onPressed: _signup,
                                    icon: const Icon(Icons.person_add, color: Colors.white),
                                    label: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal[700],
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
