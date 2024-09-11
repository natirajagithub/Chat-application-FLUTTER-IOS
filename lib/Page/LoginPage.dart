import 'package:chat_app/notification/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import '../Auth_service/auth_services.dart';
import '../Componants/Buttons.dart';
import '../Componants/My_TextField.dart';
import '../Page/HomePage.dart';
import 'Email-reset-password.dart'; // Import your Home Page


Future<void>_firebaseMessagingBackgroundHandler(RemoteMessage message) async {

}


class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  LoginPage({Key? key, this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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

    RemoteMessage? initialMeaasge = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMeaasge!= null){
      PushNotification notification = PushNotification(
          title: initialMeaasge.notification?.title??'',
          body: initialMeaasge.notification?.body??'',
          dataTitle: initialMeaasge.data['title']??'',
          dataBody: initialMeaasge.data['body']??''
      );
      setState(() {
        _notificationInfo = notification;
        totalNotification++;
      });
    }
  }

  @override
  void initState() {

    totalNotification =0;
    registerNotification();
    checkForInitializeMessage();

    // TODO: implement initState
    super.initState();
  }






  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  void login(BuildContext context) async {
    final authService = AuthService();
    try {
      // Attempt to sign in
      await authService.signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);

      // If sign-in is successful, navigate to Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Replace with your actual Home Page widget
      );
    } catch (e) {
      // Show error dialog if sign-in fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Login Failed"),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ForgotPasswordDialog(
          _handleRecoveryMethod,
        );
      },
    );
  }

  void _handleRecoveryMethod(BuildContext context, String method) {
    Navigator.pop(context); // Close previous dialog
    if (method == 'email') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmailRecoveryScreen()),
      );
    } else if (method == 'phone') {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image widget instead of Icon
              Image.asset(
                'assets/images/account.png', // Replace with your image path
                width: 100,  // Adjust width as needed
                height: 100, // Adjust height as needed
              ),
              SizedBox(height: 10),
              Text(
                'Welcome to the Chat Mate',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 50),
              MyTextfield(
                hintText: 'Email',
                obscureText: false,
                controller: _emailController,
              ),
              SizedBox(height: 10),
              MyTextfield(
                hintText: 'Password',
                obscureText: true,
                controller: _passwordController,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 202),
                child: TextButton(
                  onPressed: () {
                     _showForgotPasswordDialog(context);
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(height: 10),
              MyButton(
                text: 'Login',
                onTap: () => login(context),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Not a member?"),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      " Register Now",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//=---------------------------------------------------------------------------------------

class ForgotPasswordDialog extends StatelessWidget {
  final Function(BuildContext, String) handleRecoveryMethod;

  ForgotPasswordDialog(this.handleRecoveryMethod);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Forgot Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Email'),
            onTap: () {
              handleRecoveryMethod(context, 'email');
            },
          ),
          ListTile(
            leading: Icon(Icons.mobile_friendly_rounded),
            title: Text('Phone'),
            onTap: () {
              handleRecoveryMethod(context, 'phone');
            },
          ),
        ],
      ),
    );
  }
}
