import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Auth/chat_user.dart';
import 'package:chatapp/pages/Calls/call.dart';
import 'package:chatapp/pages/GroupChat/grouplists.dart';
import 'package:chatapp/pages/Welcome/Homescreen.dart';
import 'package:chatapp/widgets/pic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';

import '../../Auth/auth.dart';
import '../../helper/dialogs.dart';
import 'package:chatapp/main.dart';
import '../../widgets/texifield.dart';
import '../Login/signin.dart';
import 'creatinggroup.dart';

class Groupdialog extends StatefulWidget {
  Groupdialog({Key? key}) : super(key: key);

  @override
  _GroupdialogState createState() => _GroupdialogState();
}

class _GroupdialogState extends State<Groupdialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController groupname = TextEditingController();
  final TextEditingController groupdes = TextEditingController();
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {Navigator.pop(context);},
            icon: const Icon(Ionicons.chevron_back_outline),
          ),
          title: const Text("Create New Group"),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                child: Column(
                  children: [
                    SizedBox(width: mq.width, height: mq.height * .07),
                    ProfilePic(user: APIs.me),
                    SizedBox(height: mq.height * .10),
                    TextFormField(
                      controller: groupname,
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.people, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Group Name',
                        label: const Text('Group Name'),
                      ),
                    ),
                    const SizedBox(height: 35),
                    TextFormField(
                      controller: groupdes,
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.description_outlined,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Group Description',
                        label: const Text('Description'),
                      ),
                    ),
                    SizedBox(height: mq.height * .10),
                    SizedBox(
                      height: 45,
                      width: 180,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  _formKey.currentState!.save();
                                  String name = groupname.text.trim();
                                  String des = groupdes.text.trim();

                                  try {
                                    await APIs.createGroup(
                                        user.displayName.toString(),
                                        user.uid.toString(),
                                        name,
                                        des);
                                    Dialogs.showSnackbar(
                                        context, 'Group Created');
                                    groupname.clear();
                                    groupdes.clear();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GroupListChat(),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                        style: TextButton.styleFrom(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(100.0),
                              //   color: Colors.blue,
                              // ),
                              child: isLoading
                                  ? const  Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,  // Adjust the width as needed
                                    height: 24, // Adjust the height as needed
                                    child:  CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text('Creating Group...', style: TextStyle(fontSize: 14, color: Colors.white),)
                                ],
                              )
                                  : const Text(
                                      "Create",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Sofia",
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                            // if (isLoading)
                            // Positioned.fill(
                            //   child: CircularProgressIndicator(
                            //     strokeWidth: 2,
                            //     valueColor:
                            //     AlwaysStoppedAnimation<Color>(Colors.white),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
