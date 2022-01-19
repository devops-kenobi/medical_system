import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../constants.dart';
import '../../../responsive.dart';

class BodyUser extends StatefulWidget {
  @override
  State<BodyUser> createState() => _BodyUserState();
}

CollectionReference users = FirebaseFirestore.instance.collection('users');
final _user = FirebaseAuth.instance.currentUser;

class _BodyUserState extends State<BodyUser> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _tel = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;
  final maskFormatter = MaskTextInputFormatter(
      mask: '+66 : ###-#######', filter: {"#": RegExp(r'[0-9]')});
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> _usersStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .snapshots();

    Map<String, String> mapStatus = {
      "super_admin": "ผู้ดูแลระบบ",
      "admin": "ผู้ช่วยดูแลระบบ",
      "user": "ผู้ใช้ทั่วไป",
      "pending_approval": "ผู้ใช้รอการอนุมัติ"
    };
    Future<void> updateUser(String firstName, String lastName, String tel) {
      return users.doc(_user!.uid).update({
        'first_name': firstName,
        'last_name': lastName,
        'tel': tel
      }).then((value) {
        Fluttertoast.showToast(
            msg: "สำเร็จ",
            fontSize: 40,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            textColor: colorTextP2);
      }).catchError((error) {
        print(error);
      });
    }

    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    return Container(
      height: sizePageHeight * 0.7,
      width: sizePageWidth,
      decoration: const BoxDecoration(
          color: colorPriority3,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: StreamBuilder(
        stream: _usersStream,
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Text(
              'Something went wrong',
              style: TextStyle(color: Colors.red),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              strokeWidth: 2,
            ));
          }
          _firstName.text = snapshot.data!.get('first_name');
          _lastName.text = snapshot.data!.get('last_name');
          // _tel.text = snapshot.data!.get('tel');
          _tel.text = maskFormatter.maskText(snapshot.data!.get('tel'));
          _email.text = snapshot.data!.get('email');
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Icon(
                  Icons.person,
                  color: snapshot.data!.get('status') == 'super_admin'
                      ? colorSuperAdmin
                      : snapshot.data!.get('status') == 'admin'
                          ? colorAdmin
                          : snapshot.data!.get('status') == 'user'
                              ? colorUser
                              : colorTextP3,
                  size: 60,
                ),
                Text(
                  "สถานะ ${mapStatus[snapshot.data!.get('status')].toString()}",
                  style: const TextStyle(color: colorTextP1),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.4
                      : sizePageWidth * 0.8,
                  child: TextField(
                    controller: _firstName,
                    decoration: InputDecoration(
                      prefixText: "ชื่อ ",
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.4
                      : sizePageWidth * 0.8,
                  child: TextField(
                    controller: _lastName,
                    decoration: InputDecoration(
                      prefixText: "นามสกุล ",
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.0)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.4
                      : sizePageWidth * 0.8,
                  child: TextField(
                      inputFormatters: [maskFormatter],
                      keyboardType: TextInputType.phone,
                      controller: _tel,
                      decoration: const InputDecoration(
                        prefixText: "เบอร์โทร ",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        fillColor: Colors.white,
                        filled: true,
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.4
                      : sizePageWidth * 0.8,
                  child: TextField(
                      enabled: false,
                      keyboardType: TextInputType.phone,
                      controller: _email,
                      style: const TextStyle(color: colorTextP3),
                      decoration: const InputDecoration(
                        prefixText: "email ",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        fillColor: Colors.white,
                        filled: true,
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 40,
                  width: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.2
                      : sizePageWidth * 0.4,
                  child: Card(
                      color: colorBlue,
                      child: InkWell(
                        child: const Center(
                          child: Text(
                            "บันทึกการแก้ไข",
                            style: TextStyle(color: colorTextP2),
                          ),
                        ),
                        onTap: () async {
                          if (_firstName.text.isNotEmpty &&
                              _lastName.text.isNotEmpty &&
                              maskFormatter.unmaskText(_tel.text).length ==
                                  10) {
                            await updateUser(_firstName.text, _lastName.text,
                                maskFormatter.unmaskText(_tel.text));
                          }
                        },
                      )),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Future<void> showDialogProcess() {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: true, // user must tap button!
  //     builder: (BuildContext context) {
  //       return const AlertDialog(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(10.0))),
  //         backgroundColor: secondaryColor,
  //         title: Center(
  //           child: Text("กำลังบันทึก",
  //               style: TextStyle(
  //                 color: colorTextP1,
  //               )),
  //         ),
  //         content: SizedBox(
  //             height: 100,
  //             width: 200,
  //             child: Center(child: CircularProgressIndicator())),
  //       );
  //     },
  //   );
  // }
}
