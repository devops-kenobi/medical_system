import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/constants.dart';
import 'package:flutter_temperature_humidity_system/screens/setting/components/create_sensor.dart';
import 'package:flutter_temperature_humidity_system/screens/setting/components/sensor.dart';
import 'package:flutter_temperature_humidity_system/screens/setting/components/header.dart';

import 'components/cabinet.dart';
import 'components/create_cabinet.dart';

class SettingPage extends StatelessWidget {
  SettingPage({Key? key}) : super(key: key);
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> checkUser = FirebaseFirestore
        .instance
        .collection('users')
        .doc(_user!.uid)
        .snapshots();

    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;

    return StreamBuilder(
        stream: checkUser,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong',
                style: TextStyle(color: Colors.red));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.data!.get('status') == "admin" ||
                  snapshot.data!.get('status') == "super_admin"
              ? SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      children: [
                        const HeaderSetting(),
                        const SizedBox(
                          height: defaultPadding,
                        ),
                        CreateSensor(),
                        ScncerData(), //⬅ข้อมูลเซนเซอร์
                        const SizedBox(
                          height: defaultPadding,
                        ),
                        CreateCabinet(), //⬅text ที่เก็บยา / ปุ่ม + ที่เก็บยา
                        Cabinet(), //⬅ข้อมูลที่เก็บยา
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.admin_panel_settings,
                      color: colorTextP1,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'เฉพาะผู้ดูแลระบบเท่านั้น',
                      style: TextStyle(color: colorTextP1),
                    ),
                  ],
                ));
        });
  }
}
