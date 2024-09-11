import 'package:chat_app/Auth_service/auth_services.dart';
import 'package:chat_app/Page/Login_or-Regiaster.dart';
import 'package:chat_app/Page/SettingsPage.dart';
import 'package:flutter/material.dart';

import '../Page/LoginPage.dart';

class Mydrawer extends StatelessWidget {
  const Mydrawer({Key? key}) : super(key: key);

  Future<void> logout(BuildContext context) async {
    final auth = AuthService();
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginOrRagister()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().getCurrentUser();

    String? email = user?.email;
    String? displayName = user?.displayName;
    String? photoURL = user?.photoURL;

    // Determine the initial to display
    String initial = 'U'; // Default initial if no user info available
    if (displayName != null && displayName.isNotEmpty) {
      initial = displayName[0].toUpperCase();
    } else if (email != null && email.isNotEmpty) {
      initial = email[0].toUpperCase();
    }

    // Determine avatar content based on user info
    Widget avatarChild;
    if (photoURL != null) {
      // Display user's profile picture
      avatarChild = CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(photoURL),
        backgroundColor: Colors.white,
      );
    } else {
      // Display default avatar with user's initial
      avatarChild = CircleAvatar(
        radius: 30,
        backgroundColor: Colors.black, // Background color of the circle
        child: Text(
          initial,
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      );
    }

    return Drawer(
      backgroundColor: Color(0xFF758C81),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // User information
              DrawerHeader(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      avatarChild,
                      SizedBox(height: 10),
                      Text(
                        email ?? 'No email',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              // Home list tile
              ListTile(
                title: Text("H O M E"),
                leading: Icon(Icons.home, color: Colors.white),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Settings list tile
              ListTile(
                title: Text("S E T T I N G S", style: TextStyle(color: Colors.white)),
                leading: Icon(Icons.settings, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingPage()),
                  );
                },
              ),

              // Logout list tile
              ListTile(
                title: Text("L O G O U T", style: TextStyle(color: Colors.white)),
                leading: Icon(Icons.logout, color: Colors.white),
                onTap: () => logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
