import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/screens/validate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  // FirebaseMessaging.instance.getToken();
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final Future<FirebaseApp> _firebase = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Temperature Humidity System',
        theme: ThemeData(
          scaffoldBackgroundColor: bgColor,
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.sarabunTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.black),
          canvasColor: secondaryColor,
        ),
        home: Scaffold(
            body: FutureBuilder(
          future: _firebase,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error ${snapshot.hasError}");
            }
            if (snapshot.connectionState == ConnectionState.done) {
              Firebase.initializeApp().then((value) async {
                FirebaseAuth.instance.authStateChanges().listen((event) async {
                  if (event != null) {
                    await Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return EmailVerification();
                    }));
                  }
                });
              });
              return const LoginPage();
            }
            return const Center(
                child: CircularProgressIndicator(
              strokeWidth: 2,
            ));
          },
        )));
  }
}
