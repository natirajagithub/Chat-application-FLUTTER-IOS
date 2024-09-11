import 'package:chat_app/notification/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'Auth_service/auth_get.dart';

@pragma('vm: entry-point')
Future<void>_firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message : ${message.messageId}");

  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  if(initialMessage!=null){
    PushNotification notification = PushNotification(
        title: initialMessage.notification?.title??'',
        body: initialMessage.notification?.body??'',
        dataTitle: initialMessage.data['title']??'',
        dataBody: initialMessage.data['body']??''
    );
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());


}

class MyApp extends StatelessWidget {




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:  false,

      home: AuthGate(),

      // home: LoginOrRagister(),
      // home: Registerpage(),
    );
  }
}
