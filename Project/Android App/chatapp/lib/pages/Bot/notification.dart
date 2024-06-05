import 'package:chatapp/Auth/auth.dart';
import 'package:chatapp/helper/my_date_util.dart';
import 'package:chatapp/pages/Bot/Status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          onPressed: () {Navigator.pop(context);},
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Notification').orderBy('Time',descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final String owner = documents[index]['Owner'] ?? '';
              final String item = documents[index]['item'] ?? '';
              final String status = documents[index]['status'] ?? '';
              final String deliverylocation = documents[index]['delivery_address'] ?? '';
              final String ClientNumber = documents[index]['Client_Number'] ?? '';
              final String ClientName = documents[index]['Client_name'] ?? '';
              final String Time = documents[index]['Time'] ?? '';
              final String Price = documents[index]['Price'] ?? '';
              final String DocId = documents[index]['DocID'] ?? '';

              return Column(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: InkWell(
                      onTap: () {
                        // print(DocId);
                        Navigator.push(context, MaterialPageRoute(builder: (_)=> OrderDetailsPage(owner: owner,item: item,status: status,deliveryadd: deliverylocation,clientname: ClientName,clientnumber: ClientNumber,time: Time,price: Price,doc: DocId)));
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.notifications, color: Colors.grey[700]),
                          backgroundColor: Colors.grey[200],
                        ),
                        title: Text("Order Placed"),
                        subtitle: Text(item),
                        trailing: Text(MyDateUtil.getFormattedTime(context: context, time: Time))
                        // PopupMenuButton<String>(
                        //   itemBuilder: (BuildContext context) {
                        //     return <PopupMenuEntry<String>>[
                        //       PopupMenuItem<String>(
                        //         value: 'delete',
                        //         child: Text('Delete'),
                        //       ),
                        //     ];
                        //   },
                        //   onSelected: (String value) {
                        //     if (value == 'delete') {
                        //       FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Notification').doc(documents[index].id).delete();
                        //     }
                        //   },
                        // ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
