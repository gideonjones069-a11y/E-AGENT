import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'report_screen.dart';

class AllReportsScreen extends StatefulWidget {
  const AllReportsScreen({super.key});

  @override
  State<AllReportsScreen> createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends State<AllReportsScreen> {

  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final data = await DatabaseHelper.instance.getAllReports();

    setState(() {
      reports = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Reports"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : reports.isEmpty
              ? const Center(child: Text("No reports available"))

              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {

                    final report = reports[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),

                      child: ListTile(
                        leading: const Icon(Icons.description),

                        title: Text(report['policy'] ?? 'Unknown'),

                        subtitle: Text(
                          "Client ID: ${report['clientId']} | Score: ${report['riskScore']}",
                        ),

                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportScreen(
                                result: {
                                  'policy': report['policy'],
                                  'risk_score': report['riskScore'],
                                  'risk_level': report['riskLevel'],
                                  'premium_estimate': report['premium'],
                                  'reserve_suggestion': {
                                    'min': report['reserveMin'],
                                    'max': report['reserveMax'],
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}