import 'dart:convert';
import 'dart:developer';

import 'dart:io';

import 'package:chatapp/Auth/GroupUser.dart';
import 'package:chatapp/pages/Calls/call.dart';
import 'package:chatapp/widgets/group_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';

import 'package:http/http.dart';

import 'package:chatapp/Auth/chat_user.dart';

import '../models/message.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
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


 static Future getUserName(String userId) async {
  try {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();

    if (documentSnapshot.exists) {

      return documentSnapshot['name'].toString();
    } 
  } catch (error) {
    // Handle errors if any during the document retrieval
    print("Error retrieving user data: $error");
    return "Unknown User";
  }
}

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });

    // for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // static Stream<QuerySnapshot<Map<String, dynamic>>> getMyGroups() {
  //   // Replace 'groups' with the actual collection name where your groups are stored
  //   return FirebaseFirestore.instance.collection('Groups').doc(user.uid).collection('MyGroups').snapshots();
  // }

static Stream<QuerySnapshot<Map<String, dynamic>>> getMyGroups() {
  return FirebaseFirestore.instance
      .collection('Groups')
      .where('members', arrayContains: "${user.uid}_${user.displayName}")
      .snapshots();
}

  static Future<void> UpdateMemeberName(String userId, String name, String newName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .where('members', arrayContains: "${userId}_${name}")
          .get();

      // Iterate over each document in the snapshot
      snapshot.docs.forEach((doc) async {
        // Update the array field
        List<String> botAccess = List<String>.from(doc['members']);
        int index = botAccess.indexOf("${userId}_${name}");
        if (index != -1) {
          botAccess.removeAt(index);
          botAccess.add("${userId}_${newName}");

          await doc.reference.update({'members': botAccess});
        }
      });
    } catch (e) {
      print('Error updating bot name: $e');
    }
  }

  static Future<void> UpdateRecentMemberName(String userId, String name, String newName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .where('recentMessageSender', isEqualTo: name)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      snapshot.docs.forEach((doc) {
        batch.update(doc.reference, {'recentMessageSender': newName});
      });

      await batch.commit();
    } catch (e) {
      print('Error updating recent member name: $e');
    }
  }

  static Future<void> UpdateAdminName(String userId, String name, String newName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .where('admin', isEqualTo: '${userId}_$name')
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'admin': '${userId}_$newName'});
      }

      await batch.commit();
    } catch (e) {
      print('Error updating recent member name: $e');
    }
  }

  static Future<void> updateNameInSubcollection(String oldName, String newName) async {
    try {

      QuerySnapshot<Map<String, dynamic>> groupSnapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();


      for (QueryDocumentSnapshot<Map<String, dynamic>> groupDoc in groupSnapshot.docs) {

        QuerySnapshot<Map<String, dynamic>> subCollectionSnapshot = await groupDoc.reference
            .collection('messages')
            .where('sender', isEqualTo: oldName)
            .get();


        subCollectionSnapshot.docs.forEach((subDoc) {
          batch.update(subDoc.reference, {'sender': newName});
        });
      }

      // Commit the batch update
      await batch.commit();
    } catch (e) {
      print('Error updating name in subcollection: $e');
    }
  }


  static Future<void> fetchFieldValue() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (documentSnapshot.exists) {
        var fieldValue = documentSnapshot.get('disabled');
        print('Field Value: $fieldValue');
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error fetching document: $error');
    }
  }


  static Future getusergroups() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Process the snapshot data as needed
      print(snapshot.data());
    } catch (error) {
      // Handle any errors that occurred during the operation
      print(error);
    }
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, 
          "body : ": msg,
          "android_channel_id": "Notifications"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAA8OPcMNM:APA91bH9967nzT4hV-ZeSQx6GLkBc0-dWn0azHEhr8d94hsM4depU-GtChfuhRf9gR1eKNqpeHkE1T6hgDXh2Uy7erdIAWFL5MZjUKOXv3OvaEWhG6_xYAXpK3hFszrbhaHriM3Mg8YX'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  static Future<void> sendcall(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name,
          "body": msg,
          "android_channel_id": "Notifications",
          "click_action": "FLUTTER_NOTIFICATION_CLICK", // Add this line for the action buttons
          "actions": [
            {"action": "action1", "title": "Action 1"},
            {"action": "action2", "title": "Action 2"},
          ],
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var res = await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
          'key=AAAA8OPcMNM:APA91bH9967nzT4hV-ZeSQx6GLkBc0-dWn0azHEhr8d94hsM4depU-GtChfuhRf9gR1eKNqpeHkE1T6hgDXh2Uy7erdIAWFL5MZjUKOXv3OvaEWhG6_xYAXpK3hFszrbhaHriM3Mg8YX'
        },
        body: jsonEncode(body),
      );

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using ChatBuddy",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // static Future<void> callroom(String type) async {
  //   final time = DateTime.now().millisecondsSinceEpoch.toString();

  //   Map<String, dynamic> userData = {
  //     'name': user.displayName.toString(),
  //     'image': user.photoURL.toString(),
  //     'time': time,
  //   };

  //   if (type == "voice") {
  //     userData["icon"] = "Icon(Boxicons.bx_phone)";
  //   }
  //   if (type == "video") {
  //     userData["icon"] = "Icon(Boxicons.bx_video)";
  //   } else {
  //     userData["icon"] = "Icon(Boxicons.bx_error)";
  //   }

  //   return await firestore.collection('CallRoom').doc(user.uid).set(userData);
  // }

  static Future<void> callRoom(String type, roomid) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, dynamic> userData = {
      'name': user.displayName.toString(),
      'image': user.photoURL.toString(),
      'roomId': roomid,
      'time': time,
    };

    if (type == "voice") {
      userData["icon"] = "Icon(Boxicons.bx_phone)";
      userData["type"] = "Voice Call";
    } else if (type == "video") {
      userData["icon"] = "Icon(Boxicons.bx_video)";
      userData["type"] = "Vedio Call";
    }

    // Reference to the user's document in the 'CallRoom' collection
    DocumentReference userDocRef =
        firestore.collection('CallRoom').doc(user.uid);

    // Add a subcollection 'calls' under the user's document
    CollectionReference callsCollection = userDocRef.collection('calls');

    // Add a new document in the 'calls' subcollection with the userData
    await callsCollection.add(userData);
  }

  static Future createGroup(
      String userName, String id, String groupName, String des) async {
    DocumentReference groupDocumentReference =
        await FirebaseFirestore.instance.collection("Groups").add({
      "groupName": groupName,
      "groupIcon": me.image,
      "admin": "${id}_${user.displayName}",
      "members": [],
      "groupId": "",
      "description": des,
      "recentMessage": "",
      "recentMessageSender": "",
      "recentMessageTime" : "",
      "createdAt": DateTime.now().millisecondsSinceEpoch.toString()
    });

    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${user.uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    // await FirebaseFirestore.instance.collection('Groups').doc()


    DocumentReference userDocumentReference =
        FirebaseFirestore.instance.collection("users").doc(user.uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type,Reply reply) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type, reply));
  }

  // for updating user information
  static Future<void> updateUserInfo(String about) async {
    await firestore.collection('users').doc(user.uid).update({
      'about': about,
    });

  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    final groupRef = firestore.collection('Groups').doc();
    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${groupRef.id}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .update({'image': me.image});
  }

  static Future<void> updategroupimage(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('Group_Pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    // me.image = await ref.getDownloadURL();

    await firestore
        .collection('groups')
        .doc(user.uid)
        .update({'image': me.image});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type , Reply replmsg) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time,
        reply: replmsg
        );

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file,Reply reply) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image,reply);
  }

  static Future<void> sendChatVideo(ChatUser chatUser, File videoFile) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('videos/${getConversationID(chatUser.id)}/$time.mp4');

    await ref.putFile(videoFile);

    final videoUrl = await ref.getDownloadURL();

    final Message message = Message(
      toId: chatUser.id,
      msg: videoUrl,
      read: '',
      type: Type.video,
      fromId: user.uid,
      sent: time,
    );

    final messageRef = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');

    await messageRef.doc(time).set(message.toJson()).then((value) {
      sendPushNotification(chatUser, 'Vedio 🎥');
    });
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
    if (message.type == Type.video) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  // Group Method

  static Future<void> sendGroupMessage(String groupId,Map<String, dynamic> text) async {


    try{
      FirebaseFirestore.instance.collection('Groups').doc(groupId).collection('messages').add(text);
      FirebaseFirestore.instance.collection('Groups').doc(groupId).update({
      "recentMessage": text['message'],
      "recentMessageSender": text['sender'],
      "recentMessageTime": text['time'].toString(),

    });
      // await sendGroupNotification(groupId, text['message']);

    }catch(e){
      print(e);
    }
  }

  // static Future<void> sendGroupNotification(String groupId, String msg) async {
  //   try {
  //     // Retrieve the push tokens of all members in the group
  //     var groupMembers = await FirebaseFirestore.instance.collection('Groups').doc(groupId).snapshots();
  //     // var tokens = groupMembers.docs.map((member) => member['pushToken']).toList();
  //
  //     // Send a notification to each member in the group
  //     for (var token in tokens) {
  //       await sendgroupNotification(token, 'New Group Message', msg);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  static Future<void> sendgroupNotification(String pushToken, String title, String bodys) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": title,
          "body": bodys,
          "android_channel_id": "Notifications",
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
          'key=AAAA8OPcMNM:APA91bH9967nzT4hV-ZeSQx6GLkBc0-dWn0azHEhr8d94hsM4depU-GtChfuhRf9gR1eKNqpeHkE1T6hgDXh2Uy7erdIAWFL5MZjUKOXv3OvaEWhG6_xYAXpK3hFszrbhaHriM3Mg8YX'
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }

  static Stream<QuerySnapshot> getAllGroupMessages() {
    try {
      return FirebaseFirestore.instance
          .collection('group_messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      print('Error fetching group messages: $e');
      return Stream.empty();
    }
  }

  static Future getGroupAdmin(String groupId) async{
     DocumentReference d = FirebaseFirestore.instance.collection('Groups').doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    log("${documentSnapshot['admin']}");
    return documentSnapshot['admin'];
  }

  static Future getGroupMembers(groupId) async {
    return FirebaseFirestore.instance.collection('Groups').doc(groupId).snapshots();
  }

  static Future searchByName(String groupName) {
    return FirebaseFirestore.instance.collection('Groups').where("groupName", isEqualTo: groupName).get();
  }

  static Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }



static Future<String?> getreplyname(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.get('name');
      } else {
        return null; // User not found
      }
    } catch (e) {
      print('Error getting reply name: $e');
      return null;
    }
  }

   static Future  getUserGroups() async {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();
  }

    static Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentReference groupDocumentReference = FirebaseFirestore.instance.collection('Groups').doc(groupId);

    DocumentSnapshot documentSnapshot = await groupDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['members'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${user.uid}_${user.displayName}"])
      });
    } else {
      await userDocumentReference.update({
    
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
      
        "members": FieldValue.arrayUnion(["${user.uid}_${user.displayName}"])
      });
    }
  }

  

  static leavegroup(
      String groupId, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentReference groupDocumentReference = FirebaseFirestore.instance.collection('Groups').doc(groupId);

    DocumentSnapshot documentSnapshot = await groupDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['members'];

     await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${user.uid}_${user.displayName}"])
      });
  }

   static Future removemember(String groupId, String userId, String groupName , String username) async {
     DocumentReference userDocumentReference = FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentReference groupDocumentReference = FirebaseFirestore.instance.collection('Groups').doc(groupId);

    DocumentSnapshot documentSnapshot = await groupDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['members'];

     await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${userId}_${username}"])
      });
   }
  
  static GroupsendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
     FirebaseFirestore.instance.collection('Groups').doc(groupId).collection("messages").add(chatMessageData);
     FirebaseFirestore.instance.collection('Groups').doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  static getChats(String groupId) async {
    return FirebaseFirestore.instance.collection('Groups')
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  static getrecentmessage(String groupId){
    DocumentReference data = FirebaseFirestore.instance.collection('Groups').doc(groupId);
    return data.snapshots();
  }

}

class GMessage {
  final String senderId;
  final String text;
  final Type type;
  final FieldValue timestamp;

  GMessage({
    required this.senderId,
    required this.text,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'type': type.toString(),
      'timestamp': timestamp,
    };
  }
}

enum GType {
  text,
  image,
  video,
}

