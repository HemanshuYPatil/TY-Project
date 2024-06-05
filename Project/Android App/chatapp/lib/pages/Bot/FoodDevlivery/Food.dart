import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/files.dart';
import 'package:http/http.dart' as http;
import '../../../main.dart';
import '../data.dart';

class DeliverModel extends StatefulWidget {
  const DeliverModel({super.key});

  @override
  State<DeliverModel> createState() => _DeliverModelState();
}

class _DeliverModelState extends State<DeliverModel> {
  ChatUser myself = ChatUser(
      id: '1',
      firstName: FirebaseAuth.instance.currentUser!.displayName.toString());
  ChatUser bot = ChatUser(id: '2', firstName: 'DeliverModel');
  List<ChatMessage> allmsg = [];
  List<ChatUser> typing = [];

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: Text('DeliverModel'),
      ),
      body: DashChat(
        currentUser: myself,
        onSend: (ChatMessage m) {
          getmsg(m);

        },
        typingUsers: typing,
        messages: allmsg,
        messageListOptions: MessageListOptions(
          scrollPhysics: BouncingScrollPhysics(),


        ),
        messageOptions: const MessageOptions(
            borderRadius: 10.0
        ),
      ),

    );
  }

  getmsg(ChatMessage m) async {
    typing.add(bot);
    allmsg.insert(0, m);
    setState(() {});
    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    await http
        .post(Uri.parse(base_url), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        print(result);
        print(result['candidates'][0]['content']['parts'][0]['text']);

        ChatMessage m1 = ChatMessage(
            user: bot,
            createdAt: DateTime.now(),
            text: result['candidates'][0]['content']['parts'][0]['text']);

        allmsg.insert(0, m1);
        setState(() {});
      }
    }).catchError((onError) {});
    typing.remove(bot);
    setState(() {});
  }
}
