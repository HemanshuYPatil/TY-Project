import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerDetails extends StatefulWidget {
  const SellerDetails({Key? key}) : super(key: key);

  @override
  State<SellerDetails> createState() => _SellerDetailsState();
}

class _SellerDetailsState extends State<SellerDetails> {
  final name = TextEditingController();
  final lastname = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  final shopname = TextEditingController();
  final pincode = TextEditingController();
  final state = TextEditingController();
  final otp = TextEditingController();
  int currentstep = 0;
  bool isContinuePressed = false;
  late String verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Details'),
        centerTitle: true,
      ),
      body: Stepper(
        type: StepperType.horizontal, // or StepperType.vertical
        currentStep: currentstep,
        steps: getSteps(), // pass array list of Step widgets
        onStepContinue: () {
          if (currentstep < (getSteps().length - 1)) {
            setState(() {
              currentstep += 1;
            });
          } else {
            print('Submited');
          }
        },
        onStepCancel: () {
          if (currentstep == 0) {
            return;
          }

          setState(() {
            currentstep -= 1;
          });
        },
        onStepTapped: (int index) {
          setState(() {
            currentstep = index;
          });
        },
      ),
    );
  }

  Future<void> _sendOTP() async {
    String phoneNumber = "+91${phone.text}"; // Add your country code
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('Complete');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Failed to verify phone number: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        print('OTP sent to $phoneNumber');
        this.verificationId = verificationId; // Store verification ID
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Auto retrieval timeout: $verificationId');
      },
      timeout: Duration(seconds: 60), // Adjust timeout as needed
    );
  }

  Future<void> _verifyOTP() async {
    String smsCode = otp.text;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      print('OTP Verified');
    } catch (e) {
      print('Failed to verify OTP: $e');
    }
  }

  List<Step> getSteps() {
    return <Step>[
      Step(
        state: currentstep <= 0 ? StepState.editing : StepState.complete,
        isActive: currentstep >= 0,
        title: const Text('Account'),
        content: Container(
          child: Column(
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Full Name',
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: lastname,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: phone,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
          state: currentstep <= 1 ? StepState.editing : StepState.complete,
          isActive: currentstep >= 1,
          title: const Text('Address'),
          content: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: address,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Full House Address',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: pincode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Pin Code',
                  ),
                ),
              ],
            ),
          )
      ),
      Step(
          state: StepState.complete,
          isActive: currentstep >= 2,
          title: const Text('Confirm'),
          content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Name: ${name.text}'),
                  Text('Email: ${lastname.text}'),
                  const Text('Password: *****'),
                  Text('Address : ${address.text}'),
                  Text('PinCode : ${pincode.text}'),
                ],
              )))
    ];
  }
}
