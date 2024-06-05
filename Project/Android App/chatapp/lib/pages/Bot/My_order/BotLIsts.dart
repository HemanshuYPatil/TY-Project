// ignore: file_names
import 'package:chatapp/Auth/bot.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/pages/Bot/BotChat/BotchatScreen.dart';
import 'package:chatapp/pages/Bot/CreateBot/newbot.dart';
import 'package:chatapp/pages/Bot/CreateBot/sellerdetails.dart';
import 'package:chatapp/pages/Bot/FoodDevlivery/Food.dart';
import 'package:chatapp/pages/Bot/My_order/MyOrder.dart';
import 'package:chatapp/pages/Bot/NewBot.dart';
import 'package:chatapp/pages/Bot/Payment/payment_method.dart';
import 'package:chatapp/pages/Bot/notification.dart';
import 'package:chatapp/pages/Calls/call.dart';
import 'package:chatapp/pages/Profile/setting_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:badges/badges.dart' as badges;
import 'package:ionicons/ionicons.dart';
import '../../../Auth/auth.dart';
import '../../../main.dart';

import '../../Profile/froeward_btn.dart';
import '../../Profile/profile.dart';
import '../../Profile/setting_page.dart';

import '../botsearch.dart';

class BotModel {
  final String name;
  final Widget page;
  final String botid;
  BotModel({required this.name, required this.page,required this.botid});
}

class AllBotLists extends StatefulWidget {
  const AllBotLists({Key? key}) : super(key: key);

  @override
  State<AllBotLists> createState() => _AllBotListsState();
}

class _AllBotListsState extends State<AllBotLists> {
  final List<BotModel> bots = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(9),
        child: StreamBuilder<QuerySnapshot>(
          stream: BotBackend.getAllBots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Failed to Load Bot');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final DocumentSnapshot document = snapshot.data!.docs[index];
                  final String name = document['BotName'];
                  final String des = document['description'];
                  final String id = document['BotId'];
                  final String privacy = document['BotPrivacy'];
                  final String type = document['Type'];
                  final String admin = document['admin'];
                  final String adminId = document['AdminId'];
                  final String createdat = document['createdAt'];
                  final String token = document['AdminPushToken'];


                  return BotCard(
                    bot: BotModel(
                      name: name,
                      botid: id,
                      page: BotChatScreen(
                        name: name,
                        type: type,
                        id: id,
                        admin: admin,
                        createdat: createdat,
                        privacy: privacy,
                        des: des,
                        token: token,
                        adminid: adminId,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),

    );
  }


}

class BotCard extends StatelessWidget {
  final BotModel bot;

  const BotCard({Key? key, required this.bot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // color: Colors.blue.withOpacity(0.1),
          ),
          child: Row(
            children: [
              // Display user's image
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.03),
                child: const CircleAvatar(
                  child: Icon(Boxicons.bx_bot),
                ),
              ),

              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display user's name obtained from widget.user
                    Text(
                      bot.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // SizedBox(height: 10),
                    // // Display user's role or description
                    // Text(
                    //   bot.page.toString(),
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: Colors.grey,
                    //   ),
                    // )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>My_Order(botdocId: bot.botid)));
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Ionicons.chevron_forward_outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
