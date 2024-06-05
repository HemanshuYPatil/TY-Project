import 'package:chatapp/Auth/auth.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/pages/GroupChat/grouplists.dart';
import 'package:chatapp/pages/Welcome/Homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:ionicons/ionicons.dart';
import '../../models/bottom.dart';
import '../../main.dart';

class GroupInfo extends StatefulWidget {
  final String groupname;
  final String groudId;
  final String adminname;

  const GroupInfo(
      {super.key,
      required this.adminname,
      required this.groudId,
      required this.groupname});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  @override
  void initState() {
    // TODO: implement initState
    getmembers();
    super.initState();
  }

  getmembers() {
    APIs.getGroupMembers(widget.groudId).then((value) {
      setState(() {
        members = value;
      });
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Info"),
        leading: IconButton(
          onPressed: () {Navigator.pop(context);},
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {


              _showPopupMenu(context);            },
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).primaryColor.withOpacity(0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.groupname.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Group: ${widget.groupname}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text("Admin: ${getName(widget.adminname)}")
                    ],
                  )
                ],
              ),
            ),
            memberList(),
          ],
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
        // const PopupMenuItem(
        //   value: '', // Use String literals
        //   child: Text('Edit'),
        // ),

        const PopupMenuItem(

          value: '1', // Use String literals
          child: Text('Leave',style: TextStyle(color: Colors.red),),
        ),

      ],
    );

    // Convert the selection to String
    String selectionString = selection?.toString() ?? '';

    if (selectionString == '1') {
      // ignore: use_build_context_synchronously
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Leave Group"),
              content: const Text("Are you sure you exit the group? "),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                MaterialButton(
                  onPressed: () {


                    APIs.leavegroup(widget.groudId, widget.groupname);
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>  const GroupListChat()));
                  },
                  child: const Text(
                    'Leave',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            );
          });
    }

  }

  bottomsheet(String userId, String username){
  
    showModalBottomSheet(
        context: context as BuildContext,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

          
                _OptionItem(
                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 26),
                    name: 'Remove Member',
                    onTap: () async {
                      if(APIs.me.name != widget.adminname){
                        APIs.removemember(widget.groudId, userId, widget.groupname, username).then((value) => {
                          Navigator.pop(context),
                          Dialogs.showSnackbar(context, '${username} Removed')
                        });
                      }
                      else{
                        print('Current User is not Admin');
                      }

                    }),

         
              //read time
            ],
          );
        });
  
  }

memberList() {
  return StreamBuilder(
    stream: members,
    builder: (context, AsyncSnapshot snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data['members'] != null) {
          if (snapshot.data['members'].length != 0) {
            return ListView.builder(
              itemCount: snapshot.data['members'].length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: ListTile(
                    onLongPress: () {
                      // Print user id and name when ListTile is tapped
                      print("User ID: ${getId(snapshot.data['members'][index])}");
                      print("User Name: ${getName(snapshot.data['members'][index])}");
                      if(FirebaseAuth.instance.currentUser!.displayName.toString() == getName(widget.adminname)){
                        bottomsheet(getId(snapshot.data['members'][index]),getName(snapshot.data['members'][index]));
                      }else{
                        Dialogs.showSnackbar(context, "Only Admin Can Remove The Member");
                      }
                    },
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        getName(snapshot.data['members'][index])
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(getName(snapshot.data['members'][index])),
                    subtitle: Text("Member"),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text("NO MEMBERS"),
            );
          }
        } else {
          return const Center(
            child: Text("NO MEMBERS"),
          );
        }
      } else {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        );
      }
    },
  );
}

}


class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
