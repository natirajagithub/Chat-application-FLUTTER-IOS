// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ChatUser {
//   final String userID;
//   final String email;
//   final String name;
//   final String profileImageUrl;
//   final Timestamp? lastActive;
//
//   ChatUser({
//     required this.userID,
//     required this.email,
//     required this.name,
//     required this.profileImageUrl,
//     this.lastActive,
//   });
//
//   // Factory method to create a ChatUser instance from a Firestore document snapshot
//   factory ChatUser.fromDocumentSnapshot(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return ChatUser(
//       userID: data['userID'] ?? '',
//       email: data['email'] ?? '',
//       name: data['name'] ?? '',
//       profileImageUrl: data['profileImageUrl'] ?? '',
//       lastActive: data['lastActive'] as Timestamp?,
//     );
//   }
//
//   // Method to convert ChatUser to a map for Firestore storage
//   Map<String, dynamic> toMap() {
//     return {
//       'userID': userID,
//       'email': email,
//       'name': name,
//       'profileImageUrl': profileImageUrl,
//       'lastActive': lastActive,
//     };
//   }
// }
