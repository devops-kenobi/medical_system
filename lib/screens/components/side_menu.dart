import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_temperature_humidity_system/constants.dart';
import 'package:flutter_temperature_humidity_system/screens/components/provider.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    double sizePageHeight = MediaQuery.of(context).size.height;
    var provider = Provider.of<ProviderStatus>(context);
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("images/logo.png"),
          ),
          DrawerListTile(
            titleColor: provider.getPage() == 1 ? bgColor : secondaryColor,
            title: "หน้าหลัก",
            svgSrc: "icon/home.svg",
            press: () {
              provider.setPage(1);
            },
          ),
          DrawerListTile(
            titleColor: provider.getPage() == 2 ? bgColor : secondaryColor,
            title: "ข้อมูลที่เก็บยา",
            svgSrc: "icon/setting.svg",
            press: () {
              provider.setPage(2);
            },
          ),
          DrawerListTile(
            titleColor: provider.getPage() == 3 ? bgColor : secondaryColor,
            title: "ข้อมูลผู้ใช้",
            svgSrc: "icon/user.svg",
            press: () {
              provider.setPage(3);
            },
          ),
          SizedBox(
            height: sizePageHeight * 0.5,
          ),
          ListTile(
            tileColor: secondaryColor,
            onTap: () async {
              try {
                await _auth.signOut().then((value) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return MyApp();
                  }));
                });
              } catch (e) {
                // ignore: avoid_print
                print(e);
              }
            },
            horizontalTitleGap: 0.0,
            leading: SvgPicture.asset(
              "icon/logout.svg",
              color: Colors.white54,
              height: 20,
            ),
            title: const Text(
              "ออกจากระบบ",
              style: TextStyle(color: Colors.white54),
            ),
          )
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.titleColor,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title;
  final String svgSrc;
  final VoidCallback press;
  // ignore: prefer_typing_uninitialized_variables
  final titleColor;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: titleColor,
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        color: colorPriority1,
        height: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
