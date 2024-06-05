import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Login/signin.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> splashData = [
    {
      "title": "Welcome To\n ChatApp",
      "subtitle":
          "Discover a New Way to Stay Connected",
      "image": "assets/images/boarding1.png"
    },
    {
      "title": "Chat & \n Discover",
      "subtitle":
          "Forge New Friendships in an Instant",
      "image": "assets/images/boarding2.png"
    },
    {
      "title": "Connect To\n Firends",
      "subtitle":
          "Stay Close, Even When Miles Apart",
      "image": "assets/images/boarding3.png"
    },
  ];

  AnimatedContainer _buildDots({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        color: Colors.blue,
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 9,
      curve: Curves.easeIn,
      width: _currentPage == index ? 20 : 10,
    );
  }

    void _navigateToNextPage() {
    if (_currentPage + 1 == splashData.length) {
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignInpage(),
        ),
      );
    } else {
      
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _controller,
                itemCount: splashData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          splashData[index]['title']!.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: "Sofia",
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ),
                      Text(
                        splashData[index]['subtitle']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Sofia",
                          fontSize: 15,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(
                        height: 80.0,
                      ),
                      AspectRatio(
                        aspectRatio: 12 / 9,
                        child: Image.asset(
                          splashData[index]['image']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Spacer(),
                    ],
                  );
                },
                onPageChanged: (value) => setState(() => _currentPage = value),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashData.length,
                        (int index) => _buildDots(index: index),
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      child: TextButton(
                        onPressed: () {
                        
                          _navigateToNextPage();
                        },
                       style: TextButton.styleFrom(
                        elevation: 1,
                         shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor:  Colors.blue,
                       ),
                        child: Text(
                          _currentPage + 1 == splashData.length
                              ? 'Get Started'
                              : 'Next',
                              
                          style:  const TextStyle(
                            fontSize: 14,
                            fontFamily: "Sofia",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




