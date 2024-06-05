// ignore: file_names
class Group {

  Group({
    required this.groupId,
    required this.groupName,
    required this.createdAt,
    required this.groupAdmin,
    required this.members,
    required this.image,
    required this.description,
    required this.recentmessage,
    required this.recentmessageSender
  });

  final String groupId;
  final String description;
  final String groupName;
  final DateTime createdAt;
  final String groupAdmin;
  final List<String> members;
  final String image;
  final String recentmessage;
  final String recentmessageSender;


  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['groupId'] ?? '',
      groupName: json['groupName'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      groupAdmin: json['groupAdmin'] ?? '',
      members: (json['members'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      recentmessage: json['recentmessage'] ?? '',
      recentmessageSender: json['recentmessageSender'] ?? '',

    );
  }


  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'createdAt': createdAt.toIso8601String(),
      'groupAdmin': groupAdmin,
      'image': image,
      'members': members,
      'description': description,
      'recentmessage': recentmessage,
      'recentmessageSender': recentmessageSender,

    };
  }
}
