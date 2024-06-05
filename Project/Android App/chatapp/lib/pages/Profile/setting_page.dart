import 'package:chatapp/Auth/bot.dart';
import 'package:chatapp/pages/Bot/My_order/BotLIsts.dart';
import 'package:chatapp/pages/Calls/call.dart';
import 'package:chatapp/pages/Profile/profile.dart';
import 'package:chatapp/pages/Profile/setting_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ionicons/ionicons.dart';

import '../../Auth/auth.dart';
import '../../Auth/chat_user.dart';

import '../../helper/dialogs.dart';
import '../Login/signin.dart';
import 'froeward_btn.dart';

class AccountScreen extends StatefulWidget {
  final ChatUser user;
  const AccountScreen({super.key,required this.user});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isDarkMode = false;
  String username = "";
  String _image = '';
  late Future<String> _getImageUrl;
  List<String> allbot = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getImageUrl = Future.value(APIs.me.image);
    somefunction();
  }

  void somefunction() {
    // Fetch username
    APIs.getUserName(widget.user.id).then((value) {
      setState(() {
        username = value;
      });
    }).catchError((error) {
      // Handle error
      print("Error fetching username: $error");
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leadingWidth: 70,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 1),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue.withOpacity(0.1),
                  ),
                  child: Row(
                    children: [



                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display user's name obtained from widget.user
                            Text(
                               auth.currentUser!.displayName.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Display user's role or description
                            Text(
                              auth.currentUser!.email.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                      ForwardButton(
                        onTap: () {
                          // Navigate to edit account screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  ProfileScreen( user: APIs.me,),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),


              const SizedBox(height: 100),

              const SizedBox(height: 20),
              SettingItem(
                title: "My Order",
                icon: Ionicons.bag,
                bgColor: Colors.orange.shade100,
                iconColor: Colors.orange,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> const AllBotLists()));
                },
              ),
              const SizedBox(height: 20),
              SettingItem(
                title: "Transaction History",
                icon: Boxicons.bx_history,
                bgColor: Colors.purple.shade100,
                iconColor: Colors.purple,
                onTap: () {},
              ),
              // const SizedBox(height: 20),
              // SettingItem(
              //   title: "My Bots",
              //   icon: Boxicons.bx_bot,
              //   bgColor: Colors.green.shade100,
              //   iconColor: Colors.green,
              //   onTap: () {
              //
              //   },
              // ),
              // const SizedBox(height: 20),
              // SettingItem(
              //   title: "Notifications",
              //   icon: Ionicons.notifications,
              //   bgColor: Colors.blue.shade100,
              //   iconColor: Colors.blue,
              //   onTap: () {
              //
              //   },
              // ),
              const SizedBox(height: 20),
              SettingItem(
                title: "Log Out",
                icon: Ionicons.log_out,
                bgColor: Colors.red.shade100,
                iconColor: Colors.red,
                onTap: () async {
                  showMyDialog(context);
                },
              ),
              const SizedBox(height: 20),
              // SettingSwitch(
              //   title: "Dark Mode",
              //   icon: Ionicons.earth,
              //   bgColor: Colors.purple.shade100,
              //   iconColor: Colors.purple,
              //   value: isDarkMode,
              //   onTap: (value) {
              //     setState(() {
              //       isDarkMode = value;
              //     });
              //   },
              // ),

            ],
          ),
        ),
      ),
    );
  }
  showMyDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title:  Text("Are you sure?"),
          content:  Text("Want to logout"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: ()  async {
                try {
                  Dialogs.showProgressBar(context);

                  await APIs.updateActiveStatus(false);

                  await APIs.auth.signOut().then((value) async {
                    try {
                      GoogleSignIn().signOut().then((value) {
                        //for hiding progress dialog
                        Navigator.pop(context);

                        APIs.auth = FirebaseAuth.instance;

                        //replacing home screen with login screen
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInpage()));

                        Dialogs.showSnackbar(context, "Log Out SuccessFully");
                      });
                    } catch (e) {
                      print(e);
                    }
                  });
                } catch (e) {
                  print(e);
                }// Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

}