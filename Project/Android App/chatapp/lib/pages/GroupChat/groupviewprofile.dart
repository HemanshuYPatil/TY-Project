import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../helper/my_date_util.dart';
import '../../main.dart';
import '../Calls/call.dart';

class GroupViewProfile extends StatefulWidget {
  final name,des,join,url;
  const GroupViewProfile({super.key,required this.name,required this.join,required this.des,required this.url});

  @override
  State<GroupViewProfile> createState() => _GroupViewProfileState();
}

class _GroupViewProfileState extends State<GroupViewProfile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //app bar
          appBar: AppBar(title: Text(widget.name), leading: IconButton(
            onPressed: () {Navigator.pop(context);},
            icon: const Icon(Ionicons.chevron_back_outline),
          ),),
          floatingActionButton: //user about
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Created At: ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
              Text(
                  MyDateUtil.getLastMessageTime(
                      context: context,
                      time: widget.join,
                      showYear: true),
                  style: const TextStyle(color: Colors.black54, fontSize: 15)),
            ],
          ),

          //body
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(width: mq.width, height: mq.height * .03),

                  //user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.url,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  // for adding some space
                  SizedBox(height: mq.height * .03),

                  // // user email label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Group: ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight:  FontWeight.w500,
                        fontSize: 15,
                      ),),

                      Text(widget.name,
                          style:
                          const TextStyle(color: Colors.black87, fontSize: 16)),
                    ],
                  ),
                  // for adding some space
                  SizedBox(height: mq.height * .02),

                  //user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Description: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      Text(widget.des,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
