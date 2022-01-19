import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/screens/home/home.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../main.dart';
import 'components/provider.dart';
import 'main_screen.dart';
import 'new_user.dart';

class EmailVerification extends StatefulWidget {
  EmailVerification({Key? key}) : super(key: key);

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final _auth = FirebaseAuth.instance;

  final _user = FirebaseAuth.instance.currentUser;

  void sendEmail() {
    _user!.sendEmailVerification();
  }

  @override
  void initState() {
    super.initState();
    if (_user!.emailVerified == false) {
      sendEmail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user!.emailVerified == false
          ? WaitVerification()
          : UserVerification(),
    );
  }
}

class WaitVerification extends StatelessWidget {
  WaitVerification({Key? key}) : super(key: key);
  final _user = FirebaseAuth.instance.currentUser;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "สำเร็จ",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
              "กรุณาทำการยืนยันที่อยู่อีเมล Please verify your email address."),
          Text("Email ${_user!.email} "),
          // const SizedBox(
          //   height: 20,
          // ),
          // ElevatedButton(
          //     onPressed: () async {
          //       try {
          //         await _auth.signOut().then((value) {
          //           Navigator.pushReplacement(context,
          //               MaterialPageRoute(builder: (context) {
          //             return MyApp();
          //           }));
          //         });
          //       } catch (e) {
          //         print(e);
          //       }
          //     },
          //     child: const Text("ยืนยันอีเมลแล้ว")),
        ],
      ),
    );
  }
}

//User Verification ===================================================================================

class UserVerification extends StatelessWidget {
  UserVerification({Key? key}) : super(key: key);
  final _auth = FirebaseAuth.instance;
  final _user = FirebaseAuth.instance.currentUser;

  Future<bool> checkUser(String uid) async {
    late bool user;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (documentSnapshot.exists) {
        user = true;
      } else {
        user = false;
      }
    });
    print(user);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProviderStatus())
      ],
      child: Scaffold(
          body: FutureBuilder(
        future: checkUser(_user!.uid),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              strokeWidth: 2,
            ));
          }
          return snapshot.data == true ? MainScreen() : const CreateNewUser();
        },
      )),
    );
  }
}
