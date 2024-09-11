import 'dart:io';
// import 'package:chat_app/Bottom-nav-bar/status-view/image_view_page.dart'; // Ensure this import is correct
import 'package:chat_app/Bottom-nav-bar/status-view/status-view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class StatusPage extends StatefulWidget {
  final List<Map<String, dynamic>> users;

  const StatusPage({
    Key? key,
    required this.users,
    required String currentUserEmail,
  }) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<File>? _imageFiles;
  List<String>? _imageUrls;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final ImagePicker _picker = ImagePicker();
  late Stream<QuerySnapshot> _statusStream;

  @override
  void initState() {
    super.initState();
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null || currentUserEmail.isEmpty) {
      print('Error: Current user email is empty.');
      return;
    }

    _statusStream = FirebaseFirestore.instance
        .collection('status')
        .orderBy('timestamp', descending: true)
        .snapshots();

    _loadCurrentUserStatus();
  }

  Future<void> _loadCurrentUserStatus() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail == null || currentUserEmail.isEmpty) {
      print('Current user email is empty.');
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('status').doc(currentUserEmail).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        setState(() {
          _imageUrls = List<String>.from(data['imageUrls'] ?? []);
        });
      }
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _imageFiles = pickedFiles.map((file) => File(file.path)).toList();
      });

      await _uploadImages();
    }
  }

  Future<void> _uploadImages() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (_imageFiles == null || _imageFiles!.isEmpty || currentUserEmail == null || currentUserEmail.isEmpty) {
      print('No images selected or current user email is empty.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    List<String> imageUrls = [];

    try {
      for (File imageFile in _imageFiles!) {
        final String fileName = basename(imageFile.path);
        final Reference storageRef = FirebaseStorage.instance.ref().child('status_images').child(fileName);

        final UploadTask uploadTask = storageRef.putFile(imageFile);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          setState(() {
            _uploadProgress = progress;
          });
          print("Upload is $progress% complete");
        });

        final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        imageUrls.add(downloadUrl);
      }

      setState(() {
        _imageUrls = imageUrls;
      });

      await FirebaseFirestore.instance.collection('status').doc(currentUserEmail).set({
        'email': currentUserEmail,
        'imageUrls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'isUploaded': true,
      });

    } catch (e) {
      print("Error uploading images: $e");
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6CBC99),
        title: Text("Status"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (currentUserEmail != null && currentUserEmail.isNotEmpty) ...[
              _buildCurrentUserStatus(context),
              SizedBox(height: 16.0),
            ],
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _statusStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildNoUsersMessage();
                  }

                  final statusDocs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: statusDocs.length,
                    itemBuilder: (context, index) {
                      final status = statusDocs[index].data() as Map<String, dynamic>;
                      final email = status['email'] ?? '';
                      final imageUrls = List<String>.from(status['imageUrls'] ?? []);
                      final isUploaded = status['isUploaded'] ?? false;

                      return ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.black,
                              child: imageUrls.isNotEmpty
                                  ? CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(imageUrls[0]),
                                backgroundColor: Colors.transparent,
                              )
                                  : Text(
                                email.isNotEmpty ? email[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (isUploaded)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        onTap: () {
                          print('Tapped on user: $email'); // Debug log
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ImageViewPage(
                                imageUrls: imageUrls,
                                email: email,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            if (_isUploading)
              LinearProgressIndicator(
                value: _uploadProgress / 100,
                color: Colors.green,
                backgroundColor: Colors.grey[200],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildCurrentUserStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.black,
                  child: _imageUrls != null && _imageUrls!.isNotEmpty
                      ? CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(_imageUrls![0]),
                    backgroundColor: Colors.transparent,
                  )
                      : Text(
                    FirebaseAuth.instance.currentUser?.email?.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: _pickImages,
                    icon: Icon(
                      Icons.add_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Text(
              'My Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 9.0),
        Divider(
          thickness: 2.5,
          color: Colors.grey[300],
        ),
        SizedBox(height: 0.0),
        Text(
          'Recent update',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF138019),
          ),
        ),
        Divider(
          thickness: 1.0,
          color: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildNoUsersMessage() {
    return Center(
      child: Text(
        'No users available',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
