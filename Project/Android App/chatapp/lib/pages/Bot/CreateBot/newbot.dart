import 'dart:math';

import 'package:chatapp/Auth/bot.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import '../../../Auth/auth.dart';
import '../../../helper/dialogs.dart';
import '../../../main.dart';
import '../../Calls/call.dart';

class CreateNewBot extends StatefulWidget {
  const CreateNewBot({Key? key}) : super(key: key);

  @override
  State<CreateNewBot> createState() => _CreateNewBotState();
}

class _CreateNewBotState extends State<CreateNewBot> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController groupname = TextEditingController();
  final TextEditingController groupdes = TextEditingController();

  bool isLoading = false;

  List<dynamic> productTypesList = [];

  String model = "";

  final List<String> items = [
    'Restaurant',
    'Sweet Shop',
    'General Store'
  ];
  final List<String> item = [
    'Public',
    'Private'
  ];
  String? selectedValue;
  String? BotPrivacy;
  @override
  void initState() {
    super.initState();
    productTypesList.add({"id": 1, "label": "Simple"});
    productTypesList.add({"id": 2, "label": "Variable"});
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Bot"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {Navigator.pop(context);},
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.size.width * .05),
              child: Column(

                children: [
                  SizedBox(height: mq.size.height * .10),
                  Center(
                    child: InkWell(
                      onTap: () {},
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(mq.size.height * 0.03),
                        child: Container(
                          width: 100, // Adjust width as needed
                          height: 100, // Adjust height as needed
                          child: CircleAvatar(
                            child: Container(
                                width: 160,
                                height: 160,
                                child: Icon(
                                  Boxicons.bx_bot,
                                  size: 60,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: mq.size.height * .10),
                  TextFormField(
                    controller: groupname,
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Bot Name',
                      labelText: 'Bot Name',
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: groupdes,
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.people, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Description or Address',
                      labelText: 'Description or Address',
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: 700,
                    height: 60,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            Icon(
                              Icons.list,
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                'Select Bot Type',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                                // overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items: items
                            .map((String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        value: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          width: 160,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white,
                          ),
                          elevation: 2,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                          iconSize: 14,
                          iconEnabledColor: Colors.blue,
                          iconDisabledColor: Colors.blue,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 500,

                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                          ),
                          offset: const Offset(-20, 0),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: MaterialStateProperty.all(6),
                            thumbVisibility: MaterialStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  SizedBox(height: mq.size.height * .10),
                  SizedBox(
                    height: 45,
                    width: 180,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                _formKey.currentState!.save();
                                String name = groupname.text.trim();
                                String des = groupdes.text.trim();

                                if(BotPrivacy == "Public"){
                                  try {
                                    BotBackend.createnewbot(name, des, selectedValue!, BotPrivacy!);
                                    Dialogs.showSnackbar(
                                        context, 'Bot Created Created');
                                    groupname.clear();
                                    groupdes.clear();
                                    setState(() {

                                      isLoading = false;
                                    });
                                  } finally {

                                  }
                                }
                                else{
                                  try {
                                    BotBackend.createprivatebot(name, des, selectedValue!, BotPrivacy!,generateRandomCode());
                                    Dialogs.showSnackbar(
                                        context, 'Bot Created Created');
                                    groupname.clear();
                                    groupdes.clear();
                                    setState(() {

                                      isLoading = false;
                                    });
                                  } finally {

                                  }
                                }


                              }
                            },
                      style: TextButton.styleFrom(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            child: isLoading
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24, // Adjust the width as needed
                                        height:
                                            24, // Adjust the height as needed
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Creating Group...',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      )
                                    ],
                                  )
                                : const Text(
                                    "Create",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Sofia",
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  String generateRandomCode() {
    final random = Random();
    return '${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}${random.nextInt(10)}  '.toString();
  }
}
