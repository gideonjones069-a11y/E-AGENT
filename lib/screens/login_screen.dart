import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {

    final url = Uri.parse('http://127.0.0.1:8000/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<bool> registerUser(
      String email, String password) async {

    final url = Uri.parse('http://127.0.0.1:8000/register');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": "agent",
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          /// IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg1.png', 
              fit: BoxFit.cover,
            ),
          ),

          /// OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          ///CONTENT
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Icon(
                      Icons.security,
                      size: 80,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "WELCOME TO E-AGENT",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ///LOGIN 
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {

                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          final result = await loginUser(email, password);

                          if (result != null) {

                            final user = result['user'];

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Login successful")),
                            );

                            Navigator.pushReplacementNamed(
                              context,
                              '/home',
                              arguments: user,
                            );

                          } else {

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Invalid credentials")),
                            );
                          }
                        },
                        child: const Text("Login"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ///REGISTEr
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {

                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          final success = await registerUser(email, password);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Registered successfully")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Registration failed")),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}