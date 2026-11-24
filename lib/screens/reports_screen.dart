import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'report_screen.dart';

class ReportsScreen extends StatefulWidget {

  final int clientId;
  final String clientName;

  const ReportsScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {

  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadReports();
  }

  Future<void> _loadReports() async {

    final data = await DatabaseHelper.instance
        .getReportsByClient(widget.clientId);

    setState(() {
      reports = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("${widget.clientName} Reports"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : reports.isEmpty
              ? const Center(
                  child: Text(
                    "No reports yet.\nRun underwriting first.",
                    textAlign: TextAlign.center,
                  ),
                )

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
                          "Risk Score: ${report['riskScore']} | Premium: KES ${report['premium']}",
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {

                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Report"),
                                    content: const Text("Are you sure you want to delete this report?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {

                                  await DatabaseHelper.instance.deleteReport(report['id']);

                                  setState(() {
                                    reports.removeAt(index);
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Report deleted")),
                                  );
                                }
                              },
                            ),

                            const Icon(Icons.arrow_forward_ios, size: 16),

                          ],
                        ),

                        
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