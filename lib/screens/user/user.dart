import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/screens/components/provider.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import 'components/body_user.dart';
import 'components/body_user_pa.dart';
import 'components/body_user_sa.dart';
import 'components/header.dart';

class UserPage extends StatelessWidget {
  UserPage({Key? key}) : super(key: key);
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
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
            return const Center(child: CircularProgressIndicator());
          }
          // return Text("data");

          return snapshot.data!.get('status') == "super_admin" ||
                  snapshot.data!.get('status') == "admin"
              ? SafeArea(
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          HeaderUser("admin"),
                          const Spacer(),
                          Dropdown(),
                        ],
                      ),
                      if (provider.getPageUser() == 1) BodyUser(),
                      if (provider.getPageUser() == 2) BodyUserForSuperAdmin(),
                      const SizedBox(
                        height: 3,
                      ),
                      if (provider.getPageUser() == 2) BodyUserPendingApproval()
                    ],
                  ),
                ))
              : SafeArea(
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      HeaderUser("User"),
                      const SizedBox(
                        height: defaultPadding,
                      ),
                      BodyUser(),
                    ],
                  ),
                ));
        });
  }
}

class Dropdown extends StatefulWidget {
  Dropdown({Key? key}) : super(key: key);

  @override
  _DropdownState createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  Map<String, String> choice = {
    'A': 'ข้อมูลส่วนตัว',
    'B': 'ข้อมูลผู้ใช้ทั้งหมด'
  };
  Map<String, int> page = {'A': 1, 'B': 2};
  String _selectedLocation = 'A';
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProviderStatus>(context);
    return SizedBox(
      height: 45,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        color: colorTextP2,
        child: DropdownButton<String>(
          dropdownColor: colorTextP2,
          underline: const SizedBox(),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          hint: provider.getPageUser() == 1
              ? const Text(" ข้อมูลส่วนตัว",
                  style: TextStyle(color: colorTextP1))
              : const Text(" ข้อมูลผู้ใช้ทั้งหมด",
                  style: TextStyle(color: colorTextP1)),
          items: <String>['A', 'B'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(choice[value].toString(),
                  style: const TextStyle(color: colorTextP1)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLocation = value!;
            });
            provider.setPageUser(page[_selectedLocation]);
          },
        ),
      ),
    );
  }
}
