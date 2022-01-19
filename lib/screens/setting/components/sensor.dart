import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/constants.dart';
import 'package:flutter/services.dart';
import '../../../responsive.dart';

class ScncerData extends StatelessWidget {
  final Stream<QuerySnapshot> _senser =
      FirebaseFirestore.instance.collection('sensors').snapshots();

  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    return StreamBuilder(
        stream: _senser,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong',
                style: TextStyle(color: colorButtonRed));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: const Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(color: colorBlue),
                ),
              ),
            );
          }
          // print(snapshot.data!.docs);
          return ListSensor(snapshot.data!.docs);
        });
  }
}

class ListSensor extends StatefulWidget {
  List<QueryDocumentSnapshot<Object?>> sensorData;
  ListSensor(this.sensorData);

  @override
  State<ListSensor> createState() => _ListSensorState();
}

class _ListSensorState extends State<ListSensor> {
  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal, //แสดง widget เป็น แนวนอน 😘
          itemCount: widget.sensorData.length,
          itemBuilder: (context, index) {
            return SizedBox(
              width: 200,
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: colorSensor,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      showDialogDetellsSensor(
                          widget.sensorData[index].get("name"),
                          widget.sensorData[index].id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.memory_outlined,
                            color: colorTextP2,
                            size: 35,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              "ชื่อ: ${widget.sensorData[index].get("name")}",
                              style: const TextStyle(color: colorTextP2),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              "ID: ${widget.sensorData[index].id}",
                              style: const TextStyle(color: colorTextP2),
                            ),
                          ),
                          widget.sensorData[index].get("status") == true
                              ? const SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    "สถานะ: กำลังใช้งาน",
                                    style: TextStyle(color: colorTextP2),
                                  ),
                                )
                              : const SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    "สถานะ: ว่าง",
                                    style: TextStyle(color: colorTextP2),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  )),
            );
          },
        ),
      ),
    );
  }

  Future<void> showDialogDetellsSensor(String name, String sensorID) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    TextEditingController _sensorName = TextEditingController();
    _sensorName.text = name;
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              backgroundColor: secondaryColor,
              title: const Icon(
                Icons.memory_outlined,
                color: colorSensor,
              ),
              content: SizedBox(
                  height: 120,
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
                          child: Row(
                            children: [
                              Text('ID : $sensorID',
                                  style: const TextStyle(color: colorTextP1)),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: sensorID));
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(
                                  Icons.content_copy_outlined,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          )),
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
              ]);
        });
  }

  Future<void> delete(String sensorID, String listID) {
    CollectionReference sensors =
        FirebaseFirestore.instance.collection('sensors');
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
}
