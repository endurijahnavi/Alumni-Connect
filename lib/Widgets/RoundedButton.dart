import 'package:flutter/material.dart';
import 'package:appdevproject/Constants/Constants.dart';

class RoundedButton extends StatelessWidget {
  final String btnText;
  final VoidCallback onBtnPressed;

  const RoundedButton(
      {Key? key, required this.btnText, required this.onBtnPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      color: Color.fromRGBO(82, 184, 206, 100),
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        onPressed: onBtnPressed,
        minWidth: 320,
        height: 60,
        child: Text(
          btnText,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
