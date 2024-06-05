import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/pages/GroupChat/searchpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import '../../Auth/auth.dart';
import '../../Auth/chat_user.dart';
import '../../helper/my_date_util.dart';
import '../../main.dart';
import 'groupchatScreen.dart';
import 'groupdislaog.dart';
import 'groupprofile.dart';

class GroupListChat extends StatefulWidget {
  const GroupListChat({super.key});

  @override
  State<GroupListChat> createState() => _GroupListChatState();
}

class _GroupListChatState extends State<GroupListChat> {
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  List<ChatUser> _userList = [];
  List<GroupUser> _groupList = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  Set<ChatUser> _selectedUsers = Set<ChatUser>();
  int selection = 0;

  Stream? groups;





  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          title: Text('Groups'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GroupSearch()));
                },
                icon: Icon(Boxicons.bx_search)),
            IconButton(
                onPressed: () {
                  _showPopupMenu(context);
                },
                icon: Icon(Boxicons.bx_dots_vertical))
          ],
        ),
        body: StreamBuilder(
          stream: APIs.getMyGroups(),
          builder: (context, groupSnapshot) {
            switch (groupSnapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );

              case ConnectionState.active:
              case ConnectionState.done:
                final groupData = groupSnapshot.data?.docs;
                _groupList = groupData
                        ?.map((e) => GroupUser.fromJson(
                            e.data() as Map<String, dynamic>))
                        .toList() ??
                    [];

                // _groupList.sort((a, b) =>
                //     DateTime.parse(MyDateUtil.getFormattedTime(context: context, time: b.recentmsgtime))
                //         .compareTo(DateTime.parse(a.recentmsgtime)));

                // _groupList.sort((a, b) => b.parseRecentMessageTime().compareTo(a.parseRecentMessageTime()));


                if (_userList.isNotEmpty || _groupList.isNotEmpty) {
                  return ListView.builder(
                    itemCount: _isSearching
                        ? _searchList.length
                        : (_userList.length + _groupList.length),
                    padding: EdgeInsets.only(top: mq.height * .01),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      // Display group card
                      final groupIndex = index - _userList.length;
                      return GestureDetector(
                        onTap: () {

                        },
                        child: GroupCard(
                          group: _groupList[groupIndex],
                          // Add any necessary properties
                        ),
                      );
                    },
                  );
                } else {
                  return  Center(
                    child: noGroupWidget()
                  );
                }
            }
          },
        ));
  }




  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
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
          value: '1', // Use String literals
          child: Text('New Group'),
        ),
      ],
    );

    // Convert the selection to String
    String selectionString = selection?.toString() ?? '';

    if (selectionString == '1') {
      // Navigate to Groupdialog
      Navigator.push(context, MaterialPageRoute(builder: (_) => Groupdialog()));
    }
  }
}

class GroupUser {
  final String groupId;
  final String name;
  final String groupName;
  final String groupImage;
  final String groupDes;
  final String recentmsg;
  final String recentmsgsender;
  final String createdat;
  final String recentmsgtime;

  GroupUser(
      {required this.groupId,
      required this.groupName,
      required this.groupImage,
      required this.groupDes,
      required this.recentmsg,
      required this.name,
      required this.recentmsgsender,
      required this.recentmsgtime,
      required this.createdat});

  factory GroupUser.fromJson(Map<String, dynamic> json) {
    return GroupUser(
        groupId: json['groupId'] ?? '',
        groupName: json['groupName'] ?? '',
        groupImage: json['groupIcon'] ?? '',
        groupDes: json['description'] ?? '',
        createdat: json['createdAt'] ?? '',
        name: json['name'] ?? '',
        recentmsg: json["recentMessage"] ?? '',
        recentmsgsender: json["recentMessageSender"] ?? '',
        recentmsgtime: json['recentMessageTime'] ?? '');
  }


  DateTime parseRecentMessageTime() {
    // Assuming "recentmsgtime" is in the format "HH:mm"
    // Prepend today's date to the time string and parse it as DateTime
    final today = DateTime.now();
    final timeString = recentmsgtime.split(':');
    final recentMessageDateTime = DateTime(
      today.year,
      today.month,
      today.day,
      int.parse(timeString[0]),
      int.parse(timeString[1]),
    );
    return recentMessageDateTime;
  }
// Add toJson() method if needed

// Add any other methods or properties if needed
}

class GroupCard extends StatelessWidget {
  final GroupUser group;

  const GroupCard({
    required this.group,
    Key? key,
  }) : super(key: key);

  String _truncateRecentMessage(String message) {
    const maxLength = 5; // Set your desired maximum length
    return message.length > maxLength
        ? '${message.substring(0, maxLength)}...' // Truncate and add ellipsis
        : message;
  }

  @override
  Widget build(BuildContext context) {
    var widget;
    return GestureDetector(
      onTap: () => {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => Groupdialog()))
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 6),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          child: ListTile(
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => GroupChatScreen(
                            groupId: group.groupId,
                            username: group.name,
                            groupname: group.groupName,
                            groupicon: group.groupImage,
                            join: group.createdat,
                            des: group.groupDes,
                          )))
            },
            leading: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => GroupProfile(
                          image: group.groupImage,
                          groupname: group.groupName,
                          des: group.groupDes,
                          join: group.createdat,
                        ));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * 0.03),
                child: CachedNetworkImage(
                  width: mq.height * 0.055,
                  height: mq.height * 0.055,
                  imageUrl: group.groupImage,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
              ),
            ),
            title: Text(group.groupName),
            subtitle: group.recentmsg != null && group.recentmsg.isNotEmpty
                ? Text(
                    "${group.recentmsgsender}: ${_truncateRecentMessage(group.recentmsg)}",
                  )
                : const Text(''),
            trailing: group.recentmsg != null && group.recentmsg.isNotEmpty
                ? Text(
                    MyDateUtil.getLastMessageTime(
                        context: context, time: group.recentmsgtime),
                    style: const TextStyle(color: Colors.black54),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
