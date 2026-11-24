import 'package:flutter/material.dart';
import 'policies_screen.dart';
import 'reports_screen.dart';
import 'cyber_underwriting_screen.dart';

class ClientProfileScreen extends StatelessWidget {
  final Map<String, dynamic> client;

  const ClientProfileScreen({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    final String name = client['fullName'] ?? '';
    final String phone = client['phoneNumber'] ?? '';
    final String email = client['email'] ?? 'No email';
    final String policy = client['policyType'] ?? 'Not specified';
    final String notes = client['notes'] ?? '';

    final int clientId = client['id'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Profile'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// AVATAR
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// NAME
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            /// PHONE
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Phone"),
                subtitle: Text(phone),
              ),
            ),

            /// EMAIL
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email"),
                subtitle: Text(email),
              ),
            ),

            /// POLICY TYPE
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.policy),
                title: const Text("Policy Type"),
                subtitle: Text(policy),
              ),
            ),

            /// NOTES
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.note),
                title: const Text("Notes"),
                subtitle: Text(
                  notes.isEmpty ? "No notes added" : notes,
                ),
              ),
            ),

            const Spacer(),

            /// GENERAL UNDERWRITING
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.policy),
                label: const Text("Run Underwriting"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PoliciesScreen(
                        clientId: clientId,
                        client: client,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /// CYBER
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shield),
                label: const Text("Cyber Assessment"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CyberUnderwritingScreen(
                        clientId: clientId,
                        clientName: name,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            /// REPORTS
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.assessment),
                label: const Text("View Reports"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportsScreen(
                        clientId: clientId,
                        clientName: name,
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}