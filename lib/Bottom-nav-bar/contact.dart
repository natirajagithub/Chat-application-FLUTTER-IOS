import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const ContactsPage({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts:', style: TextStyle(color: Colors.white),),

        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: users.isNotEmpty ? _buildContactsList() : _buildNoContactsMessage(),
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final email = user['email'] ?? '';
        final displayName = user['displayName'] ?? '';

        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blueGrey,
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          title: Text(
            displayName.isNotEmpty ? displayName : email,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          onTap: () {
            // Handle contact tap
          },
        );
      },
    );
  }

  Widget _buildNoContactsMessage() {
    return Center(
      child: Text(
        'No contacts available',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
