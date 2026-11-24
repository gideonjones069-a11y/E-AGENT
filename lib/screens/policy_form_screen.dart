import 'package:flutter/material.dart';

class PolicyFormScreen extends StatefulWidget {
  const PolicyFormScreen({super.key});

  @override
  State<PolicyFormScreen> createState() => _PolicyFormScreenState();
}

class _PolicyFormScreenState extends State<PolicyFormScreen> {
  final Map<String, int> answers = {};

  List<String> getQuestions(String policy) {
    switch (policy) {
      case 'Endowment':
      case 'Term Life':
        return [
          'Age of client?',
          'Smoker or non-smoker?',
          'Any existing illnesses?',
          'Occupation risk level?',
          'Family dependents?',
          'Annual income?',
          'Desired cover amount?',
          'Medical history?',
          'Previous life cover?',
          'Premium affordability?',
        ];

      case 'Comprehensive':
        return [
          'Car make and model?',
          'Year of manufacture?',
          'Driver experience?',
          'Vehicle usage?',
          'Annual mileage?',
          'Accident history?',
          'Car security features?',
          'Parking location?',
          'Primary driver age?',
          'Claim frequency?',
        ];

      default:
        return List.generate(10, (i) => 'Generic question ${i + 1}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final policy =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Policy';

    final questions = getQuestions(policy);

    return Scaffold(
      appBar: AppBar(
        title: Text('$policy Questionnaire'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 6),

            for (var q in questions)
              Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Slider(
                        value: (answers[q] ?? 5).toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '${answers[q] ?? 5}',
                        onChanged: (value) {
                          setState(() {
                            answers[q] = value.toInt();
                          });
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Score: ${answers[q] ?? 5}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/result',
                    arguments: answers,
                  );
                },
                child: const Text('Generate Result'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}