import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/helper/my_date_util.dart';
import 'package:chatapp/pages/Bot/ChatBuddyGPT/ChatBuddyGPT.dart';
import 'package:chatapp/pages/Calls/call.dart';
import 'package:chatapp/pages/GroupChat/groupdislaog.dart';
import 'package:chatapp/pages/GroupChat/groupprofile.dart';
import 'package:chatapp/pages/GroupChat/searchpage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chatapp/Auth/auth.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import '../../Auth/chat_user.dart';


import 'package:chatapp/main.dart';
import 'package:chatapp/widgets/chat_user_card.dart';
import '../../helper/dialogs.dart';
import '../GroupChat/groupchatScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _userList = [];
  List<GroupUser> _groupList = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  Set<ChatUser> _selectedUsers = Set<ChatUser>();
  int selection = 0;

  Stream? groups;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            // backgroundColor: Theme.of(context).colorScheme.background,

            leading: const Icon(Boxicons.bx_home),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email, ...',
                    ),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (val) {
                      _searchList.clear();

                      for (var i in _userList) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                  )
                : const Text('Chats'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });

                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (_) => GroupSearch()));
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Boxicons.bx_search,
                ),
              ),
              IconButton(
                onPressed: () async {
                  _showPopupMenu(context);
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {
                _addChatUserDialog();
              },
              child: const Icon(Icons.add),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, userSnapshot) {
              switch (userSnapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                      userSnapshot.data?.docs.map((e) => e.id).toList() ?? [],
                    ),
                    builder: (context, userSnapshot) {
                      switch (userSnapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final userData = userSnapshot.data?.docs;
                          _userList = userData
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          return StreamBuilder(
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

                                  // if (_userList.isNotEmpty || _groupList.isNotEmpty) {
                                    if (_userList.isNotEmpty){
                                    return ListView.builder(
                                      itemCount: _isSearching
                                          ? _searchList.length
                                          : (_userList.length +
                                              _groupList.length),
                                      padding:
                                          EdgeInsets.only(top: mq.height * .01),
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        if (index < _userList.length) {

                                          return GestureDetector(
                                            onLongPress: () {
                                              _toggleSelection(
                                                  _userList[index]);
                                            },
                                            onTap: () {
                                              _toggleSelection(
                                                  _userList[index]);
                                            },
                                            child: ChatUserCard(
                                              user: _userList[index],
                                              isSelected:
                                                  _isSelected(_userList[index]),
                                            ),
                                          );
                                        }
                                      }

                                    );
                                  } else {
                                    return const Center(
                                      child: Text(
                                        'No Chat Found!',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    );
                                  }
                              }
                            },
                          );
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  bool _isSelected(ChatUser user) {
    return _selectedUsers.contains(user);
  }

  void _toggleSelection(ChatUser user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
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

        const PopupMenuItem(
          value: '2', // Use String literals
          child: Text('Call History'),
        ),

      ],
    );

    // Convert the selection to String
    String selectionString = selection?.toString() ?? '';

    if (selectionString == '1') {
      // Navigate to Groupdialog
      Navigator.push(context, MaterialPageRoute(builder: (_) => Groupdialog()));
    }

    if (selectionString == '2') {
      // Navigate to Groupdialog
      Navigator.push(context, MaterialPageRoute(builder: (_) => Calls()));
    }
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.person_add,
              color: Colors.blue,
              size: 28,
            ),
            Text('  Add User'),
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'Email Id',
            prefixIcon: const Icon(Icons.email, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              Navigator.pop(context);
              if (email.isNotEmpty) {
                await APIs.addChatUser(email).then((value) {
                  if (!value) {
                    Dialogs.showSnackbar(context, 'User does not exist!');
                  }
                });
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  // return GroupTile(
                  //     groupId: getId(snapshot.data['groups'][reverseIndex]),
                  //     groupName: getName(snapshot.data['groups'][reverseIndex]),
                  //     userName: snapshot.data['fullName']);
                  return Text('data');
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
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
        recentmsgtime: json['recentMessageTime'] ?? ''
    );
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
                ?  Text(
              "${group.recentmsgsender}: ${_truncateRecentMessage(group.recentmsg)}",
            )
                : const Text(''),

            trailing: group.recentmsg != null && group.recentmsg.isNotEmpty
                ? Text(MyDateUtil.getLastMessageTime(context: context, time: group.recentmsgtime),style: const TextStyle(color: Colors.black54),)
                : null,

          ),
        ),
      ),
    );


  }
}
