
import 'dart:developer';

import 'package:chatapp/models/bottom.dart';
import 'package:chatapp/models/bottomMenu.dart';
import 'package:chatapp/pages/OnBoardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import '../Auth/auth.dart';



//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');

        APIs.fetchFieldValue();

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) =>  BottomBar()));
      }

      else {
        
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const OnBoardingScreen()));
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {

    mq = MediaQuery.of(context).size;

    return  Scaffold(
 
      body: Stack(children: [
 
        Positioned(
            top: mq.height * .35,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('assets/images/icon.png')),

        
        Positioned(
            bottom: mq.height * .10,
            width: mq.width,
            child: const Text(' ',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.black87, letterSpacing: .5))),
      ]),
    );
  }
}
