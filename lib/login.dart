import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/responsive.dart';

import 'constants.dart';
import 'reset.dart';

import 'screens/validate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = FirebaseAuth.instance.currentUser;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _emailAuth = TextEditingController();
  final TextEditingController _passwordAuth = TextEditingController();
  late bool _passwordVisible;
  late bool _authentication;
  String statusAuth = '';
  String statusLogin = '';
  bool waitRes = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _authentication = false;
    // Firebase.initializeApp().then((value) async {
    //   await FirebaseAuth.instance.authStateChanges().listen((event) async {
    //     if (event != null) {
    //       await Navigator.pushReplacement(context,
    //           MaterialPageRoute(builder: (context) {
    //         return EmailVerification();
    //       }));
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;

    return Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: sizePageHeight / 15,
              ),
              Text(
                "Temperature and Humidity Alert System",
                style: TextStyle(
                    fontSize: !Responsive.isMobile(context)
                        ? sizePageWidth * 0.04
                        : 26,
                    color: Colors.white),
              ),
              const SizedBox(
                height: 15,
              ),
              Text("for medication storages with internet of things",
                  style: TextStyle(
                      fontSize: !Responsive.isMobile(context)
                          ? sizePageWidth * 0.025
                          : 22,
                      color: Colors.white)),
              const SizedBox(
                height: 20,
              ),
              Text("ระบบแจ้งเตือนอุณหภูมิและความชื้น",
                  style: TextStyle(
                      fontSize: !Responsive.isMobile(context)
                          ? sizePageWidth * 0.02
                          : 25,
                      color: Colors.white)),
              Text("เพื่อการเก็บรักษายาด้วยอินเทอร์เน็ตของสรรพสิ่ง",
                  style: TextStyle(
                      fontSize: !Responsive.isMobile(context)
                          ? sizePageWidth * 0.02
                          : 25,
                      color: Colors.white)),
              const SizedBox(
                height: 25,
              ),
              //Login ================================================================================
              _authentication == false
                  ? Container(
                      height: 360,
                      width: !Responsive.isMobile(context)
                          ? sizePageWidth * 0.7
                          : sizePageWidth * 0.95,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Image.asset(
                              "images/user.png",
                              height: 120,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: !Responsive.isMobile(context)
                                ? sizePageWidth * 0.5
                                : sizePageWidth * 0.9,
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
                            height: 10,
                          ),
                          SizedBox(
                            width: !Responsive.isMobile(context)
                                ? sizePageWidth * 0.5
                                : sizePageWidth * 0.9,
                            height: 45,
                            child: TextField(
                              obscureText: !_passwordVisible,
                              controller: _password,
                              decoration: InputDecoration(
                                hintText: "Password",
                                prefixIcon: const Icon(Icons.vpn_key),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8.0)),
                                fillColor: Colors.white,
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: colorPriority2,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                            child: Text(
                              statusLogin,
                              style: const TextStyle(color: colorButtonRed),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            width: 200,
                            child: Card(
                              color: colorBlue,
                              child: InkWell(
                                child: waitRes == false
                                    ? const Center(
                                        child: Text(
                                        "Login",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                    : const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
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
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                            email: _email.text,
                                            password: _password.text
                                            // email: "6114631020@rbru.ac.th",
                                            // password: "2222222222"
                                            )
                                        .then((value) {
                                      setState(() {
                                        waitRes = false;
                                      });
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return EmailVerification();
                                      }));
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    setState(() {
                                      waitRes = false;
                                    });
                                    // print(e.message);
                                    // print(e.code);
                                    if (e.code == "invalid-email") {
                                      setState(() {
                                        statusLogin =
                                            "รูปแบบอีเมลไม่ถูกต้อง The email address is badly formatted.";
                                      });
                                    }
                                    if (e.code == "weak-password") {
                                      setState(() {
                                        statusLogin =
                                            "รหัสผ่านควรมีอย่างน้อย 6 ตัวอักษร Password should be at least 6 characters";
                                      });
                                    }
                                    if (e.code == "wrong-password") {
                                      setState(() {
                                        statusLogin =
                                            "รหัสผ่านไม่ถูกต้อง The password is invalid ";
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("don't have an account?"),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _authentication = true;
                                      });
                                    },
                                    child: const Text("Register"))
                              ],
                            ),
                          ),
                        ],
                      ))
                  :
                  //Authentication =========================================================================
                  Container(
                      height: 360,
                      width: !Responsive.isMobile(context)
                          ? sizePageWidth * 0.7
                          : sizePageWidth * 0.95,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Image.asset(
                              "images/email2.png",
                              height: 95,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 20,
                            child: Text(
                              "ยืนยันตัวตนด้วยอีเมลของท่าน Authenticate with your email",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: !Responsive.isMobile(context)
                                ? sizePageWidth * 0.5
                                : sizePageWidth * 0.9,
                            height: 45,
                            child: TextField(
                              controller: _emailAuth,
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
                            height: 10,
                          ),
                          SizedBox(
                            width: !Responsive.isMobile(context)
                                ? sizePageWidth * 0.5
                                : sizePageWidth * 0.9,
                            height: 45,
                            child: TextField(
                              obscureText: !_passwordVisible,
                              controller: _passwordAuth,
                              decoration: InputDecoration(
                                hintText: "Password",
                                prefixIcon: const Icon(Icons.vpn_key),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8.0)),
                                fillColor: Colors.white,
                                filled: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: colorPriority2,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: 20,
                              child: Text(
                                statusAuth,
                                style: const TextStyle(color: colorButtonRed),
                              )),
                          SizedBox(
                            height: 40,
                            width: 200,
                            child: Card(
                              color: colorBlue,
                              child: InkWell(
                                child: waitRes == false
                                    ? const Center(
                                        child: Text(
                                        "Register",
                                        style: TextStyle(color: Colors.white),
                                      ))
                                    : const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            // strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                onTap: () async {
                                  setState(() {
                                    waitRes = true;
                                  });
                                  try {
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: _emailAuth.text,
                                            password: _passwordAuth.text)
                                        .then((value) async {
                                      setState(() {
                                        waitRes = false;
                                      });
                                      // try {
                                      //   await FirebaseAuth.instance
                                      //       .signInWithEmailAndPassword(
                                      //           email: _emailAuth.text,
                                      //           password: _passwordAuth.text)
                                      //       .then((value) {
                                      //     Navigator.pushReplacement(context,
                                      //         MaterialPageRoute(
                                      //             builder: (context) {
                                      //       return EmailVerification();
                                      //     }));
                                      //   });
                                      // } on FirebaseAuthException catch (e) {
                                      //   // print(e);
                                      // }
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    print(e.toString());
                                    setState(() {
                                      waitRes = false;
                                    });
                                    // print(e.message);
                                    // print(e.code);
                                    if (e.code == "email-already-in-use") {
                                      setState(() {
                                        statusAuth =
                                            "ที่อยู่อีเมลถูกใช้แล้ว email address is already in use by another account";
                                      });
                                    }
                                    if (e.code == "weak-password") {
                                      setState(() {
                                        statusAuth =
                                            "รหัสผ่านควรมีอย่างน้อย 6 ตัวอักษร Password should be at least 6 characters";
                                      });
                                    }
                                    if (e.code == "invalid-email") {
                                      setState(() {
                                        statusAuth =
                                            "รูปแบบอีเมลไม่ถูกต้อง The email address is badly formatted.";
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("already have an account?"),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _authentication = false;
                                      });
                                    },
                                    child: const Text("Login"))
                              ],
                            ),
                          ),
                        ],
                      )),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReserPassword()),
                    );
                  },
                  child: const Text(
                    "forget password?",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ));
  }
}
