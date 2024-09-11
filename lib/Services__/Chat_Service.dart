import 'package:chat_app/Models/Message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /*
      List<Map<String, dynamic>>

      [
      {
        'email': test@gmail.com
        'id' : ..
        }
   */



  Stream<List<Map<String, dynamic>>> getUsersStream(){
    return _firestore.collection("Users").snapshots().map((snapshot){
      return snapshot.docs.map((doc){
        final user = doc.data();

        return user;
      }
      ).toList();
    }
    );

  }

  Future<void>sendMessage( String receiverID, message) async{
    // get currect user
    final String currectUserID = _auth.currentUser!.uid;
    final String currectUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();


    // create a new mwessage

    Message newMessage = Message(
        senderID: currectUserID,
        senderEmail: currectUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp);

    // construct chst room ID with two ueers

    List<String>ids= [currectUserID, receiverID];
    ids.sort();

    String chatRoomID = ids.join('_');


    // add new message
    await _firestore
        .collection("CHAT_ROOMS")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // get messages



  }
  Stream<QuerySnapshot>getMessages(String userID, otherUserID){

    List<String>ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

}