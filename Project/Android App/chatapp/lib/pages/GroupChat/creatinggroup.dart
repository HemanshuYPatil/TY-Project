import 'package:chatapp/pages/GroupChat/groupchatScreen.dart';
import 'package:chatapp/pages/Welcome/Homescreen.dart';
import 'package:flutter/material.dart';

import '../../Auth/auth.dart';
import '../../helper/dialogs.dart';

class CreatingGroup extends StatefulWidget {
  final id,name,groupname,des;
  const CreatingGroup({super.key, required this.des,  required this.groupname, required this.name,  required this.id});

  @override
  State<CreatingGroup> createState() => _CreatingGroupState();
}

class _CreatingGroupState extends State<CreatingGroup> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.createGroup(widget.id,widget.name,widget.groupname,widget.des)
        .then((value) => {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreen()))
        }).then((value) => {
          Dialogs.showSnackbar(context, 'Group Created')
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CenteredProgressBar(),
        
      )
    );
  }
}


class CenteredProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 28.0), // Adjust spacing between text and progress bar
          Text('Creating Group...', style: TextStyle(fontSize: 17),),
        ],
      ),
    );
  }
}