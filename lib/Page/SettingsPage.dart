import 'package:chat_app/Auth_service/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingPage extends StatelessWidget {
  SettingPage({Key? key}) : super(key: key);

  final AuthService _authService = AuthService();

  Future<void> _changePassword(BuildContext context) async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Current Password"),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "New Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String currentPassword = currentPasswordController.text;
                String newPassword = newPasswordController.text;

                if (currentPassword.isEmpty || newPassword.isEmpty) {
                  Fluttertoast.showToast(msg: "Please fill in both fields.");
                  return;
                }

                try {
                  await _authService.updatePassword(currentPassword, newPassword);
                  Fluttertoast.showToast(msg: "Password updated successfully.");
                  Navigator.of(context).pop(); // Close the dialog
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'wrong-password') {
                    Fluttertoast.showToast(msg: "Current password is incorrect.");
                  } else {
                    Fluttertoast.showToast(msg: "Failed to update password: ${e.message}");
                  }
                } catch (e) {
                  Fluttertoast.showToast(msg: "Failed to update password: ${e.toString()}");
                }
              },
              child: Text("Change"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await user.delete();
        Fluttertoast.showToast(msg: "Account deleted successfully.");
        Navigator.of(context).pushReplacementNamed('/login'); // Redirect to login page
      } else {
        Fluttertoast.showToast(msg: "No user currently signed in.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete account: ${e.toString()}");
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login'); // Redirect to login page
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to sign out: ${e.toString()}");
    }
  }

  Future<void> _editAvatar(BuildContext context) async {
    Fluttertoast.showToast(msg: "Avatar editing feature not implemented.");
  }

  Future<void> _editPrivacy(BuildContext context) async {
    Fluttertoast.showToast(msg: "Privacy settings feature not implemented.");
  }

  Future<void> _editNotifications(BuildContext context) async {
    Fluttertoast.showToast(msg: "Notification settings feature not implemented.");
  }

  Future<void> _changeLanguage(BuildContext context) async {
    Fluttertoast.showToast(msg: "App language settings feature not implemented.");
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();
    final email = user?.email;
    final displayName = user?.displayName;
    final photoURL = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Profile Section
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black,
                backgroundImage: photoURL != null
                    ? NetworkImage(photoURL)
                    : null,
                child: photoURL == null
                    ? Text(
                  email != null && email.isNotEmpty
                      ? email[0].toUpperCase()
                      : '?',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                )
                    : null,
              ),
              title: Text(displayName ?? 'User'),
              subtitle: Text(email ?? 'No email'),
              trailing: Icon(Icons.edit),
              onTap: () {
                Fluttertoast.showToast(msg: "Profile editing feature not implemented.");
              },
            ),
          ),

          // Change Password
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text("Change Password"),
              leading: Icon(Icons.lock),
              onTap: () => _changePassword(context),
            ),
          ),

          // Delete Account
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text("Delete Account"),
              leading: Icon(Icons.delete),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Delete Account"),
                      content: Text("Are you sure you want to delete your account? This action cannot be undone."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteAccount(context);
                          },
                          child: Text("Delete"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Logout
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text("Logout"),
              leading: Icon(Icons.logout),
              onTap: () async {
                await _logout(context);
              },
            ),
          ),

          // Privacy Settings
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text("Privacy Settings"),
              leading: Icon(Icons.privacy_tip),
              onTap: () => _editPrivacy(context),
            ),
          ),

          // Notifications Settings
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text("Notification Settings"),
              leading: Icon(Icons.notifications_active),
              onTap: () => _editNotifications(context),
            ),
          ),

          // App Language Settings
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text("App Language"),
              leading: Icon(Icons.language),
              onTap: () => _changeLanguage(context),
            ),
          ),
        ],
      ),
    );
  }
}
