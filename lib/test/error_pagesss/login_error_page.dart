import 'dart:ui';

import 'package:flutter/material.dart';

import 'alert_dialog.dart';

class LoginErrorPage extends StatelessWidget {
  const LoginErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: ClipPath(
          clipper: BottomCornersClipper(),
          child: AppBar(
            backgroundColor: Colors.blue,
            toolbarHeight: 120,
            centerTitle: true,
            title: Text('Login pages'),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -20,
            left: -90,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(100)),
            ),
          ),
          Positioned(
            right: -70,
            bottom: -50,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.4),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: -50,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.4),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),
          Positioned(
            left: -180,
            bottom: -90,
            child: Container(
              height: 350,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.4),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),
          Positioned(
            top: 220,
            right: 150,
            child: Text(
              'Login Fail',
              style: const TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: 15,
            child: Text(
              '401',
              style: TextStyle(fontSize: 270),
            ),
          ),
          Positioned(
            top: 80,
            right: -120,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Image.asset(
                'assets/images/401_login_error.png',
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            right: 160,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ErrorPages(),
                ));
              },
              child: Text(
                'Back',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 245,
            left: 40,
            child: Text(
              'Try again to login \n Something was wrong',
              style: TextStyle(
                fontSize: 25,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}