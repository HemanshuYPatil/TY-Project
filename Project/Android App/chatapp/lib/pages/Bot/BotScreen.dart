// ignore: file_names
import 'package:chatapp/Auth/bot.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/pages/Bot/BotChat/BotchatScreen.dart';
import 'package:chatapp/pages/Bot/CreateBot/createnewbot.dart';
import 'package:chatapp/pages/Bot/CreateBot/newbot.dart';
import 'package:chatapp/pages/Bot/CreateBot/otp.dart';
import 'package:chatapp/pages/Bot/CreateBot/sellerdetails.dart';
import 'package:chatapp/pages/Bot/FoodDevlivery/Food.dart';
import 'package:chatapp/pages/Bot/My_order/MyOrder.dart';
import 'package:chatapp/pages/Bot/NewBot.dart';
import 'package:chatapp/pages/Bot/Payment/ex.dart';
import 'package:chatapp/pages/Bot/Payment/payment_method.dart';
import 'package:chatapp/pages/Bot/notification.dart';
import 'package:chatapp/pages/Calls/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:badges/badges.dart' as badges;
import '../../Auth/auth.dart';
import '../../main.dart';
import '../Profile/setting_page.dart';
import 'ChatBuddyGPT/ChatBuddyGPT.dart';
import 'botsearch.dart';

class BotModel {
  final String name;
  final Widget page;

  BotModel({required this.name, required this.page});
}

class BotLists extends StatefulWidget {
  const BotLists({Key? key}) : super(key: key);

  @override
  State<BotLists> createState() => _BotListsState();
}

class _BotListsState extends State<BotLists> {
  final List<BotModel> bots = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Bots'),
        centerTitle: true,
        actions: [
          Center(
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> NotificationPage()));
              },
              child: const Badge(
                // isLabelVisible: false,
                label: Text('1'),
                child: Icon(Boxicons.bx_bell),
              ),
            ),
          ),
          // SizedBox(width: 10.0,),

          SizedBox(width: 10.0,),
          IconButton(
              onPressed: () {
                 _showPopupMenu(context);
              },
              icon: Icon(Boxicons.bx_dots_vertical)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: BotBackend.getMyBot(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Failed to Load Bot');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // return  Center(
            //   child: Dialogs.showProgressBar(context)
            // );
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

                return Card(
                  margin: EdgeInsets.symmetric(
                      horizontal: mq.width * 0.04, vertical: 5),
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: InkWell(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BotChatScreen(
                                      name: name,
                                      type: type,
                                      id: id,
                                      admin: admin,
                                      createdat: createdat,

                                      privacy: privacy,
                                      des: des,
                                      token: token,
                                      adminid: adminId
                                    )));
                      },
                      leading: InkWell(
                        onTap: () {},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.03),
                          child: const CircleAvatar(
                            child: Icon(Boxicons.bx_bot),
                          ),
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(des),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => CreateNewBot()));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
  void _showPopupMenu(BuildContext context) async {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    dynamic selection = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(overlay.size.width, 90, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      items: <PopupMenuEntry>[
        const PopupMenuItem(
          value: '1',
          // Use String literals
          child: Text('Search Bot'),
        ),
        // const PopupMenuItem(
        //   value: '2',
        //   // Use String literals
        //   child: Text('Create Bot'),
        // ),

      ],
    );

    // Convert the selection to String
    String selectionString = selection?.toString() ?? '';

    if (selectionString == '1') {
      Navigator.push(context, MaterialPageRoute(builder: (_)=> BotSearch()));
    }
    if (selectionString == '2') {
      Navigator.push(context, MaterialPageRoute(builder: (_)=> OtpScreen()));

    }
  }
}

class BotCard extends StatelessWidget {
  final BotModel bot;

  const BotCard({Key? key, required this.bot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => bot.page));
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * 0.01, vertical: 2),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          child: ListTile(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => bot.page));
            },
            leading: InkWell(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.03),
                child: const CircleAvatar(
                  child: Icon(Boxicons.bx_bot),
                ),
              ),
            ),
            title: Text(bot.name),
            subtitle: const Text('AI Chat Model'),
          ),
        ),
      ),
    );
  }


}

class BotData {
  final String botname;
  final String bottype;
  final String des;
  final String createdAt;
  final String admin;
  final String privacy;
  final String botId;
  final String token;
  BotData(
      {required this.botname,
      required this.bottype,
      required this.des,
      required this.createdAt,
      required this.admin,
      required this.privacy,
      required this.botId,
      required this.token});

  factory BotData.fromJson(Map<String, dynamic> json) {
    return BotData(
        botname: json['BotName'] ?? '',
        bottype: json['Type'] ?? '',
        des: json['description'] ?? '',
        createdAt: json['createdAt'] ?? '',
        admin: json['admin'] ?? '',
        privacy: json['BotPrivacy'] ?? '',
        botId: json["BotId"] ?? '',
        token: json["AdminPushToken"] ?? '');
  }
}
