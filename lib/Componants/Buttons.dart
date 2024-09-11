import 'package:flutter/cupertino.dart';

class MyButton extends StatelessWidget {

 final void Function()? onTap;
 final String text;

 MyButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration:  BoxDecoration(color:  CupertinoColors.activeBlue, borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Center(

         child: Text(text, ),

        ),
      ),
    );
  }
}
