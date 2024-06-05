import 'dart:developer';
import 'package:chatapp/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/pages/imagescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';

import '../Auth/auth.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/message.dart';
import '../pages/vedioplayer.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({Key? key, required this.message}) : super(key: key);

  final Message message;

  @override
  _MessageCardState createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  VideoPlayerController? _videoPlayerController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == Type.video) {
      _videoPlayerController =
          VideoPlayerController.network(widget.message.msg);
      _initializeVideoPlayerFuture = _videoPlayerController!.initialize();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    bool isMe = APIs.user.uid == widget.message.fromId;

    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ... (your existing code)

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(widget.message.type == Type.image
                      ? mq.width * .03
                      : mq.width * .04),
                  margin: EdgeInsets.symmetric(
                      horizontal: mq.width * .04, vertical: mq.height * .01),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(231, 235, 244, 20),
                    border:
                    Border.all(color: Color.fromRGBO(231, 235, 244, 10)),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: widget.message.type == Type.text
                      ? Text(
                    widget.message.msg,
                    style:
                    const TextStyle(fontSize: 16, color: Colors.black),
                  )
                      : widget.message.type == Type.image
                      ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ImageScreen(widget.message.msg),
                          ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.image, size: 70),
                      ),
                    ),
                  )
                      : Stack(
                    alignment: Alignment.center,
                    children: [
                      FutureBuilder<void>(
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return AspectRatio(
                              aspectRatio: _videoPlayerController!
                                  .value.aspectRatio,
                              child: VideoPlayer(
                                  _videoPlayerController!),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          (_videoPlayerController?.value.isPlaying ??
                              false)
                              ? Icons.pause_sharp
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerScreen(
                                    widget.message.msg),
                              ));

                          log(widget.message.msg);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: mq.width * .04),
                child: Text(
                  MyDateUtil.getFormattedTime(
                      context: context, time: widget.message.sent),
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _greenMessage() {
    bool isMessageSeen = widget.message.read.isNotEmpty;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // message time
            Row(
              children: [
                // for adding some space
                const SizedBox(width: 8),

                // double tick blue icon for message read
                Icon(
                  isMessageSeen ? Icons.done_all_rounded : Icons.done_rounded,
                  color: Colors.blue,
                  size: 20,
                ),

                // for adding some space
                const SizedBox(width: 2),

                // sent time
                Text(
                  MyDateUtil.groupmessagetime(
                      context: context, time: widget.message.sent),
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),

            // message content wrapped with GestureDetector
            Flexible(
              child: GestureDetector(
                onTap: () {
                  if (widget.message.type == Type.video) {
                    // Open video in video player when clicked
                    // Launch video player with the video URL
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(widget.message.type == Type.image
                      ? mq.width * .03
                      : mq.width * .04),
                  margin: EdgeInsets.symmetric(
                      horizontal: mq.width * .04, vertical: mq.height * .01),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(54, 96, 255, 5),
                    border: Border.all(color: const Color.fromRGBO(54, 96, 255, 5)),
                    // making borders curved
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      // bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: widget.message.type == Type.text
                      ? // show text
                  Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  )
                      : widget.message.type == Type.image
                      ? GestureDetector(
                    onTap: () {
                      print(widget.message.msg);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ImageScreen(widget.message.msg),
                          ));
                    },
                    // show image
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.image, size: 70),
                      ),
                    ),
                  )
                      : // show video
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      FutureBuilder<void>(
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return AspectRatio(
                              aspectRatio:
                              _videoPlayerController!.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController!),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          (_videoPlayerController?.value.isPlaying ??
                              false)
                              ? Icons.pause_sharp
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerScreen(
                                    widget.message.msg),
                              ));

                          log(widget.message.msg);
                        },
                      ),
                    ],
                  ),

                ),
              ),

            ),
            

          ],
        ),
      ],
    );
  }

  // bottom sheet for modifying message details
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
            // black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * .015, horizontal: mq.width * .4),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            widget.message.type == Type.text
                ? // copy option
                _OptionItem(
                    icon: const Icon(Icons.copy_all_rounded,
                        color: Colors.blue, size: 26),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        // for hiding bottom sheet
                        Navigator.pop(context);

                        Dialogs.showSnackbar(context, 'Text Copied!');
                      });
                    },
                  )
                : widget.message.type == Type.image
                    ? // save option
                    _OptionItem(
                        icon: const Icon(Icons.download_rounded,
                            color: Colors.blue, size: 26),
                        name: 'Save Image',
                        onTap: () async {
                          try {
                            log('Image Url: ${widget.message.msg}');
                            await GallerySaver.saveImage(widget.message.msg,
                                    albumName: 'We Chat')
                                .then((success) {
                              // for hiding bottom sheet
                              Navigator.pop(context);
                              if (success != null && success) {
                                Dialogs.showSnackbar(
                                    context, 'Image Successfully Saved!');
                              }
                            });
                          } catch (e) {
                            log('ErrorWhileSavingImg: $e');
                          }
                        },
                      )
                    : // save video
                    _OptionItem(
                        icon: const Icon(Icons.download_rounded,
                            color: Colors.blue, size: 26),
                        name: 'Save Video',
                        onTap: () async {
                          try {
                            log('Video Url: ${widget.message.msg}');
                            await GallerySaver.saveVideo(widget.message.msg,
                                    albumName: 'ChatBuddy')
                                .then((success) {
                              // for hiding bottom sheet
                              if (mounted) {
                                Navigator.pop(context);
                              }
                              if (success != null && success) {
                                Dialogs.showSnackbar(
                                    context, 'Video Successfully Saved!');
                              }
                            });
                          } catch (e) {
                            log('ErrorWhileSavingVideo: $e');
                          }
                        },
                      ),

            // separator or divider
            if (isMe)
              const Divider(
                color: Colors.black54,
                endIndent: 16,
                indent: 16,
              ),

            // edit option
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                name: 'Edit Message',
                onTap: () {
                  // for hiding bottom sheet
                  Navigator.pop(context);

                  _showMessageUpdateDialog();
                },
              ),

            // delete option
            if (isMe)
              _OptionItem(
                icon: const Icon(Icons.delete_forever,
                    color: Colors.red, size: 26),
                name: 'Delete Message',
                onTap: () async {
                  await APIs.deleteMessage(widget.message).then((value) {
                    // for hiding bottom sheet
                    Navigator.pop(context);
                  });
                },
              ),

            // separator or divider
            const Divider(
              color: Colors.black54,
              endIndent: 16,
              indent: 16,
            ),

            // sent time
            _OptionItem(
              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
              name:
                  'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
              onTap: () {},
            ),

            // read time
            _OptionItem(
              icon: const Icon(Icons.remove_red_eye, color: Colors.green),
              name: widget.message.read.isEmpty
                  ? 'Read At: Not seen yet'
                  : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  // dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        // title
        title: Row(
          children: const [
            Icon(
              Icons.message,
              color: Colors.blue,
              size: 28,
            ),
            Text(' Update Message'),
          ],
        ),

        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),

        // actions
        actions: [
          // cancel button
          MaterialButton(
            onPressed: () {
              // hide alert dialog
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),

          // update button
          MaterialButton(
            onPressed: () {
              // hide alert dialog
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updatedMsg);
            },
            child: const Text(
              'Update',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// custom options card (for copy, edit, delete, etc.)
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
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                    fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
