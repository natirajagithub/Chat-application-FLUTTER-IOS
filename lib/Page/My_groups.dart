// import 'package:flutter/material.dart';
//
// import 'Groups.dart';
//
// class GroupCreationScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> allUsers;
//   final void Function(List<Map<String, dynamic>>) onCreateGroup;
//
//   const GroupCreationScreen({
//     Key? key,
//     required this.allUsers,
//     required this.onCreateGroup,
//   }) : super(key: key);
//
//   @override
//   _GroupCreationScreenState createState() => _GroupCreationScreenState();
// }
//
// class _GroupCreationScreenState extends State<GroupCreationScreen> {
//   final List<Map<String, dynamic>> _selectedUsers = [];
//
//   void _toggleUserSelection(Map<String, dynamic> user) {
//     setState(() {
//       if (_selectedUsers.contains(user)) {
//         _selectedUsers.remove(user);
//       } else {
//         _selectedUsers.add(user);
//       }
//     });
//   }
//
//   void _createGroupAndNavigate(BuildContext context) {
//     if (_selectedUsers.isNotEmpty) {
//       // Create the group (for demonstration, just passing selected users)
//       widget.onCreateGroup(_selectedUsers);
//
//       // Navigate to a new page (CreatedGroupPage) to display the created group
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => GroupCreationScreen(allUsers: [], onCreateGroup: (List<Map<String, dynamic>> ) {  },),
//         ),
//       );
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('Please select at least one user.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueGrey,
//         title: Text('Create Group'),
//         actions: [
//           TextButton(
//             onPressed: () => _createGroupAndNavigate(context),
//             child: Text(
//               'Create',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: widget.allUsers.length,
//         itemBuilder: (context, index) {
//           final user = widget.allUsers[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Card(
//               elevation: 2.0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: CheckboxListTile(
//                 title: Text(
//                   user['email'],
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 // subtitle: Text(
//                 //   'User ID: ${user['uid']}',
//                 //   style: TextStyle(
//                 //     fontSize: 14.0,
//                 //     color: Colors.grey[600],
//                 //   ),
//                 // ),
//                 secondary: CircleAvatar(
//                   backgroundColor: Colors.blueGrey,
//                   child: Icon(
//                     Icons.person,
//                     color: Colors.white,
//                   ),
//                 ),
//                 value: _selectedUsers.contains(user),
//                 onChanged: (bool? value) {
//                   _toggleUserSelection(user);
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
