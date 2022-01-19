import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_temperature_humidity_system/responsive.dart';
import 'package:flutter_temperature_humidity_system/screens/components/provider.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';

class BodyHome extends StatelessWidget {
  BodyHome({Key? key}) : super(key: key);

  final Stream<QuerySnapshot> _cabinet =
      FirebaseFirestore.instance.collection('cabinets').snapshots();

  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    return Container(
        height: sizePageHeight * 0.9,
        width: sizePageWidth,
        decoration: const BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: StreamBuilder(
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
              // print(snapshot.data!.docs);
              // print(snapshot.data!.docs[0].id);
              // print(snapshot.data!.docs.length);
              return BodyHomeInfo(snapshot.data!.docs);
            }));
  }
}

class BodyHomeInfo extends StatelessWidget {
  final data;
  BodyHomeInfo(this.data);

  @override
  Widget build(BuildContext context) {
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    // print(data.length);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: !Responsive.isMobile(context) && data.length < 21
              ? Wrap(
                  direction: Axis.horizontal,
                  children: [
                    if (data.length >= 1) MedicineCabinet(data[0].id),
                    if (data.length >= 2) MedicineCabinet(data[1].id),
                    if (data.length >= 3) MedicineCabinet(data[2].id),
                    if (data.length >= 4) MedicineCabinet(data[3].id),
                    if (data.length >= 5) MedicineCabinet(data[4].id),
                    if (data.length >= 6) MedicineCabinet(data[5].id),
                    if (data.length >= 7) MedicineCabinet(data[6].id),
                    if (data.length >= 8) MedicineCabinet(data[7].id),
                    if (data.length >= 9) MedicineCabinet(data[8].id),
                    if (data.length >= 10) MedicineCabinet(data[9].id),
                    if (data.length >= 11) MedicineCabinet(data[10].id),
                    if (data.length >= 12) MedicineCabinet(data[11].id),
                    if (data.length >= 13) MedicineCabinet(data[12].id),
                    if (data.length >= 14) MedicineCabinet(data[13].id),
                    if (data.length >= 15) MedicineCabinet(data[14].id),
                    if (data.length >= 16) MedicineCabinet(data[15].id),
                    if (data.length >= 17) MedicineCabinet(data[16].id),
                    if (data.length >= 18) MedicineCabinet(data[17].id),
                    if (data.length >= 19) MedicineCabinet(data[18].id),
                    if (data.length >= 20) MedicineCabinet(data[19].id),
                  ],
                )
              : SizedBox(
                  height: sizePageHeight,
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: 200,
                          child: MedicineCabinet(data[index].id),
                        );
                      }),
                ),
        ),
      ),
    );
  }
}

class MedicineCabinet extends StatefulWidget {
  final cabinetID;
  MedicineCabinet(this.cabinetID);

  @override
  State<MedicineCabinet> createState() => _MedicineCabinetState();
}

class _MedicineCabinetState extends State<MedicineCabinet> {
  final play = AudioCache();
  final player = AudioPlayer();

  var formatDateTime = DateFormat('yyyy/MM/dd HH:mm');
  var formatTime = DateFormat('HH:mm');

  void notification() {
    play.play('/sound/notification.wav');
  }

  void _stopFile() {
    player.stop();
  }

  @override
  Widget build(BuildContext context) {
    // var provider = Provider.of<ProviderCabinet>(context);
    var provider = Provider.of<ProviderStatus>(context);
    final Stream<DocumentSnapshot<Map<String, dynamic>>> _cabinetData =
        FirebaseFirestore.instance
            .collection("cabinets")
            .doc(widget.cabinetID)
            .snapshots();
    return StreamBuilder(
      stream: _cabinetData,
      builder: (context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Something went wrong',
            style: TextStyle(color: Colors.red),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading", style: TextStyle(color: colorTextP1));
        }
        List<dynamic> sensorIdInCabinet =
            snapshot.data!['sensor_id']; //เซนเซอร์ทั้งหมดที่อยู่ในตู้ยา
        String cabinetName = snapshot.data!['name'];
        double temperatureMax = snapshot.data!['temperature_max'];
        double temperatureMin = snapshot.data!['temperature_min'];
        double humidityMax = snapshot.data!['humidity_max'];
        return SizedBox(
          width: 350,
          child: Card(
            elevation: 15,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: cabinetDefault,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                provider.setCabinetDetellsPage(true);
                provider.setSensorIdInCabinet(snapshot.data!['sensor_id']);
                provider.setStatusCabinet(
                    cabinetName, temperatureMax, temperatureMin, humidityMax);
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 20,
                          color: colorTextP4,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          cabinetName,
                          style:
                              const TextStyle(color: colorTextP4, fontSize: 16),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        SvgPicture.asset(
                          "icon/temMax.svg",
                          color: colorTextP4,
                          height: 20,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          " $temperatureMax°C".toString(),
                          style:
                              const TextStyle(color: colorTextP4, fontSize: 16),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        SvgPicture.asset(
                          "icon/temMin.svg",
                          color: colorTextP4,
                          height: 20,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          " $temperatureMin°C".toString(),
                          style:
                              const TextStyle(color: colorTextP4, fontSize: 16),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        SvgPicture.asset(
                          "icon/humidityMax.svg",
                          color: colorTextP4,
                          height: 20,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          " $humidityMax%".toString(),
                          style:
                              const TextStyle(color: colorTextP4, fontSize: 16),
                        ),
                      ],
                    ),
                    sensorIdInCabinet.isNotEmpty
                        ? SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: ListView.builder(
                              itemCount: sensorIdInCabinet
                                  .length, //จำนวนของเซนเซอร์ที่ติดตั้งอยู่ในตู้ยา
                              itemBuilder: (context, index) {
                                final Stream<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    sensorData = FirebaseFirestore.instance
                                        .collection('sensors')
                                        .doc(sensorIdInCabinet[index])
                                        .collection('list_data')
                                        // .where('time',
                                        //     isLessThanOrEqualTo: DateTime.now())
                                        .orderBy("time", descending: true)
                                        .limit(1)
                                        // .limit(1)
                                        .snapshots();
                                String sensorID = sensorIdInCabinet[index];

                                return StreamBuilder(
                                    stream: sensorData,
                                    builder: (context,
                                        AsyncSnapshot<
                                                QuerySnapshot<
                                                    Map<String, dynamic>>>
                                            snapshot) {
                                      if (snapshot.hasError) {
                                        return const Text(
                                            'Something went wrong',
                                            style:
                                                TextStyle(color: Colors.red));
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text(
                                          "Loading",
                                          style: TextStyle(color: Colors.white),
                                        );
                                      }
                                      // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลของเซนเซอร์-----------
                                      if (snapshot.data!.docs.isEmpty) {
                                        return sensorIdInCabinet.length == 1
                                            ? SizedBox(
                                                height: 140,
                                                child: ListView.builder(
                                                    itemCount: 1,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SvgPicture.asset(
                                                                "icon/temperature.svg",
                                                                color:
                                                                    colorTextP3,
                                                                height: 70,
                                                              ),
                                                              SizedBox(
                                                                height: 110,
                                                                width: 100,
                                                                child: Card(
                                                                  elevation: 10,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15)),
                                                                  color:
                                                                      colorTextP3,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            5.0),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        SensorName(
                                                                            sensorID:
                                                                                sensorID),
                                                                        Row(
                                                                          children: const [
                                                                            Icon(
                                                                              Icons.schedule_outlined,
                                                                              size: 16,
                                                                              color: colorTextP4,
                                                                            ),
                                                                            Text(
                                                                              '-',
                                                                              style: TextStyle(color: colorTextP4),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                          " - °C"
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              color: colorTextP2,
                                                                              fontSize: 40),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              SvgPicture.asset(
                                                                "icon/humidity.svg",
                                                                color:
                                                                    colorTextP3,
                                                                height: 70,
                                                              ),
                                                              SizedBox(
                                                                height: 110,
                                                                width: 100,
                                                                child: Card(
                                                                  elevation: 10,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15)),
                                                                  color:
                                                                      colorTextP3,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            5.0),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        SensorName(
                                                                            sensorID:
                                                                                sensorID),
                                                                        Row(
                                                                          children: const [
                                                                            Icon(
                                                                              Icons.schedule_outlined,
                                                                              size: 16,
                                                                              color: colorTextP4,
                                                                            ),
                                                                            Text(
                                                                              '-',
                                                                              style: TextStyle(color: colorTextP4),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Text(
                                                                          " - %"
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              color: colorTextP2,
                                                                              fontSize: 40),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                              )
                                            : // กรณีที่มีเซนเซอร์มากกว่า 1 ===================================================
                                            SizedBox(
                                                height: 50,
                                                child: ListView.builder(
                                                    itemCount: 1,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SvgPicture.asset(
                                                                "icon/temperature.svg",
                                                                color:
                                                                    colorTextP3,
                                                                height: 40,
                                                              ),
                                                              SizedBox(
                                                                width: 130,
                                                                child: Card(
                                                                  elevation: 5,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  color:
                                                                      colorTextP3,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            2.0),
                                                                    child: Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              55,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              SensorName(sensorID: sensorID),
                                                                              Row(
                                                                                children: const [
                                                                                  Icon(
                                                                                    Icons.schedule_outlined,
                                                                                    size: 15,
                                                                                    color: colorTextP4,
                                                                                  ),
                                                                                  Text(
                                                                                    ' - ',
                                                                                    style: TextStyle(color: colorTextP4),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const Spacer(),
                                                                        Text(
                                                                          " - °C"
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              color: colorTextP2,
                                                                              fontSize: 27),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              SvgPicture.asset(
                                                                "icon/humidity.svg",
                                                                color:
                                                                    colorTextP3,
                                                                height: 40,
                                                              ),
                                                              SizedBox(
                                                                width: 130,
                                                                child: Card(
                                                                  elevation: 5,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  color:
                                                                      colorTextP3,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            2.0),
                                                                    child: Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              55,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              SensorName(sensorID: sensorID),
                                                                              Row(
                                                                                children: const [
                                                                                  Icon(
                                                                                    Icons.schedule_outlined,
                                                                                    size: 15,
                                                                                    color: colorTextP4,
                                                                                  ),
                                                                                  Text(
                                                                                    ' - ',
                                                                                    style: TextStyle(color: colorTextP4),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const Spacer(),
                                                                        Text(
                                                                          " - %"
                                                                              .toString(),
                                                                          style: const TextStyle(
                                                                              color: colorTextP2,
                                                                              fontSize: 27),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                              );
                                      }
                                      //===============================end================================

                                      return sensorIdInCabinet.length == 1
                                          ? SizedBox(
                                              height: 140,
                                              child: ListView.builder(
                                                  itemCount: snapshot
                                                      .data!.docs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    bool temRed = false;
                                                    bool humRed = false;

                                                    if (snapshot.data!
                                                                .docs[index]
                                                                .get(
                                                                    'temperature') >=
                                                            temperatureMax ||
                                                        snapshot.data!.docs[0].get(
                                                                'temperature') <=
                                                            temperatureMin) {
                                                      notification();
                                                      _stopFile();
                                                      temRed = true;
                                                    }
                                                    if (snapshot.data!.docs[0]
                                                            .get('humidity') >=
                                                        humidityMax) {
                                                      notification();
                                                      _stopFile();
                                                      humRed = true;
                                                    }
                                                    Timestamp time = snapshot
                                                        .data!.docs[0]
                                                        .get('time');

                                                    return Column(
                                                      children: [
                                                        const SizedBox(
                                                            height: 10),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                              "icon/temperature.svg",
                                                              color: temRed ==
                                                                      false
                                                                  ? cabinetGreen1
                                                                  : cabinetRed,
                                                              height: 70,
                                                            ),
                                                            SizedBox(
                                                              height: 110,
                                                              width: 100,
                                                              child: Card(
                                                                elevation: 10,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15)),
                                                                color: temRed ==
                                                                        false
                                                                    ? cabinetGreen2
                                                                    : cabinetRed,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          5.0),
                                                                  child: Column(
                                                                    children: [
                                                                      SensorName(
                                                                          sensorID:
                                                                              sensorID),
                                                                      Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.schedule_outlined,
                                                                            size:
                                                                                16,
                                                                            color:
                                                                                colorTextP4,
                                                                          ),
                                                                          Text(
                                                                            formatTime.format(time.toDate()),
                                                                            style:
                                                                                const TextStyle(color: colorTextP4),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Text(
                                                                        "${snapshot.data!.docs[0].get('temperature').toStringAsFixed(0)}°C"
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                colorTextP2,
                                                                            fontSize:
                                                                                40),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            SvgPicture.asset(
                                                              "icon/humidity.svg",
                                                              color: humRed ==
                                                                      false
                                                                  ? cabinetGreen1
                                                                  : cabinetRed,
                                                              height: 70,
                                                            ),
                                                            SizedBox(
                                                              height: 110,
                                                              width: 100,
                                                              child: Card(
                                                                elevation: 10,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15)),
                                                                color: humRed ==
                                                                        false
                                                                    ? cabinetGreen2
                                                                    : cabinetRed,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          5.0),
                                                                  child: Column(
                                                                    children: [
                                                                      SensorName(
                                                                          sensorID:
                                                                              sensorID),
                                                                      Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.schedule_outlined,
                                                                            size:
                                                                                16,
                                                                            color:
                                                                                colorTextP4,
                                                                          ),
                                                                          Text(
                                                                            formatTime.format(time.toDate()),
                                                                            style:
                                                                                const TextStyle(color: colorTextP4),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Text(
                                                                        "${snapshot.data!.docs[0].get('humidity').toStringAsFixed(0)}%"
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                colorTextP2,
                                                                            fontSize:
                                                                                40),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            ) // กรณีที่มีเซนเซอร์มากกว่า 1 ===================================================
                                          : SizedBox(
                                              height: 50,
                                              child: ListView.builder(
                                                  itemCount: snapshot
                                                      .data!.docs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    bool temRed = false;
                                                    bool humRed = false;

                                                    if (snapshot.data!
                                                                .docs[index]
                                                                .get(
                                                                    'temperature') >=
                                                            temperatureMax ||
                                                        snapshot.data!
                                                                .docs[index]
                                                                .get(
                                                                    'temperature') <=
                                                            temperatureMin) {
                                                      notification();
                                                      _stopFile();
                                                      temRed = true;
                                                    }
                                                    if (snapshot
                                                            .data!.docs[index]
                                                            .get('humidity') >=
                                                        humidityMax) {
                                                      notification();
                                                      _stopFile();
                                                      humRed = true;
                                                    }
                                                    Timestamp time = snapshot
                                                        .data!.docs[index]
                                                        .get('time');

                                                    return Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                              "icon/temperature.svg",
                                                              color: temRed ==
                                                                      false
                                                                  ? cabinetGreen1
                                                                  : cabinetRed,
                                                              height: 40,
                                                            ),
                                                            SizedBox(
                                                              width: 130,
                                                              child: Card(
                                                                elevation: 5,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                color: temRed ==
                                                                        false
                                                                    ? cabinetGreen2
                                                                    : cabinetRed,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            55,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            SensorName(sensorID: sensorID),
                                                                            Row(
                                                                              children: [
                                                                                const Icon(
                                                                                  Icons.schedule_outlined,
                                                                                  size: 15,
                                                                                  color: colorTextP4,
                                                                                ),
                                                                                Text(
                                                                                  formatTime.format(time.toDate()),
                                                                                  style: const TextStyle(color: colorTextP4),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const Spacer(),
                                                                      Text(
                                                                        "${snapshot.data!.docs[index].get('temperature').toStringAsFixed(0)}°C"
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                colorTextP2,
                                                                            fontSize:
                                                                                27),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            SvgPicture.asset(
                                                              "icon/humidity.svg",
                                                              color: humRed ==
                                                                      false
                                                                  ? cabinetGreen1
                                                                  : cabinetRed,
                                                              height: 40,
                                                            ),
                                                            SizedBox(
                                                              width: 130,
                                                              child: Card(
                                                                elevation: 5,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                color: humRed ==
                                                                        false
                                                                    ? cabinetGreen2
                                                                    : cabinetRed,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            55,
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            SensorName(sensorID: sensorID),
                                                                            Row(
                                                                              children: [
                                                                                const Icon(
                                                                                  Icons.schedule_outlined,
                                                                                  size: 15,
                                                                                  color: colorTextP4,
                                                                                ),
                                                                                Text(
                                                                                  formatTime.format(time.toDate()),
                                                                                  style: const TextStyle(color: colorTextP4),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const Spacer(),
                                                                      Text(
                                                                        "${snapshot.data!.docs[index].get('humidity').toStringAsFixed(0)}%"
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                colorTextP2,
                                                                            fontSize:
                                                                                27),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            );
                                    });
                              },
                            ),
                          )
                        : SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("ไม่มีเซนเซอร์",
                                    style: TextStyle(
                                      color: colorPriority5,
                                    )),
                                Text("no sensor",
                                    style: TextStyle(
                                      color: colorPriority5,
                                    )),
                              ],
                            ),
                          )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SensorName extends StatelessWidget {
  SensorName({
    Key? key,
    required this.sensorID,
  }) : super(key: key);
  final String sensorID;

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream =
        FirebaseFirestore.instance
            .collection('sensors')
            .doc(sensorID)
            .snapshots();
    return StreamBuilder(
        stream: documentStream,
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          return Row(
            children: [
              const Icon(
                Icons.memory_outlined,
                color: colorTextP4,
                size: 15,
              ),
              Text(snapshot.data!.get('name'),
                  style: const TextStyle(color: colorTextP4), maxLines: 1),
            ],
          );
        });
  }
}
