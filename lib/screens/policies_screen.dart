import 'package:flutter/material.dart';
import 'questionnaire_screen.dart';

class PoliciesScreen extends StatelessWidget {
  final int clientId;
  final Map<String, dynamic> client;

  const PoliciesScreen({
    super.key,
    required this.clientId,
    required this.client,
  });

  static const Map<String, List<String>> policies = {
    'Life': ['Endowment', 'Whole Life', 'Term Life'],
    'Health': ['Individual', 'Family', 'Corporate'],
    'Motor': ['Comprehensive', 'Third Party', 'Commercial'],
    'Property': ['Homeowners', 'Commercial Property', 'Renters'],
    'Savings': ['Retirement', 'Education', 'Investment Plan'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Policy'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: policies.length,
        itemBuilder: (context, index) {
          final category = policies.keys.elementAt(index);
          final subPolicies = policies[category]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: subPolicies.map((sub) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuestionnaireScreen(
                              clientId: clientId,
                              client: client,
                              policyCategory: category,
                              subpolicy: sub,
                            ),
                          ),
                        );
                      },
                      child: Text(sub),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}