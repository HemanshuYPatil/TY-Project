import 'package:flutter/material.dart';
import 'package:chatapp/helper/my_date_util.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final String sender;
  final String time;
  final bool sentByMe;

  const MessageTile({
    Key? key,
    required this.message,
    required this.time,
    required this.sender,
    required this.sentByMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 6,
        bottom: 4,
        left: sentByMe ? 0 : 24,
        right: sentByMe ? 24 : 0,
      ),
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: sentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: sentByMe
                ? const EdgeInsets.only(left: 30)
                : const EdgeInsets.only(right: 30),
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: sentByMe ? Radius.circular(20) : Radius.zero,
                bottomRight: sentByMe ? Radius.zero : Radius.circular(20),
              ),
              color: sentByMe
                  ? Color.fromRGBO(54, 96, 255, 1)
                  : Color.fromRGBO(231, 235, 244, 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sentByMe ? "You" : sender,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: sentByMe ? Colors.white : Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: sentByMe ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  MyDateUtil.groupmessagetime(
                    context: context,
                    time: time,
                  ),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    color: sentByMe ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
