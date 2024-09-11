import 'package:flutter/material.dart';
import '../Auth_service/auth_services.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditingAbout = false;
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    final user = AuthService().getCurrentUser();
    _aboutController = TextEditingController(text: 'This is a sample about text.'); // Replace with actual data if available
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().getCurrentUser();

    String? email = user?.email;
    String? displayName = user?.displayName;
    String? photoURL = user?.photoURL;
    String? phoneNumber = user?.phoneNumber; // Assuming phoneNumber is available
    String? about = _aboutController.text;
    String initial = 'U';
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
      avatarChild = CircleAvatar(
        radius: 30,
        backgroundColor: Colors.black,
        child: Text(
          initial,
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      );
    }

    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      avatarChild,
                      SizedBox(height: 10),
                      Text(
                        displayName ?? 'No name',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        email ?? 'No email',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Display About information with edit functionality
              Row(
                children: [
                  Icon(Icons.info, color: Colors.black, size: 30,),
                  SizedBox(width: 10),
                  Expanded(
                    child: _isEditingAbout
                        ? TextField(
                      controller: _aboutController,
                      decoration: InputDecoration(
                        hintText: 'Enter about info',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.save, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              // Save logic here
                              _isEditingAbout = false;
                            });
                          },
                        ),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            about ?? 'No about information',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue, size: 30,),
                          onPressed: () {
                            setState(() {
                              _isEditingAbout = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Display Phone Number information

            ],
          ),
        ),
      ),
    );
  }
}
