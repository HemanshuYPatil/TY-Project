import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../Auth/auth.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../Calls/call.dart';
import '../GroupChat/grouplists.dart';

class NewBot extends StatefulWidget {
  const NewBot({super.key});

  @override
  State<NewBot> createState() => _NewBotState();
}

class _NewBotState extends State<NewBot> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController groupname = TextEditingController();
  final TextEditingController groupdes = TextEditingController();
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;
  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
    'Item5',
    'Item6',
    'Item7',
    'Item8',
  ];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create New Group"),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                child: Column(
                  children: [
                    SizedBox(width: mq.width, height: mq.height * .07),
                    Center(
                      child: InkWell(
                        onTap: () {},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.03),
                          child: Container(
                            width: 100, // Adjust width as needed
                            height: 100, // Adjust height as needed
                            child: CircleAvatar(
                              child: Container(
                                  width: 160,
                                  height: 160,
                                  child: Icon(Boxicons.bx_bot,size: 60,)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: mq.height * .10),
                    TextFormField(
                      controller: groupname,
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.people, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Bot Name',
                        label: const Text('Bot Name'),
                      ),
                    ),
                    const SizedBox(height: 35),




                    SizedBox(height: mq.height * .10),
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

                                  try {
                                    await APIs.createGroup(
                                        user.displayName.toString(),
                                        user.uid.toString(),
                                        name,
                                        des);
                                    Dialogs.showSnackbar(
                                        context, 'Group Created');
                                    groupname.clear();
                                    groupdes.clear();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GroupListChat(),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
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
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(100.0),
                              //   color: Colors.blue,
                              // ),
                              child: isLoading
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width:
                                              24, // Adjust the width as needed
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
                                          'Creating Bot...',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
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
                            // if (isLoading)
                            // Positioned.fill(
                            //   child: CircularProgressIndicator(
                            //     strokeWidth: 2,
                            //     valueColor:
                            //     AlwaysStoppedAnimation<Color>(Colors.white),
                            //   ),
                            // ),
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
      ),
    );
  }
}
