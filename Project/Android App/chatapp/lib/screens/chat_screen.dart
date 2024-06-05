import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/pages/Calls/call.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chatapp/Auth/auth.dart';
import 'package:ionicons/ionicons.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../Auth/chat_user.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/message.dart';
import '../pages/Profile/ViewProfile.dart';
import '../widgets/message_card.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _replyFocusNode = FocusNode();
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  String replymsg = '';
  String replysender = '';
  bool _isTextType = false;
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool _isListening = false;
  bool isVideo = true;

  @override
  void initState() {
    
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      bool hasSpeech = await _speechToText.initialize();
      if (hasSpeech) {
        print('SpeechToText initialized successfully');
      } else {
        print('SpeechToText initialization failed');
      }
    } catch (e) {
      print('SpeechToText initialization error: $e');
    }

    setState(() {});
  }

  void _startListening() async {
    if (_speechToText.isAvailable) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {
        _isListening = true;
      });
      alert();
    } else {
      print('SpeechToText not initialized successfully.');
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
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

                automaticallyImplyLeading: false, flexibleSpace: _appBar()),
            backgroundColor: const Color.fromRGBO(251, 252, 255, 1),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list != null && _list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                // return SwipeTo(
                                //   onRightSwipe: (details) {
                                //     _messagereply(details, _list[index]);
                                //     _replyFocusNode.requestFocus();
                                //   },
                                //   child: SizedBox(
                                //     // height: replymsg.isNotEmpty ? null : 162.0,
                                //     child: MessageCard(message: _list[index]),
                                //   ),
                                // );

                                return MessageCard(message: _list[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('Say Hii! 👋',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),
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
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewProfileScreen(user: widget.user),
          ),
        );
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              IconButton(
                onPressed: () {Navigator.pop(context);},
                icon: const Icon(Ionicons.chevron_back_outline),
              ),
              SizedBox(width: 5,),
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                  width: mq.height * .05,
                  height: mq.height * .05,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive,
                              )
                        : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive,
                          ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              //
              // Column(
              //   children: [
              //     Expanded(
              //       child: ZegoSendCallInvitationButton(
              //         invitees: [ZegoUIKitUser(id: widget.user.id, name: widget.user.name)],
              //         isVideoCall: isVideo,
              //       ),
              //     ),
              //     // Other widgets
              //   ],
              // )
            ],
          );
        },
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .01,
        horizontal: mq.width * .025,
      ),
      child: Column(
        children: [
          // Display the reply message
          if (replymsg.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: 0.0, left: 8.0, right: 55.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Color.fromRGBO(231, 235, 244, 10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, color: Colors.blue),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: FutureBuilder<String?>(
                      future: APIs.getreplyname(replysender),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Text('Error loading reply name');
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return Text('User not found');
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Replying to: ${snapshot.data}',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  replymsg,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          }
                        } else {
                          // You can return another widget here if you don't want to display anything while loading
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        replymsg = '';
                        _replyFocusNode.unfocus();
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

          // The main chat input
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Color.fromRGBO(231, 235, 244, 10),
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
                          focusNode: _replyFocusNode,
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onChanged: (text) {
                            // setState(() {
                            //   _isTextType = text.isNotEmpty;
                            // });
                          },
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
                      SizedBox(width: mq.width * .02),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                  onPressed: () async {
                    if (_textController.text.isNotEmpty) {
                      if (_list.isEmpty) {
                        APIs.sendFirstMessage(
                          widget.user,
                          _textController.text,
                          Type.text,
                          Reply(
                            replierName: replysender,
                            replyMessage: replymsg,
                          ),
                        );
                      } else {
                        APIs.sendMessage(
                          widget.user,
                          _textController.text,
                          Type.text,
                          Reply(
                            replierName: replysender,
                            replyMessage: replymsg,
                          ),
                        );
                      }
                      _textController.text = '';
                      setState(() {
                        replymsg = '';
                        _replyFocusNode.unfocus();
                      });
                    }
                  },
                  minWidth: 0,
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    right: 10,
                    left: 10,
                  ),
                  shape: const CircleBorder(),
                  color: Color.fromRGBO(50, 95, 236, 5),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 25,
                  )),
            ],
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
            if (isMe)
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
                    await APIs.sendChatImage(
                        widget.user,
                        File(i.path),
                        Reply(
                            replierName: replysender, replyMessage: replymsg));
                    setState(() => _isUploading = false);
                  }
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
                final XFile? video = await picker.pickVideo(
                  source: ImageSource.gallery,
                );

                if (video != null) {
                  log('Video Path: ${video.path}');
                  setState(() => _isUploading = true);
                  await APIs.sendChatVideo(widget.user, File(video.path));
                  setState(() => _isUploading = false);
                }
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),
            _OptionItem(
              icon: const Icon(Icons.camera, color: Colors.blue),
              name: 'Camera',
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                if (image != null) {
                  log('Image Path: ${image.path}');
                  setState(() => _isUploading = true);
                  await APIs.sendChatImage(
                    widget.user,
                    File(image.path),
                    Reply(
                      replierName: replysender,
                      replyMessage: replymsg,
                    ),
                  );
                  setState(() => _isUploading = false);
                }
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

  AlertDialog alert() {
    return AlertDialog(
      title: Text("Speech Recognition"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VoiceWaveAnimation(isListening: _isListening),
          SizedBox(height: 16),
          Text("Last Words: $_lastWords"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _stopListening();
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            _stopListening();
            Navigator.of(context).pop(_lastWords);
          },
          child: Text("Done"),
        ),
      ],
    );
  }

  void _messagereply(DragUpdateDetails details, Message message) {
    print('Reply to: ${message.msg}');
    setState(() {
      replymsg = message.msg;
      replysender = message.fromId;
    });
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

class VoiceWaveAnimation extends StatelessWidget {
  final bool isListening;

  const VoiceWaveAnimation({Key? key, required this.isListening})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 200,
      decoration: BoxDecoration(
        color: isListening ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: isListening ? 80 : 40,
          width: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
