import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/constants.dart';
import 'package:flutter_temperature_humidity_system/screens/setting/setting.dart';
import 'package:flutter_temperature_humidity_system/screens/user/user.dart';
import 'package:provider/provider.dart';

import '../responsive.dart';
import 'components/provider.dart';
import 'components/side_menu.dart';
import 'home/home.dart';

class MainScreen extends StatelessWidget {
  final _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    var provider = Provider.of<ProviderStatus>(context);
    Stream<DocumentSnapshot<Map<String, dynamic>>> checkUser = FirebaseFirestore
        .instance
        .collection('users')
        .doc(_user!.uid)
        .snapshots();
    return StreamBuilder(
        stream: checkUser,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
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
          return snapshot.data!.get('status') == "super_admin" ||
                  snapshot.data!.get('status') == "admin" ||
                  snapshot.data!.get('status') == "user"
              ? Scaffold(
                  drawer: const SideMenu(),
                  body: Container(
                    color: bgColor,
                    child: SafeArea(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // We want this side menu only for large screen
                          if (Responsive.isDesktop(context))
                            const Expanded(
                              // default flex = 1
                              // and it takes 1/6 part of the screen
                              child: SideMenu(),
                            ),
                          Expanded(
                            // It takes 5/6 part of the screen
                            flex: 5,
                            child: provider.getPage() == 1
                                ? HomePage()
                                : provider.getPage() == 2
                                    ? SettingPage()
                                    : UserPage(),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Scaffold(
                  body: SafeArea(
                    child: SizedBox(
                      width: sizePageWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.admin_panel_settings,
                            color: colorTextP1,
                            size: 35,
                          ),
                          const SizedBox(
                            height: 13,
                          ),
                          Text(
                            "อีเมล ${_user!.email} อยู่ระหว่างรอการอนุมัติจากผู้ดูแลระบบ",
                            style: const TextStyle(color: colorTextP1),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        });
  }
}
