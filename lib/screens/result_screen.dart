import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../database/database_helper.dart';

class ResultScreen extends StatefulWidget {
  final int clientId;
  final Map<String, dynamic> result;

  const ResultScreen({
    super.key,
    required this.clientId,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  int displayedScore = 0;

  late int riskScore;
  late int premium;
  late int reserveMin;
  late int reserveMax;
  late double probability;

  late String riskLevel;
  late String policy;

  late Map<String, dynamic> impacts;

  @override
  void initState() {
    super.initState();

    _loadResult();
    _startAnimation();
    _saveReport();
  }

  void _loadResult() {
    riskScore = (widget.result['risk_score'] ?? 0).toInt();
    premium = (widget.result['premium'] ?? 0).toInt();

    final reserve = widget.result['reserve'];

    if (reserve is Map) {
      reserveMin = (reserve['min'] ?? 0).toInt();
      reserveMax = (reserve['max'] ?? reserveMin).toInt();
    } else {
      reserveMin = (reserve ?? 0).toInt();
      reserveMax = reserveMin;
    }

    probability = (widget.result['probability'] ?? 0).toDouble();

    riskLevel = widget.result['risk_level'] ?? 'Unknown';
    policy = widget.result['policy'] ?? '';

    impacts = Map<String, dynamic>.from(
      widget.result['impacts'] ?? {},
    );
  }

  void _startAnimation() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    animation = Tween<double>(
      begin: 0,
      end: riskScore.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
    )..addListener(() {
        setState(() {
          displayedScore = animation.value.round();
        });
      });

    controller.forward();
  }

  Future<void> _saveReport() async {
    try {
      await DatabaseHelper.instance.addReport({
        'clientId': widget.clientId,
        'policy': policy,
        'riskScore': riskScore,
        'riskLevel': riskLevel,
        'premium': premium,
        'reserveMin': reserveMin,
        'reserveMax': reserveMax,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Save report error: $e");
    }
  }

  Color getRiskColor() {
    if (riskScore > 70) return Colors.red;
    if (riskScore > 40) return Colors.orange;
    return Colors.green;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = getRiskColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quote Result"),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [

                    Text(
                      policy,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: riskColor.withOpacity(.12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$displayedScore",
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: riskColor,
                              ),
                            ),
                            Text(
                              riskLevel,
                              style: TextStyle(
                                color: riskColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _infoTile(
                      "Suggested Premium",
                      "KES $premium / month",
                    ),

                    _infoTile(
                      "Reserve Range",
                      "KES $reserveMin - KES $reserveMax",
                    ),

                    _infoTile(
                      "Claim Probability",
                      "${(probability * 100).toStringAsFixed(1)}%",
                    ),

                    if (impacts.isNotEmpty) ...[
                      const SizedBox(height: 20),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Risk Breakdown",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      ...impacts.entries.map((e) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(e.key),
                          trailing: Text("${e.value}"),
                        );
                      }).toList(),
                    ],

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text("Back to Home"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}