import 'package:chatapp/Auth/bot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../Auth/auth.dart';

class BotSearch extends StatefulWidget {
  const BotSearch({super.key});

  @override
  State<BotSearch> createState() => _BotSearchState();
}

class _BotSearchState extends State<BotSearch> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;

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
        elevation: 0,
        title: const Text(
          "Search Bot",
        ),
        leading: IconButton(
          onPressed: () {Navigator.pop(context);},
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white, // Background color of the container
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ), // Border radius for the container
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2), // Box shadow color
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Offset for the box shadow
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Bot Name....",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {initiateSearchMethod();},
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          20), // Half of the width for a circular shape
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
          //
          isLoading
              ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          )
              : groupList(),
        ],
      ),
    );
  }
  joinedOrNot(String userName, String groupId, String groupname, String admin) async {
    await BotBackend.IsBotAdd(groupname, groupId, userName).then((value) {
      if (mounted) {
        setState(() {
          isJoined = value;
        });
      }
    });
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await BotBackend.searchByBotName(searchController.text).then((snapshot) {
        if (mounted) {
          print("Name Found");
          setState(() {
            searchSnapshot = snapshot;
            isLoading = false;
            hasUserSearched = true;
          });
        }else{
          print("Name Not Found");

        }
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                userName,
                searchSnapshot!.docs[index]['BotId'],
                searchSnapshot!.docs[index]['BotName'],
                searchSnapshot!.docs[index]['Type'],
              );
            },
          )
        : Container(child: const Text('Bot Not Found'),);
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    // function to check whether user already exists in group
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await BotBackend.togglebotjoin(groupId, userName, groupName);

          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
              print(!isJoined);
            });

          } else {
            setState(() {
              isJoined = !isJoined;
              // print(!isJoined);

            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Added",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Add", style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}
