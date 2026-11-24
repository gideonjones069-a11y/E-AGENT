import 'package:flutter/material.dart';
import 'reports_screen.dart';
import '../database/database_helper.dart';

class CyberUnderwritingScreen extends StatefulWidget {

  final int clientId;
  final String clientName;

  const CyberUnderwritingScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<CyberUnderwritingScreen> createState() => _CyberUnderwritingScreenState();
}

class _CyberUnderwritingScreenState extends State<CyberUnderwritingScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> answers = {};

  @override
  void initState() {
    super.initState();

    for (var q in _questions) {
      answers[q['key']] = q['default'];
    }
  }

  final List<Map<String, dynamic>> _questions = [
    {'label': 'Number of employees', 'key': 'employees', 'type': 'num', 'default': 50},
    {'label': 'Annual revenue (KES millions)', 'key': 'revenue', 'type': 'num', 'default': 100},
    {'label': 'Does the company store customer personal data?', 'key': 'personal_data', 'type': 'bool', 'default': true},
    {'label': 'Does the company use multi-factor authentication?', 'key': 'mfa', 'type': 'bool', 'default': false},
    {'label': 'Has there been a past cyber incident?', 'key': 'past_incident', 'type': 'bool', 'default': false},
    {'label': 'Presence of IT security policy?', 'key': 'policy', 'type': 'bool', 'default': true},
    {'label': 'Frequency of data backups (per month)', 'key': 'backups', 'type': 'num', 'default': 4},
    {'label': 'Has staff received cybersecurity training?', 'key': 'training', 'type': 'bool', 'default': false},
    {'label': 'Use of antivirus or endpoint protection?', 'key': 'antivirus', 'type': 'bool', 'default': true},
    {'label': 'Is data encrypted at rest?', 'key': 'encryption', 'type': 'bool', 'default': true},
    {'label': 'Cloud service provider used?', 'key': 'cloud', 'type': 'text', 'default': 'AWS'},
    {'label': 'Does the company outsource IT services?', 'key': 'outsourced', 'type': 'bool', 'default': false},
    {'label': 'Incident response plan in place?', 'key': 'ir_plan', 'type': 'bool', 'default': true},
    {'label': 'Estimated cyber insurance limit desired (KES millions)', 'key': 'limit', 'type': 'num', 'default': 20},
    {'label': 'Industry risk rating (1-Low, 3-Medium, 5-High)', 'key': 'industry_risk', 'type': 'num', 'default': 3},
  ];

  void _onChanged(String key, dynamic value) {
    setState(() {
      answers[key] = value;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final result = _calculateCyberScore(answers);

    ///  SAVE TO DATABASE
    await DatabaseHelper.instance.addReport({
      'clientId': widget.clientId,
      'policy': result['policy'],
      'riskScore': result['risk_score'],
      'riskLevel': result['risk_level'],
      'premium': result['premium_estimate'],
      'reserveMin': result['reserve_suggestion']['min'],
      'reserveMax': result['reserve_suggestion']['max'],
      'createdAt': DateTime.now().toIso8601String(),
    });

    ///  TO REPORTS 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReportsScreen(
          clientId: widget.clientId,
          clientName: widget.clientName,
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateCyberScore(Map<String, dynamic> a) {
    double score = 70;
    double premium = 50000;

    if (a['mfa'] == false) score -= 10;
    if (a['training'] == false) score -= 8;
    if (a['past_incident'] == true) score -= 15;
    if (a['policy'] == false) score -= 10;
    if (a['encryption'] == false) score -= 7;
    if ((a['industry_risk'] ?? 0) >= 4) score -= 10;

    score += ((a['backups'] ?? 0) >= 4 ? 5 : -5);

    score = score.clamp(0, 100);

    premium += ((5 - (score / 20)) * 20000);

    String level;

    if (score >= 75) {
      level = 'Low Risk';
    } else if (score >= 50) {
      level = 'Moderate Risk';
    } else {
      level = 'High Risk';
    }

    return {
      'policy': 'Cyber Insurance',
      'risk_score': score.round(),
      'risk_level': level,
      'premium_estimate': premium.round(),
      'reserve_suggestion': {
        'min': (premium * 5).round(),
        'max': (premium * 10).round()
      },
    };
  }

  @override
  Widget build(BuildContext context) {

    final String clientName = widget.clientName;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cyber Underwriting - $clientName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView.separated(
            itemCount: _questions.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {

              if (i == _questions.length) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Generate Underwriting Score',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final q = _questions[i];
              final value = answers[q['key']];

              switch (q['type']) {

                case 'bool':
                  return SwitchListTile(
                    title: Text(q['label']),
                    value: value ?? false,
                    onChanged: (v) => _onChanged(q['key'], v),
                  );

                case 'num':
                  return TextFormField(
                    initialValue: value?.toString(),
                    decoration: InputDecoration(labelText: q['label']),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a number';
                      return null;
                    },
                    onChanged: (v) =>
                        _onChanged(q['key'], double.tryParse(v) ?? 0),
                  );

                case 'text':
                  return TextFormField(
                    initialValue: value?.toString(),
                    decoration: InputDecoration(labelText: q['label']),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                    onChanged: (v) => _onChanged(q['key'], v),
                  );

                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}