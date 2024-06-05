import 'package:chatapp/Auth/bot.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconly/iconly.dart';
import 'package:ionicons/ionicons.dart';

class My_Order extends StatefulWidget {
  final String botdocId;
  const My_Order({Key? key, required this.botdocId});

  @override
  State<My_Order> createState() => _My_OrderState();
}

class _My_OrderState extends State<My_Order> {
  late Stream<DocumentSnapshot> orderStream;
  String price = '';
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    orderStream = FirebaseFirestore.instance
        .collection('Bot')
        .doc(widget.botdocId)
        .collection('Ordered')
        .doc()
        .snapshots();
    print(widget.botdocId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Orders"),
        leading: IconButton(
          onPressed: () {Navigator.pop(context);},
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Bot')
            .doc(widget.botdocId)
            .collection('Ordered')
            .orderBy('Time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
              "Ordered Not Received Yet",
              style: TextStyle(fontSize: 20),
            ));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var orderData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onLongPress: (){


                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Message'),
                        content: Text('Are You Sure? you Want to Delete'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text('OK'),
                            onPressed: () {

                              FirebaseFirestore.instance
                                  .collection('Bot')
                                  .doc(widget.botdocId)
                                  .collection('Ordered')
                                  .doc(orderData['ID']).delete().then((value) => Navigator.pop(context));
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  elevation: 0.1,
                  child: InkWell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Order: ${orderData['Ordered_item']}",
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (orderData['Status'] != null &&
                                      !orderData['Status'].isEmpty)
                                    Chip(
                                      shape: const StadiumBorder(),
                                      side: BorderSide.none,
                                      backgroundColor: orderData['Status'] ==
                                              'Accepted'
                                          ? Colors.green.withOpacity(0.4)
                                          : orderData['Status'] == 'Rejected'
                                              ? Colors.red.withOpacity(0.4)
                                              : theme.colorScheme.primaryContainer
                                                  .withOpacity(0.4),
                                      labelPadding: EdgeInsets.zero,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 10),
                                      label: Text(orderData['Status']),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 9),
                              const SizedBox(height: 18),
                              Text(
                                orderData['Customer'],
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(IconlyLight.home, size: 15),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      orderData['Delivery_location'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(IconlyLight.call, size: 15),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      orderData['Customer_phone'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.currency_rupee, size: 15),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      orderData['Price'],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  if (orderData['Status'] != "Accepted" &&
                                      orderData['Status'] != "Rejected")
                                    TextButton(
                                      onPressed: () {

                                        showStyledCupertinoDialogWithInput(
                                            context,
                                            orderData['Ordered_item'].toString(),orderData['ID'],
                                            orderData['OrderId'],orderData['Customer_Id']);
                                      },
                                      child: const Text('Set Price'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Payment Status"),
                                  Text(
                                    "Cash",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (orderData['Status']
                            .isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (!orderData['Price'].isEmpty) {
                                      FirebaseFirestore.instance
                                          .collection('Bot')
                                          .doc(widget.botdocId)
                                          .collection('Ordered')
                                          .doc(orderData['ID'])
                                          .update({'Status': 'Accepted'}).then(
                                              (value) {
                                        BotBackend.updateStatus(
                                            orderData['OrderId'], "Accepted",orderData['Customer_Id']);
                                      }).catchError((error) {
                                        // Failed to update
                                        print('Failed to update status: $error');
                                      });
                                    } else {
                                      showCupertinoDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CupertinoAlertDialog(
                                              title: const Text('Message'),
                                              content: const Text(
                                                  'Set a price for the product before accepting requests'),
                                              actions: <Widget>[
                                                CupertinoDialogAction(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                CupertinoDialogAction(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    // Add functionality here for OK button
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Accept'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('Bot')
                                        .doc(widget.botdocId)
                                        .collection('Ordered')
                                        .doc(orderData['ID'])
                                        .update({'Status': 'Rejected'}).then(
                                            (value) {
                                      // Successfully updated
                                      BotBackend.updateStatus(
                                          orderData['OrderId'], "Rejected",orderData['Customer_Id']);
                                    }).catchError((error) {
                                      // Failed to update
                                      print('Failed to update status: $error');
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Reject'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void showCupertinoCustomDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Message'),
          content: Text('Are You Sure? you Want to Delete'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void showStyledCupertinoDialogWithInput(
      BuildContext context, String item, String id,String orderId,String customerID) {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Column(
            children: [
              const SizedBox(height: 16), // Add space between title and content
              Text(
                'Set a Price for $item',
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: textController,
                placeholder: 'Type something',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                String inputValue = textController.text;
                setState(() {
                  price = inputValue;
                });
                FirebaseFirestore.instance
                    .collection('Bot')
                    .doc(widget.botdocId)
                    .collection('Ordered')
                    .doc(id)
                    .update({'Price': inputValue}).then((value) {
                  BotBackend.updatePrice(orderId, inputValue,customerID);
                }).catchError((error) {

                  print('Failed to update status: $error');
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
