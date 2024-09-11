import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app/Auth_service/auth_services.dart';
import 'package:chat_app/Services__/Chat_Service.dart';
import '../Componants/UserTile.dart';
import 'ChatPage.dart';
import '../Componants/MyDrawer.dart';
import 'My_groups.dart';
import 'NavBar-page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  String _selectedButton = 'ALL'; // Variable to track selected button
  int _selectedIndex = 0; // Variable to track current tab index

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers); // Listen to text changes
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up controller
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    // Fetch users and update state outside of the build method
    final usersStream = _chatService.getUsersStream();
    usersStream.listen((users) {
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        // Update hasUnreadMessages flag for each user
        _allUsers.forEach((user) {
          user['hasUnreadMessages'] = _hasUnreadMessagesForUser(user);
        });
      });
    });
  }

  bool _hasUnreadMessagesForUser(Map<String, dynamic> user) {
    // Replace this with your logic to determine if there are unread messages
    // For demo purposes, always returns true
    return true;
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final email = user['email'].toLowerCase();
        return email.contains(query);
      }).toList();
    });
  }

  void _openCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      // Handle the picked image
      print('Image path: ${photo.path}');
      // You can display the image or upload it to a server
    }
  }

  void _createGroup() {
    // Navigator.push();
      // context,
      // MaterialPageRoute(
      //   builder: (context) => GroupCreationScreen(
      //     allUsers: _filteredUsers,
      //     onCreateGroup: (selectedUsers) {
      //       // Handle group creation logic here
      //       print('Selected users: $selectedUsers');
      //     },
      //   ),
      // ),
    // );
  }

  void _scanQR() {
    // Implement QR scanning logic here
    // Example: Navigator.pushNamed(context, '/qr_scanner');
    // Replace '/qr_scanner' with your actual route for QR scanning
    print('Scanning QR code...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF6CBC99),
        title: Text("Home"),
        centerTitle: true,
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: _openCamera,
                padding: EdgeInsets.symmetric(horizontal: 4.0), // Adjust padding as needed
              ),
              IconButton(
                icon: Icon(Icons.qr_code),
                onPressed: _scanQR,
                padding: EdgeInsets.symmetric(horizontal: 4.0), // Adjust padding as needed
              ),
              PopupMenuButton(
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.group_add_outlined),
                      title: Text('New group'),
                      onTap: () {
                        _createGroup();
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.delete_sweep),
                      title: Text('Delete Users'),
                      onTap: () {
                        // Handle delete users action
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.star_border_purple500_outlined),
                      title: Text('Starred messages'),
                      onTap: () {
                        // Handle starred messages action
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.devices_other),
                      title: Text('Linked devices'),
                      onTap: () {
                        // Handle linked devices action
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      onTap: () {
                        // Handle settings action
                      },
                    ),
                  ),
                ],
                padding: EdgeInsets.symmetric(horizontal: 8.0), // Adjust padding as needed
              ),
            ],
          ),
        ],
      ),
      drawer: Mydrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 8.0), // Reduced space between search bar and buttons
            _buildButtonRow(), // Add the row of buttons
            Expanded(
              child: _buildUserList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        child: Icon(Icons.group_add),
        backgroundColor: Color(0xFF6CBC99),
      ),
      // Integrate the CustomBottomNavigationBar
      // bottomNavigationBar: CustomBottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40.0, // Set a specific height for the container
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search users...',
          fillColor: Color(0xFFDBF6DC), // Background color
          filled: true, // Ensure this is set to true to use fillColor
          contentPadding: EdgeInsets.symmetric(vertical: 7.0), // Adjust vertical padding to reduce height
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
            borderSide: BorderSide.none, // Remove border line
          ),
        ),
        onChanged: (value) => _filterUsers(), // Call filter function on change
      ),
    );
  }

  Widget _buildButtonRow() {
    return Container(
      height: 40, // Set a specific height for the container
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStyledButton(
            text: 'ALL',
            onPressed: () {
              _handleButtonPressed('ALL');
            },
            isSelected: _selectedButton == 'ALL',
          ),
          _buildStyledButton(
            text: 'Groups',
            onPressed: () {
              _handleButtonPressed('Groups');
            },
            isSelected: _selectedButton == 'Groups',
          ),
          _buildStyledButton(
            text: 'Call',
            onPressed: () {
              _handleButtonPressed('Call');
            },
            isSelected: _selectedButton == 'Call',
          ),
        ],
      ),
    );
  }

  void _handleButtonPressed(String buttonText) {
    setState(() {
      _selectedButton = buttonText;
    });

    // Handle button actions here based on buttonText
    switch (buttonText) {
      case 'ALL':
      // Action for ALL button
        _filterUsers(); // Filter all users
        break;
      case 'Groups':
      // Action for Groups button
      // Example logic for filtering groups
        List<Map<String, dynamic>> groups =
        _allUsers.where((user) => user['isGroup'] == true).toList();
        setState(() {
          _filteredUsers = groups;
        });
        break;
      case 'Call':
      // Action for Call button
      // Example logic for filtering by call status
        List<Map<String, dynamic>> callUsers =
        _allUsers.where((user) => user['isAvailable'] == true).toList();
        setState(() {
          _filteredUsers = callUsers;
        });
        break;
      default:
        break;
    }
  }

  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              isSelected ? Color(0xFF6CBC99) : Colors.transparent),
          elevation: MaterialStateProperty.all<double>(0), // No elevation
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15.0, // Text size
            fontWeight: FontWeight.bold, // Text weight
            color: isSelected ? Colors.white : Colors.black, // Text color
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> userData = _filteredUsers[index];
        if (userData["email"] != _authService.getCurrentUser()?.email) {
          return _buildUserListItem(userData);
        } else {
          return SizedBox.shrink(); // Placeholder for current user tile
        }
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData) {
    // Determine unread message count based on your data structure
    bool unreadMessageCount = userData['hasUnreadMessages'] ?? 0;

    return UserTile(
      email: userData["email"],
      lastMessage: userData["lastMessage"], // Assuming 'lastMessage' is a field in your data structure
      // Display unread message count based on 'hasUnreadMessages'
      onTap: () {
        // Navigate to chat page on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData["email"],
              receiverID: userData['uid'], email: '',
            ),
          ),
        ).then((_) {
          // Update unread message count after returning from chat page
          // Example: You may want to update 'hasUnreadMessages' in your data structure
          setState(() {
            userData['hasUnreadMessages'] = _hasUnreadMessagesForUser(userData);
          });
        });
      }, unreadMessagecount: unreadMessageCount,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle navigation based on index
      switch (index) {
        case 0:
        // Navigate to Home
        // Example: Navigator.pushNamed(context, '/home');
          break;
        case 1:
        // Navigate to Status
        // Example: Navigator.pushNamed(context, '/status');
          break;
        case 2:
        // Navigate to Profile
        // Example: Navigator.pushNamed(context, '/profile');
          break;
        case 3:
        // Navigate to Settings
        // Example: Navigator.pushNamed(context, '/settings');
          break;
      }
    });
  }
}