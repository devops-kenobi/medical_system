import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../responsive.dart';

class CreateSensor extends StatefulWidget {
  const CreateSensor({Key? key}) : super(key: key);

  @override
  State<CreateSensor> createState() => _CreateSensorState();
}

class _CreateSensorState extends State<CreateSensor> {
  CollectionReference sensors =
      FirebaseFirestore.instance.collection('sensors');
  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: sizePageWidth,
      height: 30,
      child: Row(
        children: [
          const Text(
            "  เซนเซอร์",
            style: TextStyle(color: colorTextP3),
          ),
          const Spacer(),
          SizedBox(
            width: 60,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              color: colorSensor,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                child: const Icon(
                  Icons.add_outlined,
                  color: colorTextP2,
                ),
                onTap: () => showDialogCreateSensor(),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }

  Future<void> addSensor(String name) {
    return sensors.add({
      'name': name,
      'status': 'false',
    });
    // .then((value) => Navigator.of(context).pop())
    // // ignore: avoid_print
    // .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> showDialogCreateSensor() {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    TextEditingController _sensorName = TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              backgroundColor: secondaryColor,
              title: const Text('เพิ่มเซนเซอร์',
                  style: TextStyle(
                    color: colorTextP1,
                  )),
              content: SizedBox(
                width: !Responsive.isMobile(context)
                    ? sizePageWidth * 0.2
                    : sizePageWidth * 0.9,
                child: TextField(
                  maxLength: 6,
                  controller: _sensorName,
                  decoration: InputDecoration(
                    hintText: "ชื่อเซนเซอร์",
                    icon: const Icon(Icons.memory_outlined, color: colorTextP2),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0)),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
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
                    if (_sensorName.text.isNotEmpty &&
                        _sensorName.text.length > 1) {
                      addSensor(_sensorName.text);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
  }
}
