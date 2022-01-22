import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/constants.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../responsive.dart';
import 'validate.dart';

class CreateNewUser extends StatefulWidget {
  const CreateNewUser({Key? key}) : super(key: key);

  @override
  _CreateNewUserState createState() => _CreateNewUserState();
}

class _CreateNewUserState extends State<CreateNewUser> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _tel = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;
  final maskFormatter = MaskTextInputFormatter(
      mask: '+66 : ###-#######', filter: {"#": RegExp(r'[0-9]')});

  bool waitRes = false;
  String status = '';

  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Row(children: [
          if (!Responsive.isMobile(context))
            Container(
              height: double.infinity,
              width: sizePageWidth * 0.4,
              decoration: const BoxDecoration(
                color: Colors.grey,
                image: DecorationImage(
                  image: AssetImage("assets/images/bg2.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Container(
            height: double.infinity,
            width: !Responsive.isMobile(context)
                ? sizePageWidth * 0.6
                : sizePageWidth,
            decoration: const BoxDecoration(color: Color(0XFF8FB9BF)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Center(
                    child: Text("welcome new user",
                        style: TextStyle(
                            fontSize: !Responsive.isMobile(context)
                                ? sizePageWidth * 0.04
                                : sizePageWidth * 0.07,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  child: Center(
                    child: Text("ยินดีต้อนรับผู้ใช้ใหม่",
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: !Responsive.isMobile(context)
                                ? sizePageWidth * 0.02
                                : sizePageWidth * 0.05,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.5
                      : sizePageWidth * 0.7,
                  child: TextField(
                    controller: _firstName,
                    decoration: InputDecoration(
                      hintText: "ชื่อ first name",
                      prefixIcon: const Icon(Icons.person_outlined),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.5
                      : sizePageWidth * 0.7,
                  child: TextField(
                    controller: _lastName,
                    decoration: InputDecoration(
                      hintText: "นามสกุล last name",
                      prefixIcon: const Icon(Icons.person_outlined),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.5
                      : sizePageWidth * 0.7,
                  child: TextField(
                      inputFormatters: [maskFormatter],
                      keyboardType: TextInputType.phone,
                      controller: _tel,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        hintText: "เบอร์โทร phone number",
                        fillColor: Colors.white,
                        filled: true,
                      )),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 50,
                  width: sizePageWidth * 0.2,
                  child: Card(
                    color: colorBlue,
                    child: InkWell(
                      child: Center(
                        child: waitRes == false
                            ? const Text(
                                "ตกลง",
                                style: TextStyle(color: Colors.white),
                              )
                            : const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                      ),
                      onTap: () async {
                        if (_firstName.text.isNotEmpty &&
                            _lastName.text.isNotEmpty &&
                            maskFormatter.getUnmaskedText().length == 10) {
                          setState(() {
                            waitRes = true;
                          });

                          CollectionReference users =
                              FirebaseFirestore.instance.collection('users');
                          await users.doc(_user!.uid).set({
                            "first_name": _firstName.text,
                            "last_name": _lastName.text,
                            "status": "pending_approval",
                            "tel": maskFormatter.getUnmaskedText(),
                            "email": _user!.email
                          }).then((value) {
                            setState(() {
                              waitRes = false;
                            });
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return EmailVerification();
                            }));
                          });
                        } else {
                          setState(() {
                            status =
                                "กรุณากรอกข้อมูลให้ถูกต้อง Please fill out the correct information.";
                          });
                        }
                      },
                    ),
                  ),
                ),
                Text(
                  status,
                  style: const TextStyle(color: Colors.red),
                )
              ],
            ),
          )
        ]));
  }
}
