import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;

    return Container(
      width: sizeX,
      height: sizeY,
      color: Colors.black,
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          color: Colors.white,
          // height: 75,
          // width: 202,
          height: sizeY / 10.5,
          width: sizeX / 1.95,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
