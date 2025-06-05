import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detailed_user_info_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _selectedRole = 'user';

  Stream<QuerySnapshot<Map<String, dynamic>>> _userStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: _selectedRole)
        .orderBy('storeName')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Home Screen')),
      body: Column(
        children: [

          // Button to switch role
          Row(
            children: [
              _RoleButton(
                label: 'User',
                isSelected: _selectedRole == 'user',
                onTap: () => setState(() => _selectedRole = 'user'),
              ),
              _RoleButton(
                label: 'Seller',
                isSelected: _selectedRole == 'seller',
                onTap: () => setState(() => _selectedRole = 'seller'),
              ),
            ],
          ),
          const Divider(height: 0),

          // List account for the role
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _userStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No $_selectedRole accounts found.'));
                }

                final docs = snapshot.data!.docs;
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final doc   = docs[i];
                    final data  = doc.data();
                    final userId = doc.id;

                    final name  = data['storeName'] as String? ?? 'Unnamed Account';
                    final email = data['email']     as String? ?? '';
                    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.lightBlue,
                        child: Text(initial, style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(name),
                      subtitle: email.isNotEmpty ? Text(email) : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailedUserInfoScreen(
                              userId: userId,
                              userData: data,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    // Change color when selected
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: isSelected ? Colors.lightBlue : Colors.lightBlue.withOpacity(0.15),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}