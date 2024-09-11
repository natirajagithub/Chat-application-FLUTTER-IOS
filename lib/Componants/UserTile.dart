import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {

  final String email;
  final String? lastMessage; // Nullable last message
  final void Function()? onTap;

  const UserTile({
    Key? key,
    required this.email,
    this.lastMessage,
    this.onTap, required bool unreadMessagecount,
  }) : super(key: key);

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {



  @override
  Widget build(BuildContext context) {

    String currentTime = _getCurrentTime();

    return GestureDetector(
      onTap: () {

        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content at the top
          children: [
            // Circle Avatar with capitalized first letter of the email
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              child: Text(
                widget.email[0].toUpperCase(), // Capitalize the first letter
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Column with email and last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _truncateEmail(widget.email), // Truncated email with ellipses
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentTime, // Placeholder default time (current time)
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400], // Lighter color for default time
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4), // Spacer between email and dummy text
                  Text(
                    'hey! i am using this chat App..', // Placeholder dummy text
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500], // Lighter color for dummy text
                    ),
                  ),
                  if (widget.lastMessage != null) // Conditionally show last message
                    Text(
                      widget.lastMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }

  String _truncateEmail(String email) {
    const int maxLength = 10; // Maximum characters before truncating
    if (email.length > maxLength) {
      return '${email.substring(0, maxLength)}...';
    } else {
      return email;
    }
  }

  String _getCurrentTime() {
    // Replace this with your preferred way of formatting the current time
    DateTime now = DateTime.now();
    String formattedTime = '${now.hour}:${now.minute}';
    return formattedTime;
  }
}