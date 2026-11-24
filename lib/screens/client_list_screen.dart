import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'client_profile_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List<Map<String, dynamic>> _clients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    try {
      final clients = await DatabaseHelper.instance.getClients();

      if (!mounted) return;

      setState(() {
        _clients = clients;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Client fetch error: $e");

      if (!mounted) return;

      setState(() {
        _clients = [];
        _loading = false;
      });
    }
  }

  Future<void> _deleteClient(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Client'),
        content: const Text('Are you sure you want to remove this client?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          )
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteClient(id);
      _fetchClients();
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No clients found.\nAdd a client from the Home Screen.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    // FIXED column names to match database_helper.dart
    final name = client['fullName'] ?? '';
    final email = client['email'] ?? 'No email';
    final phone = client['phoneNumber'] ?? '';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClientProfileScreen(client: client),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blueAccent,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '$email\n$phone',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        isThreeLine: true,

        // PATCHED DELETE BUTTON
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            final id = client['id'];
            if (id != null) {
              _deleteClient(id);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _clients.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchClients,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _clients.length,
                    itemBuilder: (context, index) =>
                        _buildClientCard(_clients[index]),
                  ),
                ),
    );
  }
}