import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';

class Grouppage extends StatelessWidget {
  const Grouppage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Groups')),
      body: FutureBuilder(
        
        future: fetchAllGroups(),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No groups found.'));
          } else {
            return ListView.builder(
              
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var groupData = snapshot.data![index].data() as Map<String, dynamic>;

                return GroupCard(
                  groupName: groupData['groupName'],
                  imageUrl: groupData['image'],
                  onTap: () {
                    
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> fetchAllGroups() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    var groupId = currentUser?.uid;

    try {
    
      QuerySnapshot<Object?> querySnapshot = await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .collection('MyGroups')
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching all groups: $e');
      return [];
    }
  }
}

class GroupCard extends StatelessWidget {
  final String groupName;
  final String imageUrl;
  final VoidCallback onTap;

  const GroupCard({
    required this.groupName,
    required this.imageUrl,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.03),
            child: CachedNetworkImage(
              width: mq.height * 0.055,
              height: mq.height * 0.055,
              imageUrl: imageUrl,
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
          title: Text(groupName),
        ),
      ),
    );
  }
}
