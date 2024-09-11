// Import necessary packages and components
import 'package:flutter/material.dart';
import '../Componants/Buttons.dart';
import '../Componants/My_TextField.dart';
import '../Auth_service/auth_services.dart';

class Registerpage extends StatefulWidget {
  final void Function()? onTap;

  Registerpage({Key? key, this.onTap}) : super(key: key);

  @override
  _RegisterpageState createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cPasswordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void register() async {
    final auth = AuthService();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_passwordController.text == _cPasswordController.text) {
      try {
        await auth.signUpWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
          '', // Provide a default name or get it from another input
          '', // Provide a default photoUrl or get it from another input
        );
        // Navigate to another page or show success message
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = "Passwords don't match";
        _isLoading = false;
      });
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

              // Welcome message
              Text(
                "Let's create an Account",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 50),

              // Email TextField
              MyTextfield(
                hintText: 'Email',
                obscureText: false,
                controller: _emailController,
              ),
              SizedBox(height: 10),

              // Password TextField
              MyTextfield(
                hintText: 'Password',
                obscureText: true,
                controller: _passwordController,
              ),
              SizedBox(height: 10),

              // Confirm Password TextField
              MyTextfield(
                hintText: 'Confirm Password',
                obscureText: true,
                controller: _cPasswordController,
              ),
              SizedBox(height: 10),

              // Register Button
              _isLoading
                  ? CircularProgressIndicator()
                  : MyButton(
                text: 'Register',
                onTap: register,
              ),
              SizedBox(height: 25),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),

              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      " Login Now",
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
