import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  final int clientId;
  final Map<String, dynamic> client;
  final String policyCategory;
  final String subpolicy;

  const QuestionnaireScreen({
    super.key,
    required this.clientId,
    required this.client,
    required this.policyCategory,
    required this.subpolicy,
  });

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> answers = {};
  late List<_Q> questions;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    questions = _questionsFor(widget.policyCategory, widget.subpolicy);

    for (var q in questions) {
      answers[q.key] = q.defaultValue;
    }

    _prefillClientData();
  }

  void _prefillClientData() {
    final client = widget.client;

    answers['client_name'] = client['fullName'] ?? '';
    answers['client_email'] = client['email'] ?? '';
    answers['saved_policy'] = client['policyType'] ?? '';

    if (answers.containsKey('dependents')) {
      answers['dependents'] = 2;
    }
  }

  List<_Q> _questionsFor(String cat, String sub) {
    final s = sub.toLowerCase();

    if (cat == 'Life') {
      List<_Q> qs = [
        _Q('Age', 'age', 'num', 30),
        _Q('BMI', 'bmi', 'num', 24),
        _Q('Smoker?', 'smoker', 'bool', false),
        _Q('Existing illness?', 'illness', 'bool', false),
        _Q('Income (KES thousands)', 'income', 'num', 50),
        _Q('Dependents', 'dependents', 'num', 2),
        _Q('Term (years)', 'term', 'num', 20),
      ];

      if (s.contains('endowment')) {
        qs.add(_Q('Savings Goal', 'savings_goal', 'num', 1000));
      }

      return qs;
    }

    if (cat == 'Health') {
      return [
        _Q('Age', 'age', 'num', 30),
        _Q('BMI', 'bmi', 'num', 24),
        _Q('Pre-existing illness?', 'preexist', 'bool', false),
        _Q('Dependents', 'dependents', 'num', 2),
        _Q('Cover Amount', 'cover_amount', 'num', 500),
      ];
    }

    if (cat == 'Motor') {
      return [
        _Q('Driver Age', 'driver_age', 'num', 30),
        _Q('Driving Experience', 'experience', 'num', 5),
        _Q('Claims History', 'claims', 'num', 0),
        _Q('Vehicle Value', 'vehicle_value', 'num', 800),
        _Q('Mileage', 'mileage', 'num', 15000),
      ];
    }

    if (cat == 'Property') {
      return [
        _Q('Property Value', 'property_value', 'num', 2000),
        _Q('Crime Risk (1-5)', 'crime_risk', 'num', 2),
        _Q('Flood History?', 'flood_history', 'bool', false),
        _Q('Security Installed?', 'security', 'bool', true),
      ];
    }

    if (cat == 'Cyber') {
      return [
        _Q('Revenue', 'revenue', 'num', 50),
        _Q('Records', 'records', 'num', 10000),
        _Q('MFA Enabled?', 'mfa', 'bool', false),
        _Q('Firewall Active?', 'firewall', 'bool', true),
        _Q('Past Incidents', 'incidents', 'num', 0),
      ];
    }

    return [_Q('Age', 'age', 'num', 30)];
  }

  void _onChanged(String key, dynamic value) {
    setState(() {
      answers[key] = value;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/calculate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "policy": widget.policyCategory,
          "subpolicy": widget.subpolicy,
          "answers": answers,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              clientId: widget.clientId,
              result: result,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Calculation failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.policyCategory} • ${widget.subpolicy}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: ListView.builder(
            itemCount: questions.length + 1,
            itemBuilder: (context, i) {
              if (i == questions.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('Generate Quote'),
                    ),
                  ),
                );
              }

              final q = questions[i];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: q.buildWidget(
                  answers[q.key],
                  (v) => _onChanged(q.key, v),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Q {
  final String label;
  final String key;
  final String type;
  final dynamic defaultValue;

  _Q(this.label, this.key, this.type, this.defaultValue);

  Widget buildWidget(dynamic currentValue, void Function(dynamic) onChanged) {
    if (type == 'bool') {
      return SwitchListTile(
        title: Text(label),
        value: currentValue ?? false,
        onChanged: onChanged,
      );
    }

    return TextFormField(
      initialValue: currentValue.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? 'Required field' : null,
      onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
    );
  }
}