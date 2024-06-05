import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Auth/bot.dart';
import 'package:chatapp/pages/Bot/BotInfo.dart';
import 'package:chatapp/pages/Bot/My_order/MyOrder.dart';
import 'package:chatapp/pages/Calls/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';

import '../../../main.dart';
import '../data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BotChatScreen extends StatefulWidget {
  final String name, id, type, admin, createdat, des, privacy, token, adminid;
  const BotChatScreen(
      {Key? key,
      required this.token,
      required this.name,
      required this.des,
      required this.type,
      required this.createdat,
      required this.admin,
      required this.privacy,
      required this.id,
      required this.adminid})
      : super(key: key);

  @override
  State<BotChatScreen> createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  late ChatUser bot;
  late ChatUser myself;
  List<ChatMessage> allmsg = [];
  List<ChatUser> typing = [];
  bool _showEmoji = false;
  List<dynamic>? orderDetails;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('icon');

  @override
  void initState() {
    super.initState();
    myself = ChatUser(
      id: '1',
      firstName: FirebaseAuth.instance.currentUser!.displayName.toString(),
    );
    bot = ChatUser(id: '2', firstName: "${widget.name} Bot");
    intializenotification();
  }

  void intializenotification() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  sendnotification(String title, String body) {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails('channelId', 'channelName',
            playSound: true,
            priority: Priority.max,
            importance: Importance.high,
            enableVibration: true);

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),

            ),
            backgroundColor: const Color.fromRGBO(251, 252, 255, 1),
            body: Stack(children: [
              DashChat(
                currentUser: myself,
                onSend: (ChatMessage m) {
                  getmsg(m);
                },
                typingUsers: typing,
                messages: allmsg,
                messageListOptions: const MessageListOptions(
                  scrollPhysics: BouncingScrollPhysics(),
                ),
                messageOptions: const MessageOptions(borderRadius: 10.0),
              ),
              if (allmsg.isEmpty) // Condition to check if message list is empty
                Center(
                  child: Text(
                    "Hey, it's me, ${widget.name} Bot. Let's chat!",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  void getmsg(ChatMessage m) async {
    print(m.text);
    typing.add(bot);
    allmsg.insert(0, m);
    setState(() {});

    var data = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": "hi"}
          ]
        },
        {
          "role": "model",
          "parts": [
            {"text": "Hello there! How can I assist you today?"}
          ]
        },
        {
          "role": "user",
          "parts": [
            {"text": "you are a delivery bot"}
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text":
                  "That's correct, I am a delivery bot. I am designed to assist with the delivery of items to customers. I can provide you with information about your order, track its progress, and help you with any issues you may encounter.\n\nDo you have any questions or need assistance with a delivery?"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "remember your conversation with customers should short and one line up "
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text":
                  "Got it. I will keep my responses short and to the point.\n\nIs there anything I can assist you with today?"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "your work is to take a order details and user details like phone number,delivery address all field are required"
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text":
                  "Sure, here is the information I need to process your order:\n\n 1.Item ordered:\n 2.Quantity:\n 3.Delivery address:\n 4.Phone number:\n\nOnce I have this information, I can process your order and provide you with an estimated delivery time.\n\nIs there anything else I can assist you with today?"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "when you placed an order display order item,delivery address , phone number always and also only this line in double comma \"Order successfully placed. Thank you for choosing our services!\""
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text":
                  "Order Details\n Ordered Item : \n Delivery Location: \n Phone Number:  \nOrder successfully placed. Thank you for choosing our services!"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              // ignore: unnecessary_string_interpolations
              "text": "${m.text}"
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.9,
        "topK": 1,
        "topP": 1,
        "maxOutputTokens": 500,
        "stopSequences": []
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ]
    };

    try {
      final response = await http.post(Uri.parse(base_url),
          headers: header, body: jsonEncode(data));

      if (response.statusCode == 200) {
        setState(() {
          orderDetails = jsonDecode(response.body)['candidates'];
        });
        var result = jsonDecode(response.body);
        print(data);
        print(result);
        print(result['candidates'][0]['content']['parts'][0]['text']);

        String text = result['candidates'][0]['content']['parts'][0]['text'];

        List<String> wordsToSearch = [
          "order",
          "placed",
          "successfully",
          "Thank you",
          "choosing",
          "services"
        ];

        bool allWordsPresent = wordsToSearch
            .every((word) => text.toLowerCase().contains(word.toLowerCase()));

        String orderd = extractOrderedItem(
            result['candidates'][0]['content']['parts'][0]['text']);
        String deliverylocation = extractDeliveryLocation(
            result['candidates'][0]['content']['parts'][0]['text']);
        String phonenumber = extractPhonenumber(
            result['candidates'][0]['content']['parts'][0]['text']);

        if(orderd.isNotEmpty && deliverylocation.isNotEmpty && phonenumber.isNotEmpty) {
          if (allWordsPresent) {
            String orderid = generateRandomString();
            try {
              Future.delayed(const Duration(seconds: 2), () {
                sendnotification(
                    'Ordered Placed at ${widget.name}',
                    'Your Ordered Delivery in few Minutes ');
              });

           
              BotBackend.sendPushNotification(
                  "New Ordered Received",
                  widget.token,
                  "From ${FirebaseAuth.instance.currentUser!
                      .displayName}\n Ordered Item : ${orderd}");

              BotBackend.createNotification(
                  widget.admin,
                  orderd,
                  deliverylocation,
                  phonenumber,
                  FirebaseAuth.instance.currentUser!.displayName.toString(),
                  orderid);

              BotBackend.CreateSellerNotification(
                  widget.id, user.displayName.toString(), deliverylocation,
                  phonenumber, orderd, orderid);
            } catch (e) {
              print(e);
            }
          }
        }
        // BotBackend.sendPushNotification("title", widget.token, "msg", user.uid);

        ChatMessage m1 = ChatMessage(
          user: bot,
          createdAt: DateTime.now(),
          text: result['candidates'][0]['content']['parts'][0]['text'],
        );

        allmsg.insert(0, m1);

        final updatedMessages = List<ChatMessage>.from(allmsg);
        setState(() {
          allmsg = updatedMessages;
        });
      }
    } catch (error) {
      print('Error: $error');
    }

    typing.remove(bot);
    setState(() {});
  }

  String extractOrderedItem(String orderDetails) {
    RegExp regExp = RegExp(r'(Ordered\s)?Item\s?:\s?([^\n]+)');
    return regExp.firstMatch(orderDetails)?.group(2) ?? '';
  }

  String extractDeliveryLocation(String orderDetails) {
    RegExp regExp = RegExp(r'Delivery Location: ([^\n]+)');
    return regExp.firstMatch(orderDetails)?.group(1) ?? '';
  }

  String extractPhonenumber(String orderDetails) {
    RegExp regExp = RegExp(r'Phone Number: ([^\n]+)');
    return regExp.firstMatch(orderDetails)?.group(1) ?? '';
  }

  String generateRandomString() {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    final result = StringBuffer();
    for (int i = 0; i < 8; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }
    return result.toString();
  }

  Widget _appBar() {
    return StreamBuilder(
      builder: (context, snapshot) {
        final data = snapshot.data as QuerySnapshot<Map<String, dynamic>>?;

        final List<ChatUser> list = data?.docs
                .map((e) => ChatUser.fromJson(e.data() as Map<String, dynamic>))
                .toList() ??
            [];

        return InkWell(
          child: Row(
            children: [
              IconButton(
                onPressed: () {Navigator.pop(context);},
                icon: const Icon(Ionicons.chevron_back_outline),
              ),
              SizedBox(width: 5,),
              CircleAvatar(
                child: InkWell(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: const CircleAvatar(
                      child: Icon(Boxicons.bx_bot),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

