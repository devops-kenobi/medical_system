import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../constants.dart';
import '../../../responsive.dart';

class BodyUserPendingApproval extends StatefulWidget {
  BodyUserPendingApproval({Key? key}) : super(key: key);

  @override
  _BodyUserPendingApprovalState createState() =>
      _BodyUserPendingApprovalState();
}

class _BodyUserPendingApprovalState extends State<BodyUserPendingApproval> {
  final _user = FirebaseAuth.instance.currentUser;
  String statusCurrentUser = '';
  final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .where('status', isEqualTo: 'pending_approval')
      .snapshots();
  final maskFormatter = MaskTextInputFormatter(
      mask: '###-###-####', filter: {"#": RegExp(r'[0-9]')});
  Map<String, String> mapStatus = {
    "super_admin": "ผู้ดูแลระบบ",
    "admin": "ผู้ช่วยดูแลระบบ",
    "user": "ผู้ใช้ทั่วไป",
    "pending_approval": "ผู้ใช้รอการอนุมัติ"
  };
  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        statusCurrentUser = documentSnapshot.get('status');
        // print(documentSnapshot.get('status'));
      }
    });
    return Container(
      height: sizePageHeight * 0.4,
      width: sizePageWidth,
      decoration: const BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: StreamBuilder(
        stream: _userStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong',
                style: TextStyle(color: Colors.red));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              strokeWidth: 2,
            ));
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const TitleUserPendingApproval(),
                SizedBox(
                  height: sizePageHeight * 0.35,
                  child: ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return SizedBox(
                        height: 50,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              String fullname =
                                  data['first_name'] + ' ' + data['last_name'];
                              if (_user!.uid != document.id &&
                                  statusCurrentUser == 'super_admin') {
                                showDialogUpdateStatusForSuperAdmin(
                                    fullname, data['status'], document.id);
                              } else if (_user!.uid != document.id &&
                                  statusCurrentUser == 'admin') {
                                showDialogUpdateStatusForAdmin(
                                    fullname, data['status'], document.id);
                              } else {
                                null;
                              }
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: !Responsive.isMobile(context)
                                      ? sizePageWidth * 0.05
                                      : sizePageWidth * 0.03,
                                  child: Center(
                                    child: Icon(Icons.person,
                                        color: data['status'] == 'super_admin'
                                            ? colorSuperAdmin
                                            : data['status'] == 'admin'
                                                ? colorAdmin
                                                : data['status'] == 'user'
                                                    ? colorUser
                                                    : colorTextP3),
                                  ),
                                ),
                                SizedBox(
                                    width: !Responsive.isMobile(context)
                                        ? sizePageWidth * 0.1
                                        : sizePageWidth * 0.13,
                                    child: Center(
                                        child: Text(
                                            mapStatus[data['status']]
                                                .toString(),
                                            maxLines: 1))),
                                SizedBox(
                                    width: !Responsive.isMobile(context)
                                        ? sizePageWidth * 0.2
                                        : sizePageWidth * 0.23,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(data['first_name'], maxLines: 1),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(data['last_name'], maxLines: 1),
                                      ],
                                    )),
                                SizedBox(
                                    width: !Responsive.isMobile(context)
                                        ? sizePageWidth * 0.2
                                        : sizePageWidth * 0.23,
                                    child: Center(
                                      child: Text(
                                        data['email'],
                                        maxLines: 1,
                                      ),
                                    )),
                                SizedBox(
                                    width: !Responsive.isMobile(context)
                                        ? sizePageWidth * 0.2
                                        : sizePageWidth * 0.23,
                                    child: Center(
                                        child: Text(
                                            maskFormatter.maskText(data['tel']),
                                            maxLines: 1))),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> showDialogUpdateStatusForSuperAdmin(
      String name, String status, String userID) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    String currentStatus = status;
    Future<void> updateUser(String status, String userID) {
      return users
          .doc(userID)
          .update({'status': status})
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            backgroundColor: secondaryColor,
            title: const Center(
              child: Text('เปลี่ยนสถานะผู้ใช้',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
            content: SingleChildScrollView(
                child: ListBody(children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person,
                          color: status == 'super_admin'
                              ? colorSuperAdmin
                              : status == 'admin'
                                  ? colorAdmin
                                  : status == 'user'
                                      ? colorUser
                                      : colorTextP3),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(name, style: const TextStyle(color: colorTextP2)),
                    ],
                  ),
                  SizedBox(
                      width: 200,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: currentStatus == 'super_admin'
                              ? Colors.amber
                              : colorTextP2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                currentStatus = 'super_admin';
                              });
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: colorSuperAdmin,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('ผู้ดูแลระบบ')
                              ],
                            ),
                          ),
                        ),
                      )),
                  SizedBox(
                      width: 200,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: currentStatus == 'admin'
                              ? Colors.amber
                              : colorTextP2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                currentStatus = 'admin';
                              });
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: colorAdmin,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('ผู้ช่วยดูแลระบบ')
                              ],
                            ),
                          ),
                        ),
                      )),
                  SizedBox(
                      width: 200,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: currentStatus == 'user'
                              ? Colors.amber
                              : colorTextP2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                currentStatus = 'user';
                              });
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: colorUser,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('ผู้ใช้ทั่วไป')
                              ],
                            ),
                          ),
                        ),
                      )),
                  SizedBox(
                      width: 200,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: currentStatus == 'pending_approval'
                              ? Colors.amber
                              : colorTextP2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                currentStatus = 'pending_approval';
                              });
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: colorTextP3,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('ผู้ใช้รอการอนุมัติ')
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
            ])),
            actions: [
              TextButton(
                child: const Text('ยกเลิก'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('ตกลง'),
                onPressed: () {
                  updateUser(currentStatus, userID);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> showDialogUpdateStatusForAdmin(
      String name, String status, String userID) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    String currentStatus = status;
    Future<void> updateUser(String status, String userID) {
      return users
          .doc(userID)
          .update({'status': status})
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            backgroundColor: secondaryColor,
            title: const Center(
              child: Text('เปลี่ยนสถานะผู้ใช้',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
            content: SingleChildScrollView(
                child: ListBody(children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person,
                          color: status == 'super_admin'
                              ? colorSuperAdmin
                              : status == 'admin'
                                  ? colorAdmin
                                  : status == 'user'
                                      ? colorUser
                                      : colorTextP3),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(name, style: const TextStyle(color: colorTextP2)),
                    ],
                  ),
                  SizedBox(
                      width: 200,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: currentStatus == 'user'
                              ? Colors.amber
                              : colorTextP2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                currentStatus = 'user';
                              });
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: colorUser,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('User')
                              ],
                            ),
                          ),
                        ),
                      )),
                  SizedBox(
                      width: 200,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: currentStatus == 'pending_approval'
                              ? Colors.amber
                              : colorTextP2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                currentStatus = 'pending_approval';
                              });
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.person,
                                  color: colorTextP3,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Pending Approval')
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
            ])),
            actions: [
              TextButton(
                child: const Text('ยกเลิก'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('ตกลง'),
                onPressed: () {
                  updateUser(currentStatus, userID);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
}

class TitleUserPendingApproval extends StatelessWidget {
  const TitleUserPendingApproval({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: sizePageWidth,
        height: 30,
        child: const Card(
          color: colorTextP3,
          child: Center(
              child: Text(
            'ผู้ใช้ที่รอการอนุมัติ หรือถูกบล็อก (ไม่สามารถใช้งานระบบได้)',
            style: TextStyle(color: colorTextP2),
          )),
        ));
  }
}
