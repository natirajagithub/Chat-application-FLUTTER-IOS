import 'package:chat_app/Page/Login_or-Regiaster.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../Page/HomePage.dart';
import '../notification/notification.dart';


Future<void>_firebaseMessagingBackgroundHandler(RemoteMessage message) async {

}


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {






  User? user;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // @override
  // void initState() {
  //   super.initState();
  //   // _searchController.addListener(_filterUsers); // Listen to text changes
  //   // _fetchUsers();
  //
  //
  // }


  late FirebaseMessaging _messaging;
  int totalNotification = 0;
  late PushNotification _notificationInfo;

  void registerNotification() async{
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    NotificationSettings settings  = await _messaging.requestPermission(
        badge: true,
        provisional: true,
        sound: true,
        alert: true
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){

      FirebaseMessaging.onMessage.listen((RemoteMessage message){
        print("message title: ${message.notification?.title}");

        PushNotification notification = PushNotification(
            title: message.notification?.title??'',
            body: message.notification?.body??'',
            dataTitle: message.data['title']??'',
            dataBody: message.data['body']??''
        );

        setState(() {
          _notificationInfo = notification;
          totalNotification++;
        });

        if(_notificationInfo !=null){
          showSimpleNotification(
            Text(_notificationInfo.title),
            subtitle: Text(_notificationInfo.body ?? ''),
            background: Colors.cyan,
            duration:  Duration(seconds: 2),
          );
        }

      });
    }
    else{
      print("User declained or has not been accepted permission");
    }
  }
  checkForInitializeMessage() async{
    await Firebase.initializeApp();

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage!= null){
      PushNotification notification = PushNotification(
          title: initialMessage.notification?.title??'',
          body: initialMessage.notification?.body??'',
          dataTitle: initialMessage.data['title']??'',
          dataBody: initialMessage.data['body']??''
      );
      setState(() {
        _notificationInfo = notification;
        totalNotification++;
      });
    }
  }

  @override
  void initState() {

    user = FirebaseAuth.instance.currentUser;
    _firebaseMessaging.getToken().then((token){
      print("FIREBASE TOKEN : $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      print("Received Message: ${message.notification?.body}");
    });



    totalNotification =0;
    registerNotification();
    checkForInitializeMessage();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      PushNotification notification=PushNotification(
          title: message.notification?.title?? '',
          body: message.notification?.body??'',
          dataTitle: message.data['title']??'',
          dataBody: message.data['body']??'');

      setState(() {
        _notificationInfo = notification;
        totalNotification++;
      });
    });

    // TODO: implement initState
    super.initState();
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){

          if(snapshot.hasData){

            return  HomePage();
          }
          else{
            return const LoginOrRagister();
          }

        },
      ),
    );
  }
}
