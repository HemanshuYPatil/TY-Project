import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class Voicecall extends StatelessWidget {
  const Voicecall({Key? key, required this.callID}) : super(key: key);
  final String callID ;
  


  @override
  Widget build(BuildContext context) {
    String? user = FirebaseAuth.instance.currentUser!.displayName;
    var userid = FirebaseAuth.instance.currentUser!.uid;
    return ZegoUIKitPrebuiltCall(
      appID:
          501890069, 
      appSign:
          '1444aa9d79bfc0ab422b6bd79fa7c71b47060045b7d78c5bab766a7e53049da3', 
      userID: userid,
      userName: user!,
      callID: callID,
      
      
      config: ZegoUIKitPrebuiltCallConfig.groupVoiceCall(),

      // onError: (){

      // }
        // ignore: avoid_types_as_parameter_names
        // ..onOnlySelfInRoom =
        //     (context) => Navigator.of(context).pop(),

    );
  }
}
