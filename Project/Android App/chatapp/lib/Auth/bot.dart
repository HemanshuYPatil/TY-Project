import 'dart:convert';
import 'dart:developer';

import 'dart:io';
import 'dart:math';

import 'package:chatapp/Auth/GroupUser.dart';
import 'package:chatapp/pages/Calls/call.dart';
import 'package:chatapp/widgets/group_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gallery_saver/files.dart';

import 'package:http/http.dart';

import 'package:chatapp/Auth/chat_user.dart';

import '../models/message.dart';

class BotBackend {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("Groups");

  // for storing self information
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using ChatBuddy!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // to return current user
  static User get user => auth.currentUser!;

  final groupRef = firestore.collection('Groups').doc();
  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static createnewbot(
      String name, String purpose, String type, String privacy) async {
    String adminPushToken = await getAdminPushToken(user.uid);
    DocumentReference botprivate =
        FirebaseFirestore.instance.collection('Bot').doc();

    DocumentReference newBotRef = botprivate.collection('Public').doc();

    await botprivate.set({
      "BotName": name,
      "admin": "${user.displayName}",
      "description": purpose,
      "BotId": " ",
      "BotAccess": [],
      "AdminId": user.uid,
      "AdminPushToken": adminPushToken,
      "Type": type,
      "BotPrivacy": privacy,
      "createdAt": DateTime.now().millisecondsSinceEpoch.toString()
    });
    // FirebaseFirestore.instance.collection('users').doc(user.uid).update({
    //   "Bots": FieldValue.arrayUnion(["${botprivate.id}_${name}"])
    // });
    botprivate.update({
      "BotId": botprivate.id,
      // "BotAccess": FieldValue.arrayUnion(["${user.uid}_${user.displayName}"])
    });

    FirebaseFirestore.instance.collection("users").doc(auth.currentUser?.uid).update(
        {
          "my_bot": FieldValue.arrayUnion(["${botprivate.id}_${name}"])
        });
  }

  static Future<String> getAdminPushToken(String adminUserId) async {
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(adminUserId)
          .get();

      if (documentSnapshot.exists) {
        return documentSnapshot['push_token'].toString();
      } else {
        return "";
      }
    } catch (error) {
      // Handle errors if any during the document retrieval
      print("Error retrieving admin push token: $error");
      return ""; // Return an empty string on error
    }
  }

  static Future getUserName(String userId) async {
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        return documentSnapshot['push_token'].toString();
      }
    } catch (error) {
      // Handle errors if any during the document retrieval
      print("Error retrieving user data: $error");
      return "Unknown User";
    }
  }

  static createprivatebot(String name, String purpose, String type,
      String privacy, String code) async {
    DocumentReference botprivate =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    botprivate.collection('Bot').add({
      "BotName": name,
      "admin": "${user.displayName}",
      "description": purpose,
      "BotId": "",
      "BotAccess": [],
      "Type": type,
      "Code": code,
      "BotPrivacy": privacy,
      "createdAt": DateTime.now().millisecondsSinceEpoch.toString()
    });

    botprivate
        .collection('Bot')
        .doc(botprivate.collection('Bot').id)
        .update({"BotId": botprivate.collection('Bot').id});
  }

  static Future<void> sendPushNotification(
      String title, String token, String msg) async {
    try {
      final body = {
        "to": token,
        "notification": {
          "title": title,
          "body": msg,
          "android_channel_id": "Notifications"
        },
        "data": {
          "some_data": "User ID: ${FirebaseAuth.instance.currentUser!.uid}",
        },
      };

      var res = await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'key=AAAA8OPcMNM:APA91bH9967nzT4hV-ZeSQx6GLkBc0-dWn0azHEhr8d94hsM4depU-GtChfuhRf9gR1eKNqpeHkE1T6hgDXh2Uy7erdIAWFL5MZjUKOXv3OvaEWhG6_xYAXpK3hFszrbhaHriM3Mg8YX',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static createNotification(String admin, String item, String address,
      String number, String name, String orderid) {
    DocumentReference users = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid);

    DocumentReference notification = users.collection("Notification").doc();
    notification.set({
      'OrderID': orderid,
      'Owner': admin,
      'item': item,
      'Price': '',
      'DocID': '',
      'Client_name': name,
      'Client_Number': number,
      'delivery_address': address,
      'status': '',
      'Time': DateTime.now().millisecondsSinceEpoch.toString()
    }).then((value) {
      notification.update({"DocID": notification.id});
    }).catchError((error) {
      print("Error creating seller notification: $error");
    });
  }

  static CreateSellerNotification(String id, String customersname,
      String deliveryaddress, String phonenumber, String item, String orderid) {
    DocumentReference bot =
        FirebaseFirestore.instance.collection("Bot").doc(id);
    DocumentReference order = bot.collection('Ordered').doc();

    order.set({
      "ID": order.id,
      'OrderId': orderid,
      "Ordered_item": item,
      "Customer_Id": user.uid,
      "Customer": customersname,
      "Delivery_location": deliveryaddress,
      "Customer_phone": phonenumber,
      "Price": "",
      "Status": "",
      "Time": DateTime.now().millisecondsSinceEpoch.toString(),
    }).then((value) {
      order.update({"ID": order.id});
    }).catchError((error) {
      print("Error creating seller notification: $error");
    });
  }

  static Future<void> updateStatus(
      String orderId, String newStatus, String customerID) async {
    CollectionReference<Map<String, dynamic>> notificationCollection =
        FirebaseFirestore.instance
            .collection('users')
            .doc(customerID)
            .collection('Notification');

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await notificationCollection.where('OrderID', isEqualTo: orderId).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference<Map<String, dynamic>> documentReference =
          querySnapshot.docs.first.reference;

      await documentReference.update({'status': newStatus});
    } else {
      // No matching document found
      print('No document found for order ID $orderId');
    }
  }

  static Future<void> updatePrice(
      String orderId, String price, String cutomer_id) async {
    CollectionReference<Map<String, dynamic>> notificationCollection =
        FirebaseFirestore.instance
            .collection('users')
            .doc(cutomer_id)
            .collection('Notification');

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await notificationCollection.where('OrderID', isEqualTo: orderId).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference<Map<String, dynamic>> documentReference =
          querySnapshot.docs.first.reference;

      await documentReference.update({'Price': price});
    } else {
      // No matching document found
      print('No document found for order ID $price');
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyBot() {
    return FirebaseFirestore.instance
        .collection('Bot')
        .where('BotAccess', arrayContains: "${user.uid}_${user.displayName}")
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllBots() {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return FirebaseFirestore.instance
        .collection('Bot')
        .where('AdminId', isEqualTo: user.uid)
        .snapshots();
  }



  static Future<void> UpdateAccessName(String userId, String name, String newName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Bot')
          .where('BotAccess', arrayContains: "${userId}_${name}")
          .get();

      // Iterate over each document in the snapshot
      snapshot.docs.forEach((doc) async {
        // Update the array field
        List<String> botAccess = List<String>.from(doc['BotAccess']);
        int index = botAccess.indexOf("${userId}_${name}");
        if (index != -1) {
          botAccess.removeAt(index);
          botAccess.add("${userId}_${newName}");

          await doc.reference.update({'BotAccess': botAccess});
        }
      });
    } catch (e) {
      print('Error updating bot name: $e');
    }
  }


  static Future searchByBotName(String Botname) {
    return FirebaseFirestore.instance
        .collection('Bot')
        .where("BotName", isEqualTo: Botname)
        .get();
  }

  static Future<bool> IsBotAdd(
      String botname, String botid, String userName) async {
    DocumentReference userDocumentReference =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['Bots'];
    if (groups.contains("${botid}_$botname")) {
      return true;
    } else {
      return false;
    }
  }

  static Future togglebotjoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentReference groupDocumentReference =
        FirebaseFirestore.instance.collection('Bot').doc(groupId);

    DocumentSnapshot documentSnapshot = await groupDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['BotAccess'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${user.uid}_${user.displayName}")) {
      await userDocumentReference.update({
        "Bots": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "BotAccess": FieldValue.arrayRemove(["${user.uid}_${user.displayName}"])
      });
      print("${groupId}_$groupName");
    } else {
      await userDocumentReference.update({
        "Bots": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "BotAccess": FieldValue.arrayUnion(["${user.uid}_${user.displayName}"])
      });
    }
  }
}
