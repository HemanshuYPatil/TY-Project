import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Auth/auth.dart';
import '../Auth/chat_user.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialog.dart';

class Gorupcard extends StatefulWidget {
  final ChatUser user;

  const Gorupcard({Key? key, required this.user}) : super(key: key);

  @override
  State<Gorupcard> createState() => _GorupcardState();
}

class _GorupcardState extends State<Gorupcard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(user: widget.user),
            ),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];

            return ListTile(
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.03),
                  child: CachedNetworkImage(
                    width: mq.height * 0.055,
                    height: mq.height * 0.055,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
              ),
              title: Text(widget.user.name),
              subtitle: _message != null
                  ? _message!.type == Type.image ? Text('image') : Text(_message!.msg, maxLines: 1)
                  : Text(widget.user.about, maxLines: 1),
              trailing: _message != null
                  ? _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                      ? Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                          style: const TextStyle(color: Colors.black54),
                        )
                  : null, // Do not show last message time when no message is sent
            );
          },
        ),
      ),
    );
  }
}
