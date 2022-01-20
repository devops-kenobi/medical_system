import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_temperature_humidity_system/responsive.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../constants.dart';

class CreateCabinet extends StatefulWidget {
  @override
  State<CreateCabinet> createState() => _CreateCabinetState();
}

class _CreateCabinetState extends State<CreateCabinet> {
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
            "  ที่เก็บยา",
            style: TextStyle(color: colorTextP3),
          ),
          const Spacer(),
          SizedBox(
            width: 60,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              color: colorPriority1,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                child: const Icon(
                  Icons.add_outlined,
                  color: colorTextP2,
                ),
                onTap: () => showDialogCreateCabinet(),
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

  Future<void> showDialogCreateCabinet() {
    TextEditingController _cabinetName = TextEditingController();
    TextEditingController _temperatureMax = TextEditingController();
    TextEditingController _temperatureMin = TextEditingController();
    TextEditingController _humidityMax = TextEditingController();
    Set sensor = {};
    String status = "";
    bool waitRes = false;
    bool errorTemperature = false;
    bool errorHumidity = false;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double sizePageWidth = MediaQuery.of(context).size.width;
        double sizePageHeight = MediaQuery.of(context).size.height;

        final Stream<QuerySnapshot> _readySensor = FirebaseFirestore.instance
            .collection('sensors')
            .where('status', isEqualTo: false)
            .snapshots();

        CollectionReference _cabinet =
            FirebaseFirestore.instance.collection('cabinets');
        CollectionReference _sensor =
            FirebaseFirestore.instance.collection('sensors');

        Future<void> addCabinet(String cabinetName, double temperatureMax,
            double temperatureMin, double humidityMax, Set sensor) {
          return _cabinet.add({
            'name': cabinetName,
            'temperature_max': temperatureMax,
            'temperature_min': temperatureMin,
            'humidity_max': humidityMax,
            "sensor_id": FieldValue.arrayUnion(sensor.toList())
          }).catchError((error) => print("Failed to add user: $error"));
        }

        Future<void> updateScncer(String sensorID) {
          return _sensor
              .doc(sensorID)
              .update({'status': true})
              .then((value) => print("Successfully"))
              .catchError((error) => print("Failed to update Scncer: $error"));
        }

        return StatefulBuilder(builder: (context, setState) {
          //StatefulBuilder = make it possible to setstate in dialog
          return SingleChildScrollView(
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              backgroundColor: secondaryColor,
              title: const Text('เพิ่มที่เก็บยา',
                  style: TextStyle(
                    color: colorTextP1,
                  )),
              content: SizedBox(
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
                        icon: SvgPicture.asset("assets/icons/temMin.svg",
                            color: colorTextP2),
                        hintText: "อุณหภูมิต่ำสุดที่ยอมรับได้ °C",
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
                        icon: SvgPicture.asset("assets/icons/humidityMax.svg",
                            color: colorTextP2),
                        suffixText: "%",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0)),
                        fillColor:
                            errorHumidity == false ? colorTextP2 : Colors.red,
                        filled: true,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: Center(
                        child: Text(
                          status,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        " เซนเซอร์ ที่ใช้",
                        style: TextStyle(color: colorTextP3),
                      ),
                    ),
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: ListView.builder(
                          scrollDirection:
                              Axis.horizontal, //แสดง widget เป็น แนวนอน 😘
                          itemCount: sensor.length,
                          itemBuilder: (context, index) {
                            final Stream<DocumentSnapshot<Map<String, dynamic>>>
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
                                    return const Text('Something went wrong',
                                        style:
                                            TextStyle(color: colorButtonRed));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                        width: 130,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          color: colorSensor,
                                          child: const Center(
                                            child: Text(
                                              "Loading...",
                                              style:
                                                  TextStyle(color: colorBlue),
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
                                        borderRadius: BorderRadius.circular(10),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
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
                                                      Icons.memory_outlined,
                                                      color: colorTextP2),
                                                  const SizedBox(
                                                    width: 7,
                                                  ),
                                                  Text(
                                                    snapshot.data!.get('name'),
                                                    style: const TextStyle(
                                                        color: colorTextP2),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            sensor.remove(snapshot.data!.id);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                });
                          }),
                    ),
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
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong',
                                style: TextStyle(color: colorButtonRed));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              "Loading...",
                              style: TextStyle(color: colorBlue),
                            );
                          }
                          // print(snapshot.data!.docs);
                          return Container(
                            height: 120,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                color: bgColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: snapshot.data!.docs.isNotEmpty
                                  ? ListView.builder(
                                      scrollDirection: Axis
                                          .horizontal, //แสดง widget เป็น แนวนอน 😘
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        return SizedBox(
                                          width: 200,
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              color: colorSensor,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onTap: () {
                                                  setState(() {
                                                    sensor.add(snapshot
                                                        .data!.docs[index].id);
                                                  });
                                                },
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
                                                          "ชื่อ: ${snapshot.data!.docs[index].get("name")}",
                                                          style: const TextStyle(
                                                              color:
                                                                  colorTextP2),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: double.infinity,
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
                                        style: TextStyle(color: colorTextP3),
                                      ),
                                    ),
                            ),
                          );
                        }),
                  ],
                ),
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
                              addCabinet(
                                      _cabinetName.text,
                                      double.parse(_temperatureMax.text),
                                      double.parse(_temperatureMin.text),
                                      double.parse(_humidityMax.text),
                                      sensor)
                                  .then((value) {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                                setState(() {
                                  waitRes = false;
                                });
                                Fluttertoast.showToast(
                                    msg: "สำเร็จ",
                                    fontSize: 40,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 2,
                                    textColor: colorTextP2);
                                for (var element in sensor) {
                                  updateScncer(element);
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
