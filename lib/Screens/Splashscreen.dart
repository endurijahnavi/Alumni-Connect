import 'package:appdevproject/Authentication/loginscreen.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimationIn;
  late Animation<double> _fadeAnimationOut;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Adjust the total duration as needed
    );

    _fadeAnimationIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _fadeAnimationOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve:
            Interval(0.8, 1.0), // Start fading out at 80% of the total duration
      ),
    );

    _animationController.forward();

    _navigateToAuthScreenAfterDelay();
  }

  void _navigateToAuthScreenAfterDelay() async {
    await Future.delayed(Duration(seconds: 2));
    await _animationController.reverse(); // Start the fade-out animation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(142, 170, 96, 254),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimationIn,
          child: FadeTransition(
            opacity: _fadeAnimationOut,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Alumni Connect',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
