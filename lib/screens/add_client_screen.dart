import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final notes = TextEditingController();

  String policy = 'Life';

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await DatabaseHelper.instance.addClient({
        'fullName': name.text.trim(),
        'phoneNumber': phone.text.trim(),
        'email': email.text.trim(),
        'policyType': policy,
        'notes': notes.text.trim(),
        'dateAdded': DateTime.now().toIso8601String(),
      });

      debugPrint("CLIENT INSERT RESULT: $result");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client added successfully')),
      );

      // CLEAR FORM
      name.clear();
      phone.clear();
      email.clear();
      notes.clear();

      setState(() {
        policy = 'Life';
      });

    } catch (e) {
      debugPrint("CLIENT INSERT ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add client')),
      );
    }
  }

  InputDecoration fieldStyle(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Client'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [

                      TextFormField(
                        controller: name,
                        decoration: fieldStyle('Full Name'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter name' : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        decoration: fieldStyle('Phone Number'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter phone number' : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: fieldStyle('Email'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter email' : null,
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: policy,
                        decoration: fieldStyle('Desired Policy'),
                        items: [
                          'Life',
                          'Health',
                          'Motor',
                          'Property',
                          'Savings'
                        ]
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => policy = v!),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: notes,
                        decoration: fieldStyle('Additional Notes'),
                        minLines: 2,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            submit();
                          },
                          child: const Text('Add Client'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}