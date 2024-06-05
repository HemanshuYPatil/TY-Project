import 'package:flutter/material.dart';
import 'package:awesome_otp_screen/awesome_otp_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otp = '';

  Future<String> validateOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (otp == "123456") {
      return "Done";
    } else {
      return "The entered Otp is wrong";
    }
  }

  void moveToNextScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/nextScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: AwesomeOtpScreen.withGradientBackground(
            topColor: Colors.green.shade200,
            bottomColor: Colors.greenAccent.shade700,
            otpLength: 4,
            validateOtp: validateOtp,
            routeCallback: (BuildContext context) => moveToNextScreen(context),
            // Pass context to routeCallback
            themeColor: Colors.white,
            titleColor: Colors.white,
            title: "Phone Number Verification",
            subTitle: "Enter the code sent to \n +880170020020",
            // icon: Image.asset(
            //   'assets/images/phone_logo.png',
            //   fit: BoxFit.fill,
            // ),
          ),
        ),
      ),
    );
  }
}

class NextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Screen'),
      ),
      body: Center(
        child: Text('This is the next screen!'),
      ),
    );
  }
}
