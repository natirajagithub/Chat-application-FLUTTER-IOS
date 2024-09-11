import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'AudioPreviewPage.dart';
import 'image preview.dart';
import 'videoPreviepage.dart';
import 'pdf.dart';

class ChatPage extends StatefulWidget {
  final String receiverID;
  final String receiverEmail;

  ChatPage({required this.receiverID, required this.receiverEmail, required email});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  File? pdfFile;
  File? audioFile;
  File? videoFile;
  bool isLoading = false;

  String get truncatedEmail {
    const int maxLength = 8;
    if (widget.receiverEmail.length > maxLength) {
      return widget.receiverEmail.substring(0, maxLength) + '...';
    } else {
      return widget.receiverEmail;
    }
  }

  void sendMessage({String? imagePath, String? documentPath, String? audioPath, String? videoPath}) async {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty || imagePath != null || documentPath != null || audioPath != null || videoPath != null) {
      String senderID = _auth.currentUser!.uid;
      DocumentReference messageRef = await _firestore.collection('messages').add({
        'senderID': senderID,
        'receiverID': widget.receiverID,
        'message': messageText,
        'timestamp': Timestamp.now(),
        'status': 'sent',
        'participants': [senderID, widget.receiverID],
      });

      if (imagePath != null) {
        File imageFile = File(imagePath);
        String imageName = messageRef.id + '-image';
        Reference storageReference = FirebaseStorage.instance.ref().child('images/$imageName');
        UploadTask uploadTask = storageReference.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        await messageRef.update({'imagePath': imageUrl});
      }

      if (documentPath != null) {
        File documentFile = File(documentPath);
        String documentName = messageRef.id + '-document';
        Reference storageReference = FirebaseStorage.instance.ref().child('documents/$documentName');
        UploadTask uploadTask = storageReference.putFile(documentFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String documentUrl = await taskSnapshot.ref.getDownloadURL();
        await messageRef.update({'documentPath': documentUrl});
      }

      if (audioPath != null) {
        File audioFile = File(audioPath);
        String audioName = messageRef.id + '-audio';
        Reference storageReference = FirebaseStorage.instance.ref().child('audios/$audioName');
        UploadTask uploadTask = storageReference.putFile(audioFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String audioUrl = await taskSnapshot.ref.getDownloadURL();
        await messageRef.update({'audioPath': audioUrl});
      }

      if (videoPath != null) {
        File videoFile = File(videoPath);
        String videoName = messageRef.id + '-video';
        Reference storageReference = FirebaseStorage.instance.ref().child('videos/$videoName');
        UploadTask uploadTask = storageReference.putFile(videoFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String videoUrl = await taskSnapshot.ref.getDownloadURL();
        await messageRef.update({'videoPath': videoUrl});
      }

      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          actions: <Widget>[
            TextButton(
              child: Text('Camera'),
              onPressed: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  sendMessage(imagePath: image.path);
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  sendMessage(imagePath: image.path);
                }
              },
            ),
          ],
        );
      },
    );
  }




  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      sendMessage(documentPath: result.files.single.path);
    }
  }

  Future<void> _pickAudio() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      // Implement audio recording functionality
      String audioPath = ''; // Replace with actual audio file path
      sendMessage(audioPath: audioPath);
    } else {
      print('Microphone permission denied');
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      sendMessage(videoPath: video.path);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _updateMessageStatusToDelivered();
  }

  void _updateMessageStatusToDelivered() {
    String currentUserID = _auth.currentUser!.uid;
    _firestore
        .collection('messages')
        .where('receiverID', isEqualTo: currentUserID)
        .where('status', isEqualTo: 'sent')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'status': 'delivered'});
      });
    });
  }

  void _updateMessageStatusToSeen(DocumentSnapshot message) {
    if (message['status'] != 'seen') {
      message.reference.update({'status': 'seen'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: _pickImage
                 // Adjust padding as needed
              ),
              IconButton(
                icon: Icon(Icons.qr_code),
                onPressed: (){}
                // _scanQR,
                // padding: EdgeInsets.symmetric(horizontal: 4.0), // Adjust padding as needed
              ),
              PopupMenuButton(
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.group_add_outlined),
                      title: Text('New group'),
                      onTap: () {
                        // _createGroup();
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.delete_sweep),
                      title: Text('Clear Chat'),
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
        backgroundColor: Color(0xFF6CBC99),
        title: Text(truncatedEmail),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String currentUserID = _auth.currentUser!.uid;
    return StreamBuilder(
      stream: _firestore
          .collection('messages')
          .where('participants', arrayContains: currentUserID)
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No messages found.'));
        }

        List<DocumentSnapshot> messages = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return (data['senderID'] == currentUserID && data['receiverID'] == widget.receiverID) ||
              (data['senderID'] == widget.receiverID && data['receiverID'] == currentUserID);
        }).toList();

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            final data = message.data() as Map<String, dynamic>;
            bool isSentByMe = data['senderID'] == _auth.currentUser!.uid;

            return Align(
              alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75, // Limit message width
                ),
                child: _buildMessageWidget(data, isSentByMe),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageWidget(Map<String, dynamic> data, bool isSentByMe) {
    Widget messageContent;

    if (data.containsKey('imagePath') && data['imagePath'] != null) {
      messageContent = InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImagePreviewPage(imageUrl: data['imagePath']),
            ),
          );
        },
        child: Image.network(
          data['imagePath'],
          fit: BoxFit.cover,
        ),
      );
    } else if (data.containsKey('documentPath') && data['documentPath'] != null) {
      messageContent = InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerPage(pdfUrl: data['documentPath'], uri: '', name: '',),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red[400],),
            SizedBox(width: 20),
            Text('View PDF', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          ],
        ),
      );
    } else if (data.containsKey('audioPath') && data['audioPath'] != null) {
      messageContent = InkWell(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AudioPreviewPage(audioUrl: data['audioPath']),
          //   ),
          // );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.audiotrack),
            SizedBox(width: 5),
            Text('Play Audio', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          ],
        ),
      );
    } else if (data.containsKey('videoPath') && data['videoPath'] != null) {
      messageContent = InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPreviewPage(videoUrl: data['videoPath']),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam),
            SizedBox(width: 5),
            Text('Play Video', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          ],
        ),
      );
    } else {
      messageContent = Text(data['message'] ?? '');
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Add margin for spacing
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSentByMe ? Color(0xFF50886D) : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          messageContent,
          SizedBox(height: 5), // Add some spacing between content and timestamp
          Text(
            _formatTimestamp(data['timestamp']),
            style: TextStyle(fontSize: 10, color: isSentByMe ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.image),
                        title: Text('Image'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.picture_as_pdf),
                        title: Text('Document'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickDocument();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.audiotrack),
                        title: Text('Audio'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickAudio();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.videocam),
                        title: Text('Video'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickVideo();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => sendMessage(),
          ),
        ],
      ),
    );
  }
}