import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {

  final String hintText;
  final bool obscureText;
  final TextEditingController controller;


  const MyTextfield({super.key, required this.hintText, required this.obscureText, required this.controller, });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
              focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green)
        ),
          hintText: hintText,


        ),
      ),
    );
  }
}
