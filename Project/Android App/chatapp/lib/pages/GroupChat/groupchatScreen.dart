import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Auth/auth.dart';
import 'package:chatapp/Auth/chat_user.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/pages/GroupChat/groupviewprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';

import '../../helper/my_date_util.dart';
import '../../main.dart';
import '../../models/message.dart';
import '../../widgets/group_message.dart';
import '../../widgets/message_card.dart';
import 'groupinfo.dart';

class GroupChatScreen extends StatefulWidget {
  final String username;
  final String groupId;
  final String groupname;
  final String groupicon;
  final String des;
  final String join;
  const GroupChatScreen({
    Key? key,
    required this.groupId,
    required this.username,
    required this.groupname,
    required this.groupicon,
    required this.des,
    required this.join,
  }) : super(
          key: key,
        );

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  String admin = "";
  Stream<QuerySnapshot<Map<String, dynamic>>>? chats;
  late ScrollController _scrollController;

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
    _scrollController = ScrollController();
  }

  getChatandAdmin() {
    APIs.getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        admin = value;
      });
    });

    APIs.getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
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
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GroupInfo(
                                  groudId: widget.groupId,
                                  groupname: widget.groupname,
                                  adminname: admin)));
                    },
                    icon: const Icon(Icons.info))
              ],
            ),
            backgroundColor: const Color.fromRGBO(251, 252, 255, 1),
            body: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      _buildMessagesList(),
                      if (_isUploading)
                        const Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ]
                        )
                    ],
                  ),
                ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
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

  Widget _appBar() {
    return StreamBuilder(
      builder: (context, snapshot) {
        final data = snapshot.data as QuerySnapshot<Map<String, dynamic>>?;

        final List<ChatUser> list = data?.docs
                .map((e) => ChatUser.fromJson(e.data() as Map<String, dynamic>))
                .toList() ??
            [];

        return InkWell(
          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> GroupViewProfile(name: widget.groupname, join: widget.join, des: widget.des, url: widget.groupicon))),

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
                    child: CachedNetworkImage(
                      width: mq.height * .05,
                      height: mq.height * .05,
                      imageUrl: list.isNotEmpty ? list[0].image : widget.groupicon,
                      errorWidget: (context, url, error) =>
                          const CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(list.isNotEmpty ? list[0].name : widget.groupname,
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

  Widget _buildMessagesList() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        final messages = snapshot.data?.docs;

        return messages != null && messages.isNotEmpty
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                reverse: true,
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = messages.length - 1 - index;
                  return MessageTile(
                    time: messages[reversedIndex]['time'].toString(),
                    message: messages[reversedIndex]['message'],
                    sender: messages[reversedIndex]['sender'],
                    sentByMe: FirebaseAuth.instance.currentUser?.displayName ==
                        messages[reversedIndex]['sender'],
                  );
                },
              )
            :  Container(
                child: const Center(
                  child: Text("Say Hii! 👋", style: TextStyle(
                    fontSize: 20
                  ),),
                ),
              );
      },
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .01,
        horizontal: mq.width * .025,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: const Color.fromRGBO(231, 235, 244, 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.black87,
                      size: 25,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type a Message',
                        hintStyle: TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      bool isMe = true;
                      _showBottomSheet(isMe);
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() => _isUploading = true);
                        // await APIs.sendGroupImage(File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              if (_textController.text.isNotEmpty) {
                Map<String, dynamic> chatMessageMap = {
                  "message": _textController.text,
                  "sender":
                      FirebaseAuth.instance.currentUser?.displayName ?? "",
                  "time": DateTime.now().millisecondsSinceEpoch,
                };
                await APIs.sendGroupMessage(widget.groupId, chatMessageMap);
                _textController.text = '';
              } else {
                // Dialogs.showSnackbar(context, 'Empty');
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: const Color.fromRGBO(50, 95, 236, 5),
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: mq.height * .015,
                horizontal: mq.width * .4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            _OptionItem(
              icon: const Icon(Icons.image, color: Colors.red, size: 26),
              name: 'Image',
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final List<XFile> images =
                    await picker.pickMultiImage(imageQuality: 70);

                for (var i in images) {
                  log('Image Path: ${i.path}');
                  setState(() => _isUploading = true);
                  // await APIs.sendGroupImage(File(i.path));
                  setState(() => _isUploading = false);
                }
                Navigator.pop(context);
              },
            ),
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),
            _OptionItem(
              icon: const Icon(Icons.video_file_outlined, color: Colors.blue),
              name: 'Video',
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? video =
                    await picker.pickVideo(source: ImageSource.gallery);

                if (video != null) {
                  log('Video Path: ${video.path}');
                  setState(() => _isUploading = true);
                  // await APIs.sendGroupVideo(File(video.path));
                  setState(() => _isUploading = false);
                }
                Navigator.pop(context);
              },
            ),
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),
          ],
        );
      },
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .015,
          bottom: mq.height * .015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '    $name',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
