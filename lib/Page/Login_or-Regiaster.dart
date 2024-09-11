import 'package:chat_app/Page/LoginPage.dart';
import 'package:chat_app/Page/RegisterPage.dart';
import 'package:flutter/cupertino.dart';

class LoginOrRagister extends StatefulWidget {
  const LoginOrRagister({super.key});

  @override
  State<LoginOrRagister> createState() => _LoginOrRagisterState();
}

class _LoginOrRagisterState extends State<LoginOrRagister> {

  // initially , show login paage
  bool showLoginPage = true;

  // loggle between login and register

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return Registerpage(
        onTap: togglePages,
      );
    }
  }
}



