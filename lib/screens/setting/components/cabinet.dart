import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_temperature_humidity_system/screens/components/provider.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../responsive.dart';

class Cabinet extends StatefulWidget {
  Cabinet({Key? key}) : super(key: key);

  @override
  State<Cabinet> createState() => _CabinetState();
}

class _CabinetState extends State<Cabinet> {
  final Stream<QuerySnapshot> _cabinet =
      FirebaseFirestore.instance.collection('cabinets').snapshots();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProviderStatus>(context);
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    double distance = sizePageWidth * 0.15;
    return StreamBuilder(
        stream: _cabinet,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong',
                style: TextStyle(color: colorButtonRed));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text(
              "Loading...",
              style: TextStyle(color: colorBlue),
            );
          }

          return Container(
              height: sizePageHeight * 0.65,
              width: sizePageWidth,
              decoration: const BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;

                    List<dynamic> sensor = data["sensor_id"];
                    double sizeCard = 107;
                    double sizeCardRadius = 10;
                    double fontSize = 20;
                    if (Responsive.isMobile(context)) fontSize = 15;
                    return SizedBox(
                      height: 150,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: colorPriority1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: !Responsive.isMobile(context)
                                      ? sizePageWidth * 0.15
                                      : sizePageWidth * 0.17,
                                  child: Column(
                                    children: [
                                      const Text(
                                        "ชื่อที่เก็บยา",
                                        style: TextStyle(color: colorPriority5),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        height: sizeCard,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      sizeCardRadius)),
                                          color: colorPriority4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: [
                                                const Icon(Icons.place_outlined,
                                                    color: colorTextP2),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(data['name'],
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        color: colorTextP2,
                                                        fontSize: 30))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              SizedBox(
                                  width: !Responsive.isMobile(context)
                                      ? sizePageWidth * 0.15
                                      : sizePageWidth * 0.20,
                                  child: Column(
                                    children: [
                                      const Text(
                                        "อุณหภูมิ",
                                        style: TextStyle(color: colorPriority5),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        height: sizeCard,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      sizeCardRadius)),
                                          color: colorPriority4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: [
                                                SvgPicture.asset(
                                                    "assets/icons/temperature.svg",
                                                    color: colorTextP2),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: sizeCard,
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .vertical_align_top_outlined,
                                                          color: colorTextP2),
                                                      Text(
                                                          " ${data['temperature_max']} °C"
                                                              .toString(),
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  colorTextP2,
                                                              fontSize:
                                                                  fontSize)),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: sizeCard,
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .vertical_align_bottom_outlined,
                                                          color: colorTextP2),
                                                      Text(
                                                          " ${data['temperature_min']} °C"
                                                              .toString(),
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  colorTextP2,
                                                              fontSize:
                                                                  fontSize)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              SizedBox(
                                  width: !Responsive.isMobile(context)
                                      ? sizePageWidth * 0.15
                                      : sizePageWidth * 0.20,
                                  child: Column(
                                    children: [
                                      const Text(
                                        "ความชื้น",
                                        style: TextStyle(color: colorPriority5),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        height: sizeCard,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      sizeCardRadius)),
                                          color: colorPriority4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: [
                                                SvgPicture.asset(
                                                    "assets/icons/humidity.svg",
                                                    color: colorTextP2),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .vertical_align_top_outlined,
                                                          color: colorTextP2),
                                                      Text(
                                                          " ${data['humidity_max']} %"
                                                              .toString(),
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color:
                                                                  colorTextP2,
                                                              fontSize:
                                                                  fontSize)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              SizedBox(
                                  width: !Responsive.isMobile(context)
                                      ? sizePageWidth * 0.15
                                      : sizePageWidth * 0.20,
                                  child: Column(
                                    children: [
                                      const Text(
                                        "เซนเซอร์ ",
                                        style: TextStyle(color: colorPriority5),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        height: sizeCard,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      sizeCardRadius)),
                                          color: colorPriority4,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: [
                                                const Icon(
                                                    Icons.memory_outlined,
                                                    color: colorTextP2),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                SizedBox(
                                                  height: 60,
                                                  width: double.infinity,
                                                  child: ListView.builder(
                                                    itemCount: sensor.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final Stream<
                                                              DocumentSnapshot<
                                                                  Map<String,
                                                                      dynamic>>>
                                                          documentSensor =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'sensors')
                                                              .doc(
                                                                  sensor[index])
                                                              .snapshots();
                                                      return StreamBuilder(
                                                        stream: documentSensor,
                                                        builder: (context,
                                                            AsyncSnapshot<
                                                                    DocumentSnapshot<
                                                                        Map<String,
                                                                            dynamic>>>
                                                                snapshot) {
                                                          if (snapshot
                                                              .hasError) {
                                                            return const Text(
                                                                'Something went wrong',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red));
                                                          }

                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const Text(
                                                              "Loading",
                                                              style: TextStyle(
                                                                  color:
                                                                      colorTextP2),
                                                            );
                                                          }
                                                          return SizedBox(
                                                              height: 40,
                                                              child: Card(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5.0),
                                                                  ),
                                                                  color:
                                                                      colorSensor,
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () => showDialogDeleteDataSensor(
                                                                        snapshot.data![
                                                                            'name'],
                                                                        snapshot
                                                                            .data!
                                                                            .id),
                                                                    child: Row(
                                                                      children: [
                                                                        const Icon(
                                                                            Icons
                                                                                .memory_outlined,
                                                                            color:
                                                                                colorTextP2),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          snapshot
                                                                              .data!['name'],
                                                                          style:
                                                                              const TextStyle(color: colorTextP2),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )));
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              const Spacer(),
                              IconButton(
                                onPressed: () => showDialogSetting(document.id),
                                icon: const Icon(Icons.tune_outlined,
                                    color: colorTextP2),
                              ),
                              SizedBox(
                                width: !Responsive.isMobile(context) ? 10 : 4,
                              ),
                              if (!Responsive.isMobile(context))
                                IconButton(
                                  onPressed: () {
                                    if (sensor.isNotEmpty) {
                                      showDialogNotificationCabinet();
                                    } else {
                                      showDialogDeleteCabinet(
                                          document.id, data['name']);
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outlined,
                                      color: colorTextP2),
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ));
        });
  }

  CollectionReference sensors =
      FirebaseFirestore.instance.collection('sensors');

  Future<void> delete(String sensorID, String listID) {
    return sensors.doc(sensorID).collection('list_data').doc(listID).delete();
  }

  Future<void> deleteData(String sensorID) {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          // backgroundColor: secondaryColor,
          title: Row(
            children: const [
              Icon(
                Icons.restart_alt_outlined,
                color: colorButtonRed,
              ),
              Text(' รีเซ็ตเซนเซอร์',
                  style: TextStyle(
                    color: colorButtonRed,
                  )),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              "ข้อมูลที่เซนเซอร์วัดได้ทั้งหมดจะถูกลบและเริ่มต้นเก็บข้อมูลใหม่",
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
                FirebaseFirestore.instance
                    .collection('sensors')
                    .doc(sensorID)
                    .collection('list_data')
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    delete(sensorID, doc.id);
                  }
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDialogDeleteDataSensor(String name, String sensorID) {
    return showDialog(
        useSafeArea: true,
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            backgroundColor: secondaryColor,
            title: const Icon(
              Icons.memory_outlined,
              color: colorSensor,
            ),
            content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    SizedBox(
                        width: 260,
                        child: Text(
                          'ชื่อ : $name',
                          style: const TextStyle(color: colorTextP1),
                        )),
                    SizedBox(
                        width: 260,
                        child: Text('ID : $sensorID',
                            style: const TextStyle(color: colorTextP1))),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () => deleteData(sensorID),
                        child: const Text('รีเซ็ต'))
                  ],
                )),
            actions: [
              TextButton(
                child: const Text('ตกลง'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> showDialogDeleteCabinet(String cabinetID, String cabinetName) {
    CollectionReference _cabinet =
        FirebaseFirestore.instance.collection('cabinets');

    Future<void> deleteCabinet(String cabinetID) {
      return _cabinet.doc(cabinetID).delete();
    }

    return showDialog(
      useSafeArea: true,
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            'ลบที่เก็บยา',
            style: TextStyle(color: colorButtonRed),
          ),
          content: Text("คุณแน่ใจหรือไม่ว่าต้องการลบที่เก็บยา $cabinetName"),
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
                Navigator.of(context).pop();
                deleteCabinet(cabinetID);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDialogNotificationCabinet() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          // backgroundColor: secondaryColor,
          title: Row(
            children: const [
              Text('ไม่สามารถลบได้',
                  style: TextStyle(
                    color: colorButtonRed,
                  )),
              Icon(
                Icons.error_outlined,
                color: colorButtonRed,
              ),
            ],
          ),
          content: const Text(
            "มีเซนเซอร์กำลังทำงานอยู่ภายใน กรุณาถอนการติดตั้งเซนเซอร์ก่อน",
          ),
          actions: [
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDialogSetting(String cabinetID) {
    TextEditingController _cabinetName = TextEditingController();
    TextEditingController _temperatureMax = TextEditingController();
    TextEditingController _temperatureMin = TextEditingController();
    TextEditingController _humidityMax = TextEditingController();
    Set addSensor = {};
    String status = "";
    bool waitRes = false;
    bool errorTemperature = false;
    bool errorHumidity = false;

    CollectionReference _sensor =
        FirebaseFirestore.instance.collection('sensors');

    CollectionReference _cabinet =
        FirebaseFirestore.instance.collection('cabinets');

    Stream<DocumentSnapshot<Map<String, dynamic>>> _cabinets = FirebaseFirestore
        .instance
        .collection('cabinets')
        .doc(cabinetID)
        .snapshots();

    final Stream<QuerySnapshot> _readySensor = FirebaseFirestore.instance
        .collection('sensors')
        .where('status', isEqualTo: false)
        .snapshots();

    Future<void> updateCabinet(
        String cabinetID,
        String cabinetName,
        double temperatureMax,
        double temperatureMin,
        double humidityMax,
        Set sensor) {
      return _cabinet
          .doc(cabinetID)
          .update(
            {
              'name': cabinetName,
              'temperature_max': temperatureMax,
              'temperature_min': temperatureMin,
              'humidity_max': humidityMax,
              'sensor_id': FieldValue.arrayUnion(sensor.toList())
            },
          )
          .then((value) => print("Succeessfully"))
          .catchError((error) => print("Error: $error"));
    }

    Future<void> deleteSensor(String cabinetID, List sensor) {
      return _cabinet
          .doc(cabinetID)
          .update({'sensor_id': FieldValue.arrayRemove(sensor)});
    }

    Future<void> updateScncerUsed(String sensorID) {
      return _sensor
          .doc(sensorID)
          .update({'status': true})
          .then((value) => print("Successfully"))
          .catchError((error) => print("Failed to update Scncer: $error"));
    }

    Future<void> updateScncerUnused(String sensorID) {
      return _sensor
          .doc(sensorID)
          .update({'status': false})
          .then((value) => print("Successfully"))
          .catchError((error) => print("Failed to update Scncer: $error"));
    }

    Future<void> showDialogUninstallSensor(
        String cabinetID, List sensor, String sensorID) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            // backgroundColor: secondaryColor,
            title: Row(
              children: const [
                Text('ถอนการติดตั้ง',
                    style: TextStyle(
                      color: colorButtonRed,
                    )),
                Icon(
                  Icons.gpp_maybe_outlined,
                  color: colorButtonRed,
                ),
              ],
            ),
            content: const SingleChildScrollView(
              child: Text(
                "คุณแน่ใจหรือไม่ว่าต้องการถอนการติดตั้ง เมื่อคุณกดปุ่ม 'ตกลง' ระบบจะถอนการติดตั้งตัวเซนเซอร์ ทันที",
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
                  Navigator.of(context).pop();
                  deleteSensor(cabinetID, sensor).then((value) {
                    updateScncerUnused(sensorID);
                  });
                },
              ),
            ],
          );
        },
      );
    }

    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        double sizePageWidth = MediaQuery.of(context).size.width;
        return StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: secondaryColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              title: const Text(
                'ปรับปรุง/แก้ไข',
                style: TextStyle(color: colorTextP1),
              ),
              content: StreamBuilder(
                stream: _cabinets,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      'Something went wrong',
                      style: TextStyle(color: Colors.red),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      "Loading",
                      style: TextStyle(color: colorTextP1),
                    );
                  }

                  _cabinetName.text = snapshot.data!.get('name');
                  _temperatureMax.text =
                      snapshot.data!.get('temperature_max').toString();
                  _temperatureMin.text =
                      snapshot.data!.get('temperature_min').toString();
                  _humidityMax.text =
                      snapshot.data!.get('humidity_max').toString();
                  Set sensor = snapshot.data!.get('sensor_id').toSet();
                  String cabinetID = snapshot.data!.id;
                  return SizedBox(
                      width: !Responsive.isMobile(context)
                          ? sizePageWidth * 0.5
                          : sizePageWidth * 0.9,
                      child: Column(
                        children: [
                          TextField(
                            controller: _cabinetName,
                            decoration: InputDecoration(
                              hintText: "ชื่อ",
                              icon: const Icon(Icons.add_location_alt_outlined,
                                  color: colorTextP2),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8.0)),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _temperatureMax,
                            decoration: InputDecoration(
                              hintText: "อุณหภูมิสูงสุดที่ยอมรับได้ °C",
                              icon: SvgPicture.asset("assets/icons/temMax.svg",
                                  color: colorTextP2),
                              suffixText: "°C",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8.0)),
                              fillColor: errorTemperature == false
                                  ? colorTextP2
                                  : Colors.red,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _temperatureMin,
                            decoration: InputDecoration(
                              hintText: "อุณหภูมิต่ำสุดที่ยอมรับได้ °C",
                              icon: SvgPicture.asset("assets/icons/temMin.svg",
                                  color: colorTextP2),
                              suffixText: "°C",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8.0)),
                              fillColor: errorTemperature == false
                                  ? colorTextP2
                                  : Colors.red,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _humidityMax,
                            decoration: InputDecoration(
                              hintText: "ความชื้นสูงสุดที่ยอมรับได้ %",
                              icon: SvgPicture.asset(
                                  "assets/icons/humidityMax.svg",
                                  color: colorTextP2),
                              suffixText: "%",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8.0)),
                              fillColor: errorHumidity == false
                                  ? colorTextP2
                                  : Colors.red,
                              filled: true,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            width: double.infinity,
                            child: Text(
                              " เซนเซอร์ ที่ใช้งานอยู่",
                              style: TextStyle(color: colorTextP3),
                            ),
                          ),
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                color: bgColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: sensor.length,
                              itemBuilder: (context, index) {
                                final Stream<
                                        DocumentSnapshot<Map<String, dynamic>>>
                                    _senser = FirebaseFirestore.instance
                                        .collection('sensors')
                                        .doc(sensor.toList()[index])
                                        .snapshots();
                                return StreamBuilder(
                                    stream: _senser,
                                    builder: (context,
                                        AsyncSnapshot<
                                                DocumentSnapshot<
                                                    Map<String, dynamic>>>
                                            snapshot) {
                                      if (snapshot.hasError) {
                                        return const Text(
                                            'Something went wrong',
                                            style: TextStyle(
                                                color: colorButtonRed));
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return SizedBox(
                                            width: 120,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              color: colorSensor,
                                              child: const Center(
                                                child: Text(
                                                  "Loading...",
                                                  style: TextStyle(
                                                      color: colorBlue),
                                                ),
                                              ),
                                            ));
                                      }
                                      return SizedBox(
                                        width: 200,
                                        child: Stack(
                                          children: [
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              color: colorSensor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Column(
                                                  children: [
                                                    const Icon(
                                                        Icons.memory_outlined,
                                                        color: colorTextP2),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: Text(
                                                        "ชื่อ: ${snapshot.data!.get('name')}",
                                                        style: const TextStyle(
                                                            color: colorTextP2),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: Text(
                                                        "ID: ${snapshot.data!.id}",
                                                        style: const TextStyle(
                                                            color: colorTextP2),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                                right: -2,
                                                top: -2,
                                                child: SizedBox(
                                                  height: 25,
                                                  width: 25,
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100)),
                                                    color:
                                                        const Color(0XFFDD9200),
                                                    child: InkWell(
                                                      hoverColor: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: const Icon(
                                                        Icons.close_outlined,
                                                        size: 14,
                                                        color: Colors.white,
                                                      ),
                                                      onTap: () {
                                                        List sensorID = [
                                                          snapshot.data!.id
                                                        ];
                                                        showDialogUninstallSensor(
                                                            cabinetID,
                                                            sensorID,
                                                            snapshot.data!.id);
                                                      },
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        ),
                                      );
                                    });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            width: double.infinity,
                            child: Text(
                              " เซนเซอร์ ที่เพิ่ม",
                              style: TextStyle(color: colorTextP3),
                            ),
                          ),
                          Container(
                              height: 80,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                  color: bgColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: addSensor.length,
                                itemBuilder: (context, index) {
                                  final Stream<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>> _senser =
                                      FirebaseFirestore.instance
                                          .collection('sensors')
                                          .doc(addSensor.toList()[index])
                                          .snapshots();
                                  return StreamBuilder(
                                      stream: _senser,
                                      builder: (context,
                                          AsyncSnapshot<
                                                  DocumentSnapshot<
                                                      Map<String, dynamic>>>
                                              snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text(
                                              'Something went wrong',
                                              style: TextStyle(
                                                  color: colorButtonRed));
                                        }

                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return SizedBox(
                                              width: 130,
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                color: colorSensor,
                                                child: const Center(
                                                  child: Text(
                                                    "Loading...",
                                                    style: TextStyle(
                                                        color: colorBlue),
                                                  ),
                                                ),
                                              ));
                                        }
                                        return SizedBox(
                                          width: 130,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            color: colorSensor,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: Row(
                                                        children: const [
                                                          Spacer(),
                                                          Icon(
                                                            Icons
                                                                .file_download_outlined,
                                                            color: colorTextP2,
                                                            size: 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .memory_outlined,
                                                            color: colorTextP2),
                                                        const SizedBox(
                                                          width: 7,
                                                        ),
                                                        Text(
                                                          snapshot.data!
                                                              .get('name'),
                                                          style: const TextStyle(
                                                              color:
                                                                  colorTextP2),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  addSensor.remove(
                                                      snapshot.data!.id);
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      });
                                },
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            width: double.infinity,
                            child: Text(
                              " เซนเซอร์ ที่ว่าง",
                              style: TextStyle(color: colorTextP3),
                            ),
                          ),
                          StreamBuilder(
                              stream: _readySensor,
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('Something went wrong',
                                      style: TextStyle(color: colorButtonRed));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: const Center(
                                      child: Text(
                                        "Loading...",
                                        style: TextStyle(color: colorBlue),
                                      ),
                                    ),
                                  );
                                }

                                return Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: snapshot.data!.docs.isNotEmpty
                                        ? ListView.builder(
                                            scrollDirection: Axis
                                                .horizontal, //แสดง widget เป็น แนวนอน 😘
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: (context, index) {
                                              return SizedBox(
                                                width: 200,
                                                child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    color: colorSensor,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      onTap: () {
                                                        setState(() {
                                                          addSensor.add(snapshot
                                                              .data!
                                                              .docs[index]
                                                              .id);
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: Column(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .memory_outlined,
                                                                color:
                                                                    colorTextP2),
                                                            SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              child: Text(
                                                                "ชื่อ: ${snapshot.data!.docs[index].get("name")}",
                                                                style: const TextStyle(
                                                                    color:
                                                                        colorTextP2),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              child: Text(
                                                                "ID: ${snapshot.data!.docs[index].id}",
                                                                style: const TextStyle(
                                                                    color:
                                                                        colorTextP2),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                              );
                                            },
                                          )
                                        : const Center(
                                            child: Text(
                                              "ไม่พบเซนเซอร์ ที่ว่าง",
                                              style:
                                                  TextStyle(color: colorTextP3),
                                            ),
                                          ),
                                  ),
                                );
                              }),
                          SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                status,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ));
                },
              ),
              actions: [
                TextButton(
                  child: const Text('ยกเลิก'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                waitRes == false
                    ? TextButton(
                        child: const Text('ตกลง'),
                        onPressed: () {
                          errorTemperature = false;
                          errorHumidity = false;

                          try {
                            if (double.parse(_temperatureMax.text) <
                                double.parse(_temperatureMin.text)) {
                              setState(() {
                                errorTemperature = true;
                                status =
                                    "อุณหภูมิสูงสุดที่ยอมรับได้ ต้องมากกว่า อุณหภูมิต่ำสุดที่ยอมรับได้";
                              });
                            } else if (double.parse(_humidityMax.text) < 0 ||
                                double.parse(_humidityMax.text) > 100) {
                              setState(() {
                                errorHumidity = true;
                                status =
                                    "ค่าความชื้นสัมพัทธ์ควรอยู่ในระหว่าง 0 - 100";
                              });
                            } else {
                              setState(() {
                                waitRes = true;
                              });
                              updateCabinet(
                                      cabinetID,
                                      _cabinetName.text,
                                      double.parse(_temperatureMax.text),
                                      double.parse(_temperatureMin.text),
                                      double.parse(_humidityMax.text),
                                      addSensor)
                                  .then((value) {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                                setState(() {
                                  waitRes = false;
                                });
                                Fluttertoast.showToast(
                                    msg: "สำเร็จ",
                                    fontSize: 40,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 2,
                                    textColor: colorTextP2);
                                for (var element in addSensor) {
                                  updateScncerUsed(element);
                                }
                              });
                            }
                          } catch (e) {
                            setState(() {
                              waitRes = false;
                              status = "รูแบบข้อมูลไม่ถูกต้อง";
                            });
                          }
                        })
                    : const SizedBox(
                        width: 50,
                        child: Center(
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator()),
                        ),
                      ),
              ],
            ),
          );
        });
      },
    );
  }
}
