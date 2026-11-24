import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int totalClients = 0;
  int totalReports = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);

    loadStats();
  }

  Future<void> loadStats() async {
    final clients = await DatabaseHelper.instance.getClients();
    final reports = await DatabaseHelper.instance.getAllReports();

    setState(() {
      totalClients = clients.length;
      totalReports = reports.length;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _HomeButton(
        icon: Icons.person_add_alt_1,
        label: 'Add Client',
        onTap: () => Navigator.pushNamed(context, '/add_client'),
      ),
      _HomeButton(
        icon: Icons.people,
        label: 'Clients',
        onTap: () => Navigator.pushNamed(context, '/clients'),
      ),
      _HomeButton(
        icon: Icons.policy,
        label: 'Policies',
        onTap: () => Navigator.pushNamed(context, '/policies_info'),
      ),
      _HomeButton(
        icon: Icons.bar_chart,
        label: 'Reports',
        onTap: () => Navigator.pushNamed(context, '/all_reports'),
      ),
      _HomeButton(
        icon: Icons.settings,
        label: 'Settings',
        onTap: () => Navigator.pushNamed(context, '/settings'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final shift =
                math.sin(_controller.value * 2 * math.pi) * 0.5 + 0.5;

            final gradient = LinearGradient(
              colors: [
                Color.lerp(Colors.cyan, Colors.blue, shift)!,
                Color.lerp(Colors.blue, Colors.cyan, 1 - shift)!,
              ],
            );

            return ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(bounds),
              child: const Text(
                "E-AGENT",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome Back, Agent ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                statCard("Clients", "$totalClients", Icons.people),
                const SizedBox(width: 10),
                statCard("Reports", "$totalReports", Icons.bar_chart),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (_, i) => buttons[i],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}