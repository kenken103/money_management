import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color backcolor;
  final Color forecolor;
  final double height;
  final double width;
  final VoidCallback onPressed;
  final Widget child;

  const CustomButton({
    Key? key,
    required this.backcolor,
    required this.forecolor,
    required this.height,
    required this.width,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backcolor,
          foregroundColor: forecolor,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
