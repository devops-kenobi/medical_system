import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'responsive.dart';

class ReserPassword extends StatefulWidget {
  const ReserPassword({Key? key}) : super(key: key);

  @override
  State<ReserPassword> createState() => _ReserPasswordState();
}

class _ReserPasswordState extends State<ReserPassword> {
  final TextEditingController _email = TextEditingController();

  final _auth = FirebaseAuth.instance;
  bool waitRes = false;
  String statusReset = '';

  @override
  Widget build(BuildContext context) {
    final responsiveMobile = Responsive.isMobile(context);
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: colorPriority3,
      appBar: AppBar(
        backgroundColor: colorDarkTheme,
        title: const Text("Reset Password"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(
                "The system will send information to your email to change your password.",
                style: TextStyle(
                  fontSize: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.015
                      : sizePageWidth * 0.025,
                )),
            Text("ระบบจะส่งข้อมูลไปยังอีเมลของท่านเพื่อทำการเปลี่ยนรหัสผ่าน",
                style: TextStyle(
                  fontSize: !Responsive.isMobile(context)
                      ? sizePageWidth * 0.015
                      : sizePageWidth * 0.025,
                )),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width:
                  !responsiveMobile ? sizePageWidth / 2.5 : sizePageWidth * 0.8,
              height: 45,
              child: TextField(
                controller: _email,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.0)),
                  fillColor: Colors.white,
                  filled: true,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 40,
              width: sizePageWidth * 0.2,
              child: Card(
                color: colorBlue,
                child: InkWell(
                  child: waitRes == false
                      ? const Center(
                          child: Text(
                          "Send",
                          style: TextStyle(color: Colors.white),
                        ))
                      : const SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              // strokeWidth: 2,
                            ),
                          ),
                        ),
                  onTap: () async {
                    try {
                      setState(() {
                        waitRes = true;
                      });

                      await _auth
                          .sendPasswordResetEmail(email: _email.text)
                          .then((value) {
                        Navigator.pop(context);
                        // ignore: avoid_print
                        print("OK");
                      });
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        waitRes = false;
                      });
                      // ignore: avoid_print
                      print(e.message);
                      // ignore: avoid_print
                      print(e.code);
                      if (e.code == "user-not-found") {
                        setState(() {
                          statusReset =
                              "ไม่พบที่อยู่อีเมลของท่านในระบบ Your email address was not found in the system.";
                        });
                      }
                      if (e.code == "invalid-email") {
                        setState(() {
                          statusReset =
                              "รูปแบบอีเมลไม่ถูกต้อง The email address is badly formatted.";
                        });
                      }
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 30,
              child: Text(
                statusReset,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
