import 'package:flutter/material.dart';

class BotInfo extends StatefulWidget {
  const BotInfo({super.key});

  @override
  State<BotInfo> createState() => _BotInfoState();
}

class _BotInfoState extends State<BotInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bot Info"),centerTitle: true,),

    );
  }
}
