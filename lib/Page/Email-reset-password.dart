import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailRecoveryScreen extends StatefulWidget {
  @override
  _EmailRecoveryScreenState createState() => _EmailRecoveryScreenState();
}

class _EmailRecoveryScreenState extends State<EmailRecoveryScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isSendingCode = false;

  void _sendPasswordResetEmail(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSendingCode = true;
      });

      String email = emailController.text.trim();

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to $email \n please check your email and login'),
            duration: Duration(seconds: 5),
          ),
        );

      } catch (e) {
        print("Error sending password reset email: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending reset email. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        isSendingCode = false;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // You can add more advanced email validation here if needed
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Email Recovery', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF64B5F6), // Light Blue
              Color(0xFF1976D2), // Dark Blue
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 180,
                  child: Image.asset(
                    "assets/images/account.png", // Adjust image path as per your project
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 30.0, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Text(
                  'Enter your email to receive a password reset link',
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: _validateEmail,
                  ),
                ),
                SizedBox(height: 20.0),
                _buildSendCodeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendCodeButton() {
    return ElevatedButton(
      onPressed: isSendingCode ? null : () => _sendPasswordResetEmail(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        isSendingCode ? 'Sending Code...' : 'Send Code',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
