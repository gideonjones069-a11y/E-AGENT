import 'package:flutter/material.dart';

class PoliciesInfoScreen extends StatelessWidget {
  const PoliciesInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Policies"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          _PolicyCard(
            title: "Cyber Insurance",
            description:
                "Protects businesses against cyber attacks, data breaches, and digital threats. Includes risk scoring and premium estimation.",
            icon: Icons.shield,
          ),

          _PolicyCard(
            title: "Motor Insurance",
            description:
                "Covers vehicles against accidents, theft, and third-party liabilities.",
            icon: Icons.directions_car,
          ),

          _PolicyCard(
            title: "Health Insurance",
            description:
                "Provides medical coverage for individuals and families.",
            icon: Icons.local_hospital,
          ),

          _PolicyCard(
            title: "Property Insurance",
            description:
                "Protects buildings and assets from fire, theft, and natural disasters.",
            icon: Icons.home,
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _PolicyCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
      ),
    );
  }
}