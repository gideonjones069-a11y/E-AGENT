import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: const [

          ListTile(
            leading: Icon(Icons.person),
            title: Text("Agent Name"),
            subtitle: Text("Demo Agent"),
          ),

          ListTile(
            leading: Icon(Icons.email),
            title: Text("Email"),
            subtitle: Text("agent@example.com"),
          ),

          ListTile(
            leading: Icon(Icons.info),
            title: Text("App Version"),
            subtitle: Text("E-Agent v1.0"),
          ),

        ],
      ),
    );
  }
}