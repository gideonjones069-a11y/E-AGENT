import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ReportScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {

    final policy = result['policy'] ?? "Unknown Policy";
    final riskScore = result['risk_score'] ?? 0;
    final riskLevel = result['risk_level'] ?? "Unknown";
    final premium = result['premium_estimate'] ?? 0;

    final reserve = result['reserve_suggestion'] ??
        {'min': 0, 'max': 0};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Underwriting Report'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
        children: [

          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: const Icon(Icons.policy),
              title: const Text("Policy Type"),
              subtitle: Text(policy.toString()),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.speed),
              title: const Text("Risk Score"),
              subtitle: Text("$riskScore / 100"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber),
              title: const Text("Risk Level"),
              subtitle: Text(riskLevel.toString()),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text("Estimated Premium"),
              subtitle: Text("KES $premium"),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text("Suggested Reserve"),
              subtitle: Text(
                "KES ${reserve['min']} - ${reserve['max']}",
              ),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Export Report (Coming Soon)"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("PDF export coming soon"),
                  ),
                );
              },
            ),
          )
        ],
        ),
      ),
    );
  }
}