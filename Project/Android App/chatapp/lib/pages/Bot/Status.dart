import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/pages/Bot/Payment/payment_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconly/iconly.dart';
import 'package:ionicons/ionicons.dart';

class OrderDetailsPage extends StatefulWidget {
  final String item,
      status,
      deliveryadd,
      clientnumber,
      clientname,
      time,
      owner,
      price,
      doc;

  const OrderDetailsPage({
    Key? key,
    required this.doc,
    required this.item,
    required this.status,
    required this.deliveryadd,
    required this.clientnumber,
    required this.clientname,
    required this.time,
    required this.owner,
    required this.price,
  }) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Future<DocumentSnapshot> _orderDataFuture;

  @override
  void initState() {
    super.initState();
    _orderDataFuture = _fetchOrderData();
  }

  Future<DocumentSnapshot> _fetchOrderData() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Notification')
        .doc(widget.doc)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _orderDataFuture = _fetchOrderData();
          });
        },
        child: FutureBuilder<DocumentSnapshot>(
          future: _orderDataFuture,
          builder: (context, snapshot) {
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
            var orderData = snapshot.data!.data() as Map<String, dynamic>;
            String status = orderData['status'] ?? '';

            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                SizedBox(height: 20),
                Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  elevation: 0.1,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order: ${widget.item}",
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w600),
                            ),
                            Chip(
                              shape: const StadiumBorder(),
                              side: BorderSide.none,
                              backgroundColor: status == 'Accepted'
                                  ? Colors.green.withOpacity(0.4)
                                  : status == 'Rejected'
                                      ? Colors.red.withOpacity(0.4)
                                      : status.isEmpty
                                          ? Colors.yellow.withOpacity(0.4)
                                          : Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                              .withOpacity(0.4),
                              labelPadding: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              label:
                                  Text(status.isNotEmpty ? status : 'Pending'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        const SizedBox(height: 18),
                        Text(
                          widget.clientname,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(IconlyLight.home, size: 15),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                widget.deliveryadd,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(IconlyLight.call, size: 15),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                widget.clientnumber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.currency_rupee, size: 15),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                widget.price,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Payment method"),
                            const Text("Cash or Online"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print(widget.price);
                      if (widget.price.isNotEmpty) {
                        // Show circular progress indicator
                        print('Not Empty');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: Container(
                                width: 100, // Adjust the width as needed
                                height: 100, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  color: Colors.grey[300], // Background color
                                  borderRadius: BorderRadius.circular(20), // Rounded corners
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );


                          },
                        );


                        Future.delayed(const Duration(seconds: 6), () {

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PaymentMethod(price: widget.price,))).then((value) => Navigator.pop(context));
                        });
                      } else {
                        // Show Cupertino dialog
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text('Message'),
                              content:
                                  Text('Wait for owner to accept your request'),
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
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 1),
                      child: Text('Pay Now', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                // OrderItem(order: order, visibleProducts: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}
