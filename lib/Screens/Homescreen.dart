import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.school_outlined),
          iconSize: 40,
          onPressed: () {},
        ),
        //Image(image: AssetImage('assets/images/splashscreenpic.png')),
      ),
    );
  }
}
