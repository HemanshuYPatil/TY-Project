import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/pages/Calls/voicecall.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../Auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../helper/dialogs.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import 'package:permission_handler/permission_handler.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
User get user => auth.currentUser!;

TextEditingController roomidtext = TextEditingController();
String roomId = '';

class Calls extends StatelessWidget {
  Icon convertStringToIcon(String iconString) {
    switch (iconString) {
      case "Icon(Boxicons.bx_phone)":
        return Icon(Icons.phone);
      case "Icon(Boxicons.bx_video)":
        return Icon(Icons.video_call);
      default:
        return Icon(Icons.error);
    }
  }

  const Calls({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Room"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {Navigator.pop(context);},
            icon: const Icon(Ionicons.chevron_back_outline),
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.blue,
          overlayColor: Colors.black,
          overlayOpacity: 0.4,
          children: [
            SpeedDialChild(
              child: const Icon(Boxicons.bx_phone),
              // label: "Voice Call",
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onTap: () => {showdialog(context, "Voice Call", "voice")},
            ),
            SpeedDialChild(
              child: const Icon(Boxicons.bx_video),
              // label: "Video Call",
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onTap: () => {showdialog(context, "Video Call", "video")},
            ),
            SpeedDialChild(
              child: const Icon(Boxicons.bxs_message_add),
              // label: "Video Call",
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              onTap: () => {join(context)},
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: StreamBuilder(
            stream: firestore
                .collection('CallRoom')
                .doc(user.uid)
                .collection('calls')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No Vedio and Voice Call Found'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    // Get each document from the snapshot
                    var callData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    int timeValue = int.parse(callData['time']);
                    return Card(
                      margin: EdgeInsets.symmetric(
                          horizontal: mq.width * .04, vertical: 4),
                      // color: Colors.blue.shade100,
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        //user profile picture
                        leading: InkWell(
                          onTap: () {
                            // showDialog(
                            //     context: context,
                            //     builder: (_) => ProfileDialog(user: widget.user));
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 5), // Adjust the value as needed
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.03),
                              child: convertStringToIcon(callData['icon']),
                            ),
                          ),
                        ),

                        //user name
                        title: Text(
                          callData['name'],
                          style: TextStyle(fontSize: 15),
                        ),
                        subtitle: Text(
                          callData['type'],
                          style: TextStyle(fontSize: 13),
                        ),

                        //last message time

                        trailing: Text(
                          formatDate(timeValue),
                          style: TextStyle(fontSize: 12),
                        ),

                        // style: TextStyle(color: Colors.black54),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ));
  }

  Future showdialog(BuildContext context, String title, String ontap) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [Text(title)],
              ),
              content: Text("Are you Sure you want to Create a $title room"),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),
                MaterialButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      if (ontap == "voice") {
                        room(context);
                      }
                      if (ontap == "join") {
                      } else {
                        // room(context);
                      }
                    },
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }

  void join(BuildContext context) {
    String email = ''; // Declare email variable here

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Join Call'), // Simplified title widget
          content: TextFormField(
            maxLines: null,
            controller: roomidtext,
            onChanged: (value) => roomId = value,
            decoration: InputDecoration(
              hintText: 'Room Id',
              prefixIcon: const Icon(Icons.email, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                searchRoomId(roomId, context);
              }, 
              child: const Text(
                'Join',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

Future<String?> searchRoomId(String roomId,BuildContext context) async {
 try {

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference roomsCollection = firestore.collection('rooms');


    QuerySnapshot querySnapshot = await roomsCollection.where('roomId', isEqualTo: roomId).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Iterate through the results
      for (DocumentSnapshot document in querySnapshot.docs) {
        // Access the document data
        Map<String, dynamic> roomData = document.data() as Map<String, dynamic>;
        // Do something with the data
         String id = roomData['roomId'];

         var micro = await Permission.microphone.status;

         if(!micro.isGranted){
          
         }
         if(micro.isGranted){
           
         }
         Permission.microphone.request().then((value) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Voicecall(callID: id),
            ),
          ));
        
          // ignore: use_build_context_synchronously
         
      }
    } else {
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Dialogs.showSnackbar(context, "Incorrect Room ID ");
    }
  } catch (e) {
    print('Error searching for room: $e');
  }
  return null;
}



  String generateRandomRoomId() {
    final random = Random();
    // Generate a random number between 1000 and 9999 (inclusive)
    final roomId = random.nextInt(90000) + 10000;
    return roomId.toString();
  }

  Future<void> joinvoicecall(String searchRoomId, BuildContext context) async {
    try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('roomId', isEqualTo: searchRoomId)
        .get();

    if (querySnapshot.docs.isEmpty) {
    
    // Dialogs.showSnackbar(context, "Room Id Not found");
      print("Room Id Not found");
      return;
    }

   
    DocumentSnapshot roomSnapshot = querySnapshot.docs.first;
    Object? roomData = roomSnapshot.data();
    print(roomData);

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => RoomPage(roomData)),
    // );
  } catch (e) {
    // Handle any errors that might occur
    print('Error: $e');
    // Dialogs.showSnackbar(context, "An error occurred while joining the call");
  }
  }

  String formatDate(int timestamp) {
    DateTime now = DateTime.now();
    DateTime eventTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Calculate the time elapsed since the event in hours
    int hoursDifference = now.difference(eventTime).inHours;

    // Check if the time difference is greater than 24 hours
    bool isTimeAvailable = hoursDifference >= 24;

    // Format the time or date and month based on availability
    String displayText;
    if (isTimeAvailable) {
      // Displaying day and month in "2 April" format
      displayText = DateFormat('d MMMM yyyy').format(eventTime);
    } else {
      displayText = DateFormat.Hm().format(eventTime); // Display time
    }
    return displayText;
  }

  Future<void> room(BuildContext context) async {
    roomId = generateRandomRoomId();
    final CollectionReference roomCollection =
      FirebaseFirestore.instance.collection('rooms');
       try {
      await roomCollection.doc(roomId).set({
        'roomId': roomId,
        // Add other room properties if needed
      });
    } catch (e) {
      print('Error adding room: $e');
    }
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [Text("Room Created")],
          ),
          content: Text("Room Id is $roomId"),
          actions: [
            MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  APIs.callRoom('voice', roomId);
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 16))),
            MaterialButton(
                onPressed: () async {
                  Navigator.pop(context);
                  APIs.callRoom('voice', roomId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => Voicecall(callID: roomId)));
                },
                child: const Text(
                  'Join',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ))
          ],
        );
      }),
    );
  }
}
