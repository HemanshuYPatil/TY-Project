import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/models/bottom.dart';
import 'package:chatapp/models/bottomMenu.dart';
import 'package:chatapp/pages/Bot/BotScreen.dart';
import 'package:chatapp/pages/Bot/botsearch.dart';
import 'package:chatapp/pages/Bot/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import 'PaymentApps.dart'; // Assuming Payment_Apps is in this file
import '../../../main.dart';

class PaymentMethod extends StatefulWidget {
  final String price;
  const PaymentMethod({Key? key, required this.price});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  int selectedType = 1;
  Future<UpiResponse>? _transaction;
  UpiIndia _upiIndia = UpiIndia();

  void handleRadio(int? value) {
    setState(() {
      selectedType = value!;
    });
  }



  @override
  Widget build(BuildContext context) {
    String price = widget.price;
    String deliverycharges = '30';

    int intprice =  int.parse(price);
    int intdelivery = int.parse(deliverycharges);

    int total = intprice + intdelivery;
    return WillPopScope(

      onWillPop: () async {
        // Show Cupertino dialog when user tries to go back
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Warning'),
              content: const Text('Are you sure you want to Cancel?'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Dismiss dialog
                  },
                ),
                CupertinoDialogAction(
                  child: const Text('Yes'),
                  onPressed: () {
                    print(total);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> BottomBar())); // Navigate back to previous screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Payment Cancelled")),
                    );
                  },
                ),
              ],
            );
          },
        );
        return true; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Payment'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: 20),
                buildPaymentOption(1, 'Pay with UPI'),
                SizedBox(height: 70),
                buildPaymentDetails('Price', price),
                SizedBox(height: 8),
                buildPaymentDetails('Delivery Charges', deliverycharges.toString()),
                SizedBox(height: 8),
                Divider(height: 30, color: Colors.grey),
                SizedBox(height: 8),
                buildPaymentDetails('Total', '₹ ${total.toString()}'),
                Spacer(),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Payment_Apps(price: total.toString()  ,)),
                        );
                      },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Confirm', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPaymentOption(int value, String title) {
    return GestureDetector(
      onTap: () {
        handleRadio(value);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selectedType == value ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Radio(
              value: value,
              groupValue: selectedType,
              onChanged: (val) {
                handleRadio(val as int);
              },
              activeColor: Colors.blue,
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentDetails(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
