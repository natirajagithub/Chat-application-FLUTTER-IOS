// class Group {
//   final String id;
//   final String name;
//   final List<String> members;
//
//   Group({required this.id, required this.name, required this.members});
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'members': members,
//     };
//   }
//
//   factory Group.fromMap(Map<String, dynamic> map) {
//     return Group(
//       id: map['id'],
//       name: map['name'],
//       members: List<String>.from(map['members']),
//     );
//   }
// }
