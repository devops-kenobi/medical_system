import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_temperature_humidity_system/model/graph.dart';
import 'package:flutter_temperature_humidity_system/responsive.dart';
import 'package:flutter_temperature_humidity_system/screens/components/provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../constants.dart';

class BodyDetellsCabinet extends StatefulWidget {
  BodyDetellsCabinet({Key? key}) : super(key: key);

  @override
  _BodyDetellsCabinetState createState() => _BodyDetellsCabinetState();
}

class _BodyDetellsCabinetState extends State<BodyDetellsCabinet> {
  @override
  Widget build(BuildContext context) {
    // var provider = Provider.of<ProviderStatus>(context);
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    return Container(
      height: sizePageHeight * 0.91,
      width: sizePageWidth,
      decoration: const BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: SingleChildScrollView(
        child: Column(
          children: const [
            ShowGraph(),
          ],
        ),
      ),
    );
  }
}

class ShowGraph extends StatefulWidget {
  const ShowGraph({Key? key}) : super(key: key);

  @override
  State<ShowGraph> createState() => _ShowGraphState();
}

class _ShowGraphState extends State<ShowGraph> {
  final play = AudioCache();
  final player = AudioPlayer();
  final _controllerGraph = ScrollController();
  final _controllerTem = ScrollController();
  final _controllerListDataDesktop = ScrollController();
  final _controllerListDataTablet = ScrollController();
  final _heightGraph = 480.0;
  double sizeBoxResDataalot = 175;

  void notification() async {
    await play.play('/sound/notification.wav');
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProviderStatus>(context);
    double sizePageWidth = MediaQuery.of(context).size.width;
    double sizePageHeight = MediaQuery.of(context).size.height;
    var formatDateTime = DateFormat('yyyy/MM/dd HH:mm');
    var formatDate = DateFormat('yyyy-MM-dd');
    var formatTime = DateFormat('HH:mm');
    final sizeBoxInfoSensor = sizePageWidth * 0.45;
    final _heightTem = sizeBoxInfoSensor / 2.1;
    final _widthListDataDesktop = (sizePageWidth * 0.36) * 0.85;
    final _widthListDataTablet = (sizePageWidth * 0.5) * 0.90;

    _animateTemToIndex(i) => _controllerTem.animateTo(_heightTem * i,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);

    _animateGarphToIndex(i) => _controllerGraph.animateTo(_heightGraph * i,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);

    _animateListDataDesktop(i) =>
        _controllerListDataDesktop.animateTo(_widthListDataDesktop * i,
            duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);

    _animateListDataDesktopAlot(i) =>
        _controllerListDataDesktop.animateTo(sizeBoxResDataalot * i,
            duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);

    _animateListDataTablet(i) =>
        _controllerListDataTablet.animateTo(_widthListDataTablet * i,
            duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);

    _animateListDataTabletAlot(i) =>
        _controllerListDataTablet.animateTo(sizeBoxResDataalot * i,
            duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);

    Map<String, String> sensorName = {};
    FirebaseFirestore.instance
        .collection('sensors')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        sensorName.putIfAbsent(doc.id, () => doc["name"]);
      }
    });
//--------------------------------------------------------------------------------------------------------------------------------------
// ในส่วนนี้เป็นโค้ดของการรวมข้อมูลเซนเซอร์ในตู้ยามาพอร์ตกราฟแต่เนื่องจากตัว dependencies "syncfusion_flutter_charts"
//ไม่รองรับ Data Structure ประเภท Map ทำให้ใช้โค้ดส่วนนี้ไม่ได้ 😅 ผมจึงแก้ไขเฉพาะหน้าไปก่อนโดยใช้โค้ดด้านล่าง ⬇️⬇
// get data for Compare the performance of all sensors.
    // Map<String, List<Graph>> TempAllInCabinet = {};
    // Map<String, List<Graph>> humiAllInCabinet = {};
    // for (int i = 0; i < provider.getSensorIdInCabinet().length; i++) {
    //   List<Graph> dataHumi = [];
    //   List<Graph> dataTemp = [];
    //   FirebaseFirestore.instance
    //       .collection('sensors')
    //       .doc(provider.getSensorIdInCabinet()[i].toString())
    //       .collection('list_data')
    //       .get()
    //       .then((QuerySnapshot querySnapshot) {
    //     for (var doc in querySnapshot.docs) {
    //       Timestamp time = doc["time"];

    //       Graph dataT = Graph(value: doc["temperature"], dateTime: time);
    //       dataTemp.add(dataT);
    //       Graph dataH = Graph(value: doc["humidity"], dateTime: time);
    //       dataHumi.add(dataH);
    //     }

    //     TempAllInCabinet.putIfAbsent(
    //         provider.getSensorIdInCabinet()[i].toString(), () => dataTemp);

    //     humiAllInCabinet.putIfAbsent(
    //         provider.getSensorIdInCabinet()[i].toString(), () => dataHumi);
    //   });
    // }

    // print(TempAllInCabinet['B0bYihpaYBTf5vHTVY4e']);
    //--------------------------------------------------------------------------------------------------------------------------------------

    //--------------------------------------------------------------------------------------------------------------------------------------
    //เนื่องด้วย dependencies "syncfusion_flutter_charts" ยังไม่รองรับ Data Structure ประเภท Map จึงต้องใช้โค้ดส่วนล่างไปก่อน

    List<Graph> dataTemp1 = [];
    List<Graph> dataHumi1 = [];
    if (provider.getSensorIdInCabinet().isNotEmpty) {
      FirebaseFirestore.instance
          .collection('sensors')
          .doc(provider.getSensorIdInCabinet()[0].toString())
          .collection('list_data')
          .orderBy('time', descending: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          Timestamp time = doc["time"];
          Graph dataT = Graph(value: doc["temperature"], dateTime: time);
          dataTemp1.add(dataT);
          Graph dataH = Graph(value: doc["humidity"], dateTime: time);
          dataHumi1.add(dataH);
        }
      });
    }

    List<Graph> dataTemp2 = [];
    List<Graph> dataHumi2 = [];
    if (provider.getSensorIdInCabinet().length >= 2) {
      FirebaseFirestore.instance
          .collection('sensors')
          .doc(provider.getSensorIdInCabinet()[1].toString())
          .collection('list_data')
          .orderBy('time', descending: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          Timestamp time = doc["time"];
          Graph dataT = Graph(value: doc["temperature"], dateTime: time);
          dataTemp2.add(dataT);
          Graph dataH = Graph(value: doc["humidity"], dateTime: time);
          dataHumi2.add(dataH);
        }
      });
    }
    List<Graph> dataTemp3 = [];
    List<Graph> dataHumi3 = [];
    if (provider.getSensorIdInCabinet().length >= 3) {
      FirebaseFirestore.instance
          .collection('sensors')
          .doc(provider.getSensorIdInCabinet()[2].toString())
          .collection('list_data')
          .orderBy('time', descending: false)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          Timestamp time = doc["time"];
          Graph dataT = Graph(value: doc["temperature"], dateTime: time);
          dataTemp3.add(dataT);
          Graph dataH = Graph(value: doc["humidity"], dateTime: time);
          dataHumi3.add(dataH);
        }
      });
    }

    //--------------------------------------------------------------------------------------------------------------------------------------
    Future<void> showDialogConclusion() {
      bool resTempAndHumi = true;
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                // backgroundColor: secondaryColor,
                title: Row(
                  children: [
                    resTempAndHumi == true
                        ? SvgPicture.asset(
                            "assets/icons/temperature.svg",
                            color: colorTextP3,
                            height: 40,
                          )
                        : SvgPicture.asset(
                            "assets/icons/humidity.svg",
                            color: colorTextP3,
                            height: 40,
                          ),
                    resTempAndHumi == true
                        ? const Text(
                            '°C',
                            style: TextStyle(color: colorTextP3, fontSize: 20),
                          )
                        : const Text(
                            '%',
                            style: TextStyle(color: colorTextP3, fontSize: 20),
                          ),
                    // resTempAndHumi == true
                    //     ? const Text(
                    //         ' ข้อมูลเซนเซอร์ อุณหภูมิ',
                    //         style: TextStyle(color: colorTextP3),
                    //       )
                    //     : const Text(
                    //         ' ข้อมูลเซนเซอร์ ความชื้น',
                    //         style: TextStyle(color: colorTextP3),
                    //       ),
                    const Spacer(),
                    SizedBox(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            color: colorTextP3,
                            size: 20,
                          ),
                          Text(
                            provider.getCabinetName(),
                            style: const TextStyle(
                                color: colorTextP3, fontSize: 13),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          SvgPicture.asset(
                            "assets/icons/temMax.svg",
                            color: colorTextP3,
                            height: 17,
                          ),
                          Text(
                            "${provider.getTemperatureMax()}°C".toString(),
                            style: const TextStyle(
                                color: colorTextP3, fontSize: 13),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          SvgPicture.asset(
                            "assets/icons/temMin.svg",
                            color: colorTextP3,
                            height: 17,
                          ),
                          Text(
                            "${provider.getTemperatureMin()}°C".toString(),
                            style: const TextStyle(
                                color: colorTextP3, fontSize: 13),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          SvgPicture.asset(
                            "assets/icons/humidityMax.svg",
                            color: colorTextP3,
                            height: 17,
                          ),
                          Text(
                            "${provider.getHumidityMax()}%".toString(),
                            style: const TextStyle(
                                color: colorTextP3, fontSize: 13),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                content: Column(
                  children: [
                    if (resTempAndHumi == true)
                      SizedBox(
                          // Graph temperature all =====
                          height: 500,
                          width: sizePageWidth,
                          child: Card(
                            color: Colors.white,
                            child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              primaryYAxis: NumericAxis(
                                labelFormat: '{value}°C',
                              ),

                              // Enable legend
                              legend: Legend(isVisible: true),
                              // legend: Legend(
                              //     isVisible: true,
                              //     offset: const Offset(0, 0)),
                              // Enable tooltip
                              tooltipBehavior: TooltipBehavior(enable: true),
                              crosshairBehavior: CrosshairBehavior(
                                lineType: CrosshairLineType
                                    .horizontal, //Horizontal selection indicator
                                enable: true,
                                shouldAlwaysShow:
                                    false, //The cross is always displayed (horizontal selection indicator)
                                activationMode: ActivationMode.singleTap,
                              ),
                              //Track the ball
                              trackballBehavior: TrackballBehavior(
                                lineType: TrackballLineType
                                    .vertical, //Vertical selection indicator
                                activationMode: ActivationMode.singleTap,
                                enable: true,
                                tooltipAlignment: ChartAlignment
                                    .near, //Tooltip position (top)
                                shouldAlwaysShow:
                                    true, //Track ball is always displayed (vertical selection indicator)
                                tooltipDisplayMode: TrackballDisplayMode
                                    .groupAllPoints, //Tool tip mode (group all)
                              ),
                              series: <ChartSeries<Graph, String>>[
                                if (provider.getSensorIdInCabinet().isNotEmpty)
                                  SplineSeries<Graph, String>(
                                    dataSource: dataTemp1,
                                    xValueMapper: (Graph sales, _) =>
                                        formatDateTime
                                            .format(sales.dateTime.toDate()),
                                    yValueMapper: (Graph sales, _) =>
                                        sales.value,
                                    name: sensorName[
                                        provider.getSensorIdInCabinet()[0]],
                                    width: 1,
                                    color: colorGraph1,
                                    // markerSettings: const MarkerSettings(
                                    //     isVisible: true, color: colorSensorTem),
                                    // dataLabelSettings: const DataLabelSettings(
                                    //   isVisible: true,
                                    //   color: colorSensorTem,
                                    // )
                                  ),
                                if (provider.getSensorIdInCabinet().length >= 2)
                                  SplineSeries<Graph, String>(
                                    dataSource: dataTemp2,
                                    xValueMapper: (Graph sales, _) =>
                                        formatDateTime
                                            .format(sales.dateTime.toDate()),
                                    yValueMapper: (Graph sales, _) =>
                                        sales.value,
                                    name: sensorName[
                                        provider.getSensorIdInCabinet()[1]],
                                    width: 1,
                                    color: colorGraph2,
                                    // markerSettings: const MarkerSettings(
                                    //     isVisible: true, color: colorSensor),
                                    // dataLabelSettings: const DataLabelSettings(
                                    //   isVisible: true,
                                    //   color: colorSensor,
                                    // )
                                  ),
                                if (provider.getSensorIdInCabinet().length >= 3)
                                  SplineSeries<Graph, String>(
                                    dataSource: dataTemp3,
                                    xValueMapper: (Graph sales, _) =>
                                        formatDateTime
                                            .format(sales.dateTime.toDate()),
                                    yValueMapper: (Graph sales, _) =>
                                        sales.value,
                                    name: sensorName[
                                        provider.getSensorIdInCabinet()[2]],
                                    width: 1,
                                    color: colorGraph3,
                                    // markerSettings: const MarkerSettings(
                                    //     isVisible: true, color: colorSensor),
                                    // dataLabelSettings: const DataLabelSettings(
                                    //   isVisible: true,
                                    //   color: colorSensor,
                                    // )
                                  ),
                              ],
                            ),
                          )),
                    if (resTempAndHumi == false)
                      SizedBox(
                          // Graph humidity all =====
                          height: 500,
                          width: sizePageWidth,
                          child: Card(
                            color: Colors.white,
                            child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              primaryYAxis: NumericAxis(
                                labelFormat: '{value}%',
                              ),

                              // Enable legend
                              legend: Legend(isVisible: true),
                              // legend: Legend(
                              //     isVisible: true,
                              //     offset: const Offset(0, 0)),
                              // Enable tooltip
                              tooltipBehavior: TooltipBehavior(enable: true),
                              crosshairBehavior: CrosshairBehavior(
                                lineType: CrosshairLineType
                                    .horizontal, //Horizontal selection indicator
                                enable: true,
                                shouldAlwaysShow:
                                    false, //The cross is always displayed (horizontal selection indicator)
                                activationMode: ActivationMode.singleTap,
                              ),
                              //Track the ball
                              trackballBehavior: TrackballBehavior(
                                lineType: TrackballLineType
                                    .vertical, //Vertical selection indicator
                                activationMode: ActivationMode.singleTap,
                                enable: true,
                                tooltipAlignment: ChartAlignment
                                    .near, //Tooltip position (top)
                                shouldAlwaysShow:
                                    true, //Track ball is always displayed (vertical selection indicator)
                                tooltipDisplayMode: TrackballDisplayMode
                                    .groupAllPoints, //Tool tip mode (group all)
                              ),
                              series: <ChartSeries<Graph, String>>[
                                if (provider.getSensorIdInCabinet().isNotEmpty)
                                  SplineSeries<Graph, String>(
                                    dataSource: dataHumi1,
                                    xValueMapper: (Graph sales, _) =>
                                        formatDateTime
                                            .format(sales.dateTime.toDate()),
                                    yValueMapper: (Graph sales, _) =>
                                        sales.value,
                                    name: sensorName[
                                        provider.getSensorIdInCabinet()[0]],
                                    width: 1,
                                    color: colorGraph1,
                                    // markerSettings: const MarkerSettings(
                                    //     isVisible: true, color: colorSensorTem),
                                    // dataLabelSettings: const DataLabelSettings(
                                    //   isVisible: true,
                                    //   color: colorSensorTem,
                                    // )
                                  ),
                                if (provider.getSensorIdInCabinet().length >= 2)
                                  SplineSeries<Graph, String>(
                                    dataSource: dataHumi2,
                                    xValueMapper: (Graph sales, _) =>
                                        formatDateTime
                                            .format(sales.dateTime.toDate()),
                                    yValueMapper: (Graph sales, _) =>
                                        sales.value,
                                    name: sensorName[
                                        provider.getSensorIdInCabinet()[1]],
                                    width: 1,
                                    color: colorGraph2,
                                    // markerSettings: const MarkerSettings(
                                    //     isVisible: true, color: colorSensor),
                                    // dataLabelSettings: const DataLabelSettings(
                                    //   isVisible: true,
                                    //   color: colorSensor,
                                    // )
                                  ),
                                if (provider.getSensorIdInCabinet().length >= 3)
                                  SplineSeries<Graph, String>(
                                    dataSource: dataHumi3,
                                    xValueMapper: (Graph sales, _) =>
                                        formatDateTime
                                            .format(sales.dateTime.toDate()),
                                    yValueMapper: (Graph sales, _) =>
                                        sales.value,
                                    name: sensorName[
                                        provider.getSensorIdInCabinet()[2]],
                                    width: 1,
                                    color: colorGraph3,
                                    // markerSettings: const MarkerSettings(
                                    //     isVisible: true, color: colorSensor),
                                    // dataLabelSettings: const DataLabelSettings(
                                    //   isVisible: true,
                                    //   color: colorSensor,
                                    // )
                                  ),
                              ],
                            ),
                          )),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            resTempAndHumi = !resTempAndHumi;
                          });
                        },
                        child: resTempAndHumi == true
                            ? const Text('ความชื้น')
                            : const Text('อุณหภูมิ')),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text('ตกลง'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          });
        },
      );
    }

    return Column(
      children: [
        SizedBox(
          // part 1 :=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:
          width: double.infinity,
          height: 480,
          child: ListView.builder(
              controller: _controllerGraph,
              itemCount: provider.getSensorIdInCabinet().length,
              itemBuilder: (context, index) {
                final Stream<QuerySnapshot> cabinetDetells = FirebaseFirestore
                    .instance
                    .collection('sensors')
                    .doc(provider.getSensorIdInCabinet()[index])
                    .collection('list_data')
                    .orderBy("time", descending: false)
                    .limitToLast(10)
                    .snapshots();

                return StreamBuilder(
                    stream: cabinetDetells,
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      try {
                        // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                        // แก้ไขโดยใช้ try catch คุม

                        if (snapshot.hasError) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Loading");
                          }
                          return Column(
                            children: [
                              SizedBox(
                                  height: 280,
                                  width: double.infinity,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Colors.white,
                                    child: const Center(
                                        child: Text(
                                      'Something went wrong',
                                      style: TextStyle(color: Colors.red),
                                    )),
                                  )),
                              SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Colors.white,
                                    child: const Center(
                                        child: Text(
                                      'Something went wrong',
                                      style: TextStyle(color: Colors.red),
                                    )),
                                  )),
                            ],
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            children: [
                              SizedBox(
                                  height: 280,
                                  width: double.infinity,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Colors.white,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  )),
                              SizedBox(
                                  height: 200,
                                  width: double.infinity,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: Colors.white,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  )),
                            ],
                          );
                        }

                        List<Graph> dataHumidity = [];
                        for (int i = 0; i < snapshot.data!.docs.length; i++) {
                          Timestamp time = snapshot.data!.docs[i].get('time');
                          Graph info = Graph(
                              value: snapshot.data!.docs[i].get('humidity'),
                              dateTime: time);
                          dataHumidity.add(info);
                        }
                        List<Graph> dataTemperature = [];
                        for (int i = 0; i < snapshot.data!.docs.length; i++) {
                          Timestamp time = snapshot.data!.docs[i].get('time');
                          Graph info = Graph(
                              value: snapshot.data!.docs[i].get('temperature'),
                              dateTime: time);
                          dataTemperature.add(info);
                        }

                        String lastDatetime = formatDate
                            .format(dataHumidity.last.dateTime.toDate());

                        List<Graph> humidityMax = [];
                        List<Graph> temperatureMax = [];
                        List<Graph> temperatureMin = [];
                        Timestamp firstTime =
                            snapshot.data!.docs.first.get('time');
                        Timestamp lastTime =
                            snapshot.data!.docs.last.get('time');
                        // set line Temperature Max and Min -----------------------------------
                        Graph firetInfoTemMax = Graph(
                            value: provider.getTemperatureMax(),
                            dateTime: firstTime);
                        Graph lastInfoTemMax = Graph(
                            value: provider.getTemperatureMax(),
                            dateTime: lastTime);
                        temperatureMax.add(firetInfoTemMax);
                        temperatureMax.add(lastInfoTemMax);

                        Graph firetInfoTemMin = Graph(
                            value: provider.getTemperatureMin(),
                            dateTime: firstTime);
                        Graph lastInfoTemMin = Graph(
                            value: provider.getTemperatureMin(),
                            dateTime: lastTime);
                        temperatureMin.add(firetInfoTemMin);
                        temperatureMin.add(lastInfoTemMin);
                        // set line Humidity Maximum ------------------------------------------
                        Graph firstInfoHum = Graph(
                            value: provider.getHumidityMax(),
                            dateTime: firstTime);
                        Graph lastInfoHum = Graph(
                            value: provider.getHumidityMax(),
                            dateTime: lastTime);
                        humidityMax.add(firstInfoHum);
                        humidityMax.add(lastInfoHum);

                        return Column(
                          children: [
                            SizedBox(
                              //Graph Temperature =======
                              height: 280,
                              width: double.infinity,
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    primaryYAxis: NumericAxis(
                                      labelFormat: '{value}°C',
                                    ),
                                    title: ChartTitle(text: lastDatetime),
                                    // Enable legend
                                    legend: Legend(isVisible: true),
                                    // legend: Legend(
                                    //     isVisible: true,
                                    //     offset: const Offset(0, 0)),
                                    // Enable tooltip
                                    tooltipBehavior:
                                        TooltipBehavior(enable: true),
                                    // crosshairBehavior: CrosshairBehavior(
                                    //   lineType: CrosshairLineType
                                    //       .horizontal, //Horizontal selection indicator
                                    //   enable: true,
                                    //   shouldAlwaysShow:
                                    //       false, //The cross is always displayed (horizontal selection indicator)
                                    //   activationMode: ActivationMode.singleTap,
                                    // ),
                                    //Track the ball
                                    // trackballBehavior: TrackballBehavior(
                                    //   lineType: TrackballLineType
                                    //       .vertical, //Vertical selection indicator
                                    //   activationMode: ActivationMode.singleTap,
                                    //   enable: true,
                                    //   tooltipAlignment: ChartAlignment
                                    //       .near, //Tooltip position (top)
                                    //   shouldAlwaysShow:
                                    //       true, //Track ball is always displayed (vertical selection indicator)
                                    //   tooltipDisplayMode: TrackballDisplayMode
                                    //       .groupAllPoints, //Tool tip mode (group all)
                                    // ),
                                    series: <ChartSeries<Graph, String>>[
                                      SplineSeries<Graph, String>(
                                          dataSource: dataTemperature,
                                          xValueMapper: (Graph sales, _) =>
                                              formatTime.format(
                                                  sales.dateTime.toDate()),
                                          yValueMapper: (Graph sales, _) =>
                                              sales.value,
                                          name: 'Temperature',
                                          width: 1,
                                          color: colorSensorTem,
                                          markerSettings: const MarkerSettings(
                                              isVisible: true,
                                              color: colorSensorTem),
                                          dataLabelSettings:
                                              const DataLabelSettings(
                                            isVisible: true,
                                            color: colorSensorTem,
                                          )),
                                      LineSeries<Graph, String>(
                                        dataSource: temperatureMax,
                                        dashArray: <double>[5, 5],
                                        xValueMapper: (Graph sales, _) =>
                                            formatTime.format(
                                                sales.dateTime.toDate()),
                                        yValueMapper: (Graph sales, _) =>
                                            sales.value,
                                        name: 'Maximum',
                                        width: 2,
                                        color: const Color(0XFFd00000),
                                      ),
                                      LineSeries<Graph, String>(
                                        dataSource: temperatureMin,
                                        dashArray: <double>[5, 5],
                                        xValueMapper: (Graph sales, _) =>
                                            formatTime.format(
                                                sales.dateTime.toDate()),
                                        yValueMapper: (Graph sales, _) =>
                                            sales.value,
                                        name: 'Minimum',
                                        width: 2,
                                        color: const Color(0XFFd00000),
                                      ),
                                    ]),
                              ),
                            ),
                            SizedBox(
                              //Graph Humidity =======
                              height: 200,
                              width: double.infinity,
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: SfCartesianChart(
                                  primaryXAxis: CategoryAxis(),
                                  primaryYAxis:
                                      NumericAxis(labelFormat: '{value}%'),
                                  title: ChartTitle(text: lastDatetime),
                                  // Enable legend
                                  legend: Legend(isVisible: true),
                                  // legend: Legend(
                                  //     isVisible: true,
                                  //     offset: const Offset(0, 0)),

                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  series: <ChartSeries<Graph, String>>[
                                    SplineSeries<Graph, String>(
                                        dataSource: dataHumidity,
                                        xValueMapper: (Graph sales, _) =>
                                            formatTime.format(
                                                sales.dateTime.toDate()),
                                        yValueMapper: (Graph sales, _) =>
                                            sales.value,
                                        name: 'Humidity',
                                        width: 1,
                                        color: colorSensorHum,
                                        markerSettings: const MarkerSettings(
                                            isVisible: true,
                                            color: colorSensorHum),
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                          isVisible: true,
                                          color: colorSensorHum,
                                        )),
                                    LineSeries<Graph, String>(
                                      dataSource: humidityMax,
                                      dashArray: <double>[5, 5],
                                      xValueMapper: (Graph sales, _) =>
                                          formatTime
                                              .format(sales.dateTime.toDate()),
                                      yValueMapper: (Graph sales, _) =>
                                          sales.value,
                                      name: 'Maximum',
                                      width: 2,
                                      color: const Color(0XFFd00000),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } catch (e) {
                        // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                        // แก้ไขโดยใช้ try catch คุม
                        return Column(
                          children: [
                            SizedBox(
                              height: 280,
                              width: double.infinity,
                              child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    primaryYAxis: NumericAxis(
                                      labelFormat: '{value}°C',
                                    ),
                                  )),
                            ),
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    primaryYAxis: NumericAxis(
                                      labelFormat: '{value}%',
                                    ),
                                  )),
                            ),
                          ],
                        );
                      }
                    });
              }),
        ),
        if (!Responsive.isMobile(context))
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                SizedBox(
                  // part 2 Responsive Desktop and Tablet :=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:
                  height: 215,
                  width: sizeBoxInfoSensor,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: provider.getSensorIdInCabinet().length > 1
                        ? //Responsive sensor > 1  ======================================================
                        Row(
                            children: [
                              Column(
                                //Temperature ------------------------------------------🌡
                                children: [
                                  SizedBox(
                                    height: 139,
                                    width: sizeBoxInfoSensor / 2.1,
                                    child: ListView.builder(
                                        controller: _controllerTem,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: provider
                                            .getSensorIdInCabinet()
                                            .length,
                                        itemBuilder: (context, index) {
                                          final Stream<
                                                  QuerySnapshot<
                                                      Map<String, dynamic>>>
                                              sensorData = FirebaseFirestore
                                                  .instance
                                                  .collection('sensors')
                                                  .doc(provider
                                                          .getSensorIdInCabinet()[
                                                      index])
                                                  .collection('list_data')
                                                  // .where('time',
                                                  //     isLessThanOrEqualTo: DateTime.now())
                                                  .orderBy("time",
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots();

                                          return StreamBuilder(
                                              stream: sensorData,
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          QuerySnapshot<
                                                              Map<String,
                                                                  dynamic>>>
                                                      snapshot) {
                                                try {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  if (snapshot.hasError) {
                                                    return const Text(
                                                        'Something went wrong',
                                                        style: TextStyle(
                                                            color: Colors.red));
                                                  }
                                                  if (snapshot
                                                      .data!.docs.isEmpty) {
                                                    return const SizedBox();
                                                  }

                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Text(
                                                      "Loading",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    );
                                                  }
                                                  Timestamp time = snapshot
                                                      .data!.docs[0]
                                                      .get('time');

                                                  bool temRed = false;
                                                  bool temYellow = false;
                                                  if (snapshot.data!.docs[0].get(
                                                              'temperature') >
                                                          provider
                                                              .getTemperatureMax() ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') <
                                                          provider
                                                              .getTemperatureMin()) {
                                                    notification();
                                                    temRed = true;
                                                    temYellow = false;
                                                  }
                                                  if (snapshot.data!.docs[0].get('temperature') == provider.getTemperatureMax() ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') ==
                                                          provider
                                                              .getTemperatureMin() ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') ==
                                                          provider.getTemperatureMax() -
                                                              1 ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') ==
                                                          provider.getTemperatureMin() -
                                                              1) {
                                                    temRed = false;
                                                    temYellow = true;
                                                  }

                                                  return SizedBox(
                                                    height: 130,
                                                    width:
                                                        sizeBoxInfoSensor / 2.1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Row(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              SizedBox(
                                                                width:
                                                                    sizeBoxInfoSensor /
                                                                        2.3,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    GetCurrentSensorName(
                                                                        index),
                                                                    const Spacer(),
                                                                    Text(
                                                                      formatDate
                                                                          .format(
                                                                              time.toDate()),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              colorTextP3),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .calendar_today,
                                                                      size: 15,
                                                                      color:
                                                                          colorTextP3,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    sizeBoxInfoSensor /
                                                                        2.3,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      formatTime
                                                                          .format(
                                                                              time.toDate()),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              colorTextP3),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .schedule_outlined,
                                                                      size: 15,
                                                                      color:
                                                                          colorTextP3,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    sizeBoxInfoSensor /
                                                                        2.2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      "assets/icons/temperature.svg",
                                                                      color: temRed ==
                                                                              true
                                                                          ? cabinetRed
                                                                          : temYellow == true
                                                                              ? cabinetOrange
                                                                              : cabinetGreen2,
                                                                      height:
                                                                          70,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      "${snapshot.data!.docs[0].get('temperature').toStringAsFixed(0)}°C"
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              colorSensorTem,
                                                                          fontSize:
                                                                              68),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  return SizedBox();
                                                }
                                              });
                                        }),
                                  ),
                                  SizedBox(
                                    height: 65,
                                    width: sizeBoxInfoSensor / 2.1,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: provider
                                            .getSensorIdInCabinet()
                                            .length,
                                        itemBuilder: (context, index) {
                                          final Stream<
                                                  QuerySnapshot<
                                                      Map<String, dynamic>>>
                                              sensorData = FirebaseFirestore
                                                  .instance
                                                  .collection('sensors')
                                                  .doc(provider
                                                          .getSensorIdInCabinet()[
                                                      index])
                                                  .collection('list_data')
                                                  // .where('time',
                                                  //     isLessThanOrEqualTo: DateTime.now())
                                                  .orderBy("time",
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots();
                                          return StreamBuilder(
                                              stream: sensorData,
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          QuerySnapshot<
                                                              Map<String,
                                                                  dynamic>>>
                                                      snapshot) {
                                                try {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  if (snapshot.hasError) {
                                                    return const Text(
                                                        'Something went wrong',
                                                        style: TextStyle(
                                                            color: Colors.red));
                                                  }

                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Text(
                                                      "Loading",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    );
                                                  }
                                                  bool temRed = false;
                                                  bool temYellow = false;
                                                  if (snapshot.data!.docs[0].get(
                                                              'temperature') >
                                                          provider
                                                              .getTemperatureMax() ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') <
                                                          provider
                                                              .getTemperatureMin()) {
                                                    notification();
                                                    temRed = true;
                                                    temYellow = false;
                                                  }
                                                  if (snapshot.data!.docs[0].get('temperature') == provider.getTemperatureMax() ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') ==
                                                          provider
                                                              .getTemperatureMin() ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') ==
                                                          provider.getTemperatureMax() -
                                                              1 ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') ==
                                                          provider.getTemperatureMin() -
                                                              1) {
                                                    temRed = false;
                                                    temYellow = true;
                                                  }

                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 40,
                                                        width: 90,
                                                        child: Card(
                                                          color: temRed == true
                                                              ? cabinetRed
                                                              : temYellow ==
                                                                      true
                                                                  ? cabinetOrange
                                                                  : cabinetDefault,
                                                          elevation: 15,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          9)),
                                                          child: InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        9),
                                                            onTap: () {
                                                              _animateGarphToIndex(
                                                                  index);
                                                              _animateTemToIndex(
                                                                  index);
                                                              if (Responsive
                                                                  .isDesktop(
                                                                      context)) {
                                                                _animateListDataDesktop(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                      .isDesktop(
                                                                          context) &&
                                                                  provider.getResDataonlyone() ==
                                                                      false) {
                                                                _animateListDataDesktopAlot(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                  .isTablet(
                                                                      context)) {
                                                                _animateListDataTablet(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                      .isTablet(
                                                                          context) &&
                                                                  provider.getResDataonlyone() ==
                                                                      false) {
                                                                _animateListDataTabletAlot(
                                                                    index);
                                                              }
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    "assets/icons/temperature.svg",
                                                                    color:
                                                                        cabinetGreen1,
                                                                    height: 40,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                    "${snapshot.data!.docs[0].get('temperature').toStringAsFixed(0)}°C"
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        color:
                                                                            colorTextP2,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      GetSensorName(index)
                                                    ],
                                                  );
                                                } catch (e) {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 40,
                                                        width: 90,
                                                        child: Card(
                                                          color: colorTextP3,
                                                          elevation: 15,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          9)),
                                                          child: InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        9),
                                                            onTap: () {
                                                              _animateGarphToIndex(
                                                                  index);
                                                              _animateTemToIndex(
                                                                  index);
                                                              if (Responsive
                                                                  .isDesktop(
                                                                      context)) {
                                                                _animateListDataDesktop(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                      .isDesktop(
                                                                          context) &&
                                                                  provider.getResDataonlyone() ==
                                                                      false) {
                                                                _animateListDataDesktopAlot(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                  .isTablet(
                                                                      context)) {
                                                                _animateListDataTablet(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                      .isTablet(
                                                                          context) &&
                                                                  provider.getResDataonlyone() ==
                                                                      false) {
                                                                _animateListDataTabletAlot(
                                                                    index);
                                                              }
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    "assets/icons/temperature.svg",
                                                                    color:
                                                                        colorTextP2,
                                                                    height: 40,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                    " - °C"
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        color:
                                                                            colorTextP2,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      GetSensorName(index)
                                                    ],
                                                  );
                                                }
                                              });
                                        }),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 170,
                                width: 2.5,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: colorTextP3,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
                              ),
                              const Spacer(),
                              Column(
                                //Humidity ----------------------------------------------------
                                children: [
                                  SizedBox(
                                    height: 139,
                                    width: sizeBoxInfoSensor / 2.1,
                                    child: ListView.builder(
                                        controller: _controllerTem,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: provider
                                            .getSensorIdInCabinet()
                                            .length,
                                        itemBuilder: (context, index) {
                                          final Stream<
                                                  QuerySnapshot<
                                                      Map<String, dynamic>>>
                                              sensorData = FirebaseFirestore
                                                  .instance
                                                  .collection('sensors')
                                                  .doc(provider
                                                          .getSensorIdInCabinet()[
                                                      index])
                                                  .collection('list_data')
                                                  // .where('time',
                                                  //     isLessThanOrEqualTo: DateTime.now())
                                                  .orderBy("time",
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots();
                                          return StreamBuilder(
                                              stream: sensorData,
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          QuerySnapshot<
                                                              Map<String,
                                                                  dynamic>>>
                                                      snapshot) {
                                                try {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  if (snapshot.hasError) {
                                                    return const Text(
                                                        'Something went wrong',
                                                        style: TextStyle(
                                                            color: Colors.red));
                                                  }
                                                  if (snapshot
                                                      .data!.docs.isEmpty) {
                                                    return const SizedBox();
                                                  }

                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Text(
                                                      "Loading",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    );
                                                  }
                                                  Timestamp time = snapshot
                                                      .data!.docs[0]
                                                      .get('time');

                                                  bool humRed = false;
                                                  bool humYellow = false;
                                                  if (snapshot.data!.docs[0]
                                                          .get('humidity') >
                                                      provider
                                                          .getHumidityMax()) {
                                                    notification();
                                                    humRed = true;
                                                    humYellow = false;
                                                  }
                                                  if (snapshot.data!.docs[0]
                                                              .get(
                                                                  'humidity') ==
                                                          provider
                                                              .getHumidityMax() ||
                                                      snapshot.data!.docs[0]
                                                              .get(
                                                                  'humidity') ==
                                                          provider.getHumidityMax() -
                                                              1) {
                                                    humRed = false;
                                                    humYellow = true;
                                                  }
                                                  return SizedBox(
                                                    height: 130,
                                                    width:
                                                        sizeBoxInfoSensor / 2.1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: SizedBox(
                                                        child: Row(
                                                          children: [
                                                            Column(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      sizeBoxInfoSensor /
                                                                          2.3,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      GetCurrentSensorName(
                                                                          index),
                                                                      const Spacer(),
                                                                      Text(
                                                                        formatDate
                                                                            .format(time.toDate()),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                colorTextP3),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            2,
                                                                      ),
                                                                      const Icon(
                                                                        Icons
                                                                            .calendar_today,
                                                                        size:
                                                                            15,
                                                                        color:
                                                                            colorTextP3,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      sizeBoxInfoSensor /
                                                                          2.3,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Text(
                                                                        formatTime
                                                                            .format(time.toDate()),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                colorTextP3),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            2,
                                                                      ),
                                                                      const Icon(
                                                                        Icons
                                                                            .schedule_outlined,
                                                                        size:
                                                                            15,
                                                                        color:
                                                                            colorTextP3,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      sizeBoxInfoSensor /
                                                                          2.2,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SvgPicture
                                                                          .asset(
                                                                        "assets/icons/humidity.svg",
                                                                        color: humRed ==
                                                                                true
                                                                            ? cabinetRed
                                                                            : humYellow == true
                                                                                ? cabinetOrange
                                                                                : cabinetGreen2,
                                                                        height:
                                                                            70,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        "${snapshot.data!.docs[0].get('humidity').toStringAsFixed(0)}%"
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                colorSensorHum,
                                                                            fontSize:
                                                                                68),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  return SizedBox();
                                                }
                                              });
                                        }),
                                  ),
                                  SizedBox(
                                    height: 65,
                                    width: sizeBoxInfoSensor / 2.1,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: provider
                                            .getSensorIdInCabinet()
                                            .length,
                                        itemBuilder: (context, index) {
                                          final Stream<
                                                  QuerySnapshot<
                                                      Map<String, dynamic>>>
                                              sensorData = FirebaseFirestore
                                                  .instance
                                                  .collection('sensors')
                                                  .doc(provider
                                                          .getSensorIdInCabinet()[
                                                      index])
                                                  .collection('list_data')
                                                  // .where('time',
                                                  //     isLessThanOrEqualTo: DateTime.now())
                                                  .orderBy("time",
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots();
                                          return StreamBuilder(
                                              stream: sensorData,
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          QuerySnapshot<
                                                              Map<String,
                                                                  dynamic>>>
                                                      snapshot) {
                                                try {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  if (snapshot.hasError) {
                                                    return const Text(
                                                        'Something went wrong',
                                                        style: TextStyle(
                                                            color: Colors.red));
                                                  }

                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Text(
                                                      "Loading",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    );
                                                  }
                                                  bool humRed = false;
                                                  bool humYellow = false;
                                                  if (snapshot.data!.docs[0]
                                                          .get('humidity') >
                                                      provider
                                                          .getHumidityMax()) {
                                                    notification();
                                                    humRed = true;
                                                    humYellow = false;
                                                  }
                                                  if (snapshot.data!.docs[0]
                                                              .get(
                                                                  'humidity') ==
                                                          provider
                                                              .getHumidityMax() ||
                                                      snapshot.data!.docs[0]
                                                              .get(
                                                                  'humidity') ==
                                                          provider.getHumidityMax() -
                                                              1) {
                                                    humRed = false;
                                                    humYellow = true;
                                                  }

                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 40,
                                                        width: 90,
                                                        child: Card(
                                                          color: humRed == true
                                                              ? cabinetRed
                                                              : humYellow ==
                                                                      true
                                                                  ? cabinetOrange
                                                                  : cabinetDefault,
                                                          elevation: 15,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          9)),
                                                          child: InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        9),
                                                            onTap: () {
                                                              _animateGarphToIndex(
                                                                  index);
                                                              _animateTemToIndex(
                                                                  index);
                                                              if (Responsive
                                                                  .isDesktop(
                                                                      context)) {
                                                                _animateListDataDesktop(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                      .isDesktop(
                                                                          context) &&
                                                                  provider.getResDataonlyone() ==
                                                                      false) {
                                                                _animateListDataDesktopAlot(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                  .isTablet(
                                                                      context)) {
                                                                _animateListDataTablet(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                      .isTablet(
                                                                          context) &&
                                                                  provider.getResDataonlyone() ==
                                                                      false) {
                                                                _animateListDataTabletAlot(
                                                                    index);
                                                              }
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    "assets/icons/humidity.svg",
                                                                    color:
                                                                        cabinetGreen1,
                                                                    height: 40,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                    "${snapshot.data!.docs[0].get('humidity').toStringAsFixed(0)}%"
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        color:
                                                                            colorTextP2,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      GetSensorName(index)
                                                    ],
                                                  );
                                                } catch (e) {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม

                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 40,
                                                        width: 90,
                                                        child: Card(
                                                          color: colorTextP3,
                                                          elevation: 15,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          9)),
                                                          child: InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        9),
                                                            onTap: () {
                                                              _animateGarphToIndex(
                                                                  index);
                                                              _animateTemToIndex(
                                                                  index);
                                                              if (Responsive
                                                                  .isDesktop(
                                                                      context)) {
                                                                _animateListDataDesktop(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                      .isDesktop(
                                                                          context) &&
                                                                  provider.getResDataonlyone() ==
                                                                      false) {
                                                                _animateListDataDesktopAlot(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                  .isTablet(
                                                                      context)) {
                                                                _animateListDataTablet(
                                                                    index);
                                                              }
                                                              if (Responsive
                                                                      .isTablet(
                                                                          context) &&
                                                                  provider.getResDataonlyone() ==
                                                                      false) {
                                                                _animateListDataTabletAlot(
                                                                    index);
                                                              }
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    "assets/icons/humidity.svg",
                                                                    color:
                                                                        colorTextP2,
                                                                    height: 40,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                    " - %"
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        color:
                                                                            colorTextP2,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      GetSensorName(index)
                                                    ],
                                                  );
                                                }
                                              });
                                        }),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : //part 2 Responsive Desktop and Tablet  sensor 1 only 😆 ==========================================================================
                        Row(
                            children: [
                              Column(
                                //Temperature ------------------------------------------🌡
                                children: [
                                  SizedBox(
                                    height: 205,
                                    width: sizeBoxInfoSensor / 2.1,
                                    child: ListView.builder(
                                        controller: _controllerTem,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: provider
                                            .getSensorIdInCabinet()
                                            .length,
                                        itemBuilder: (context, index) {
                                          final Stream<
                                                  QuerySnapshot<
                                                      Map<String, dynamic>>>
                                              sensorData = FirebaseFirestore
                                                  .instance
                                                  .collection('sensors')
                                                  .doc(provider
                                                          .getSensorIdInCabinet()[
                                                      index])
                                                  .collection('list_data')
                                                  // .where('time',
                                                  //     isLessThanOrEqualTo: DateTime.now())
                                                  .orderBy("time",
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots();

                                          return StreamBuilder(
                                              stream: sensorData,
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          QuerySnapshot<
                                                              Map<String,
                                                                  dynamic>>>
                                                      snapshot) {
                                                try {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  if (snapshot.hasError) {
                                                    return const Text(
                                                        'Something went wrong',
                                                        style: TextStyle(
                                                            color: Colors.red));
                                                  }
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Text(
                                                      "Loading",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    );
                                                  }
                                                  Timestamp time = snapshot
                                                      .data!.docs[0]
                                                      .get('time');

                                                  bool temRed = false;
                                                  bool temYellow = false;
                                                  if (snapshot.data!.docs[0].get(
                                                              'temperature') >
                                                          provider
                                                              .getTemperatureMax() ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') <
                                                          provider
                                                              .getTemperatureMin()) {
                                                    notification();
                                                    temRed = true;
                                                    temYellow = false;
                                                  }
                                                  if (snapshot.data!.docs[0].get('temperature') == provider.getTemperatureMax() ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') ==
                                                          provider
                                                              .getTemperatureMin() ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') ==
                                                          provider.getTemperatureMax() -
                                                              1 ||
                                                      snapshot.data!.docs[0].get(
                                                              'temperature') ==
                                                          provider.getTemperatureMin() -
                                                              1) {
                                                    temRed = false;
                                                    temYellow = true;
                                                  }

                                                  return SizedBox(
                                                    height: 130,
                                                    width:
                                                        sizeBoxInfoSensor / 2.1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Row(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              SizedBox(
                                                                width:
                                                                    sizeBoxInfoSensor /
                                                                        2.3,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    GetCurrentSensorName(
                                                                        index),
                                                                    const Spacer(),
                                                                    Text(
                                                                      formatDate
                                                                          .format(
                                                                              time.toDate()),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              colorTextP3),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .calendar_today,
                                                                      size: 15,
                                                                      color:
                                                                          colorTextP3,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    sizeBoxInfoSensor /
                                                                        2.3,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      formatTime
                                                                          .format(
                                                                              time.toDate()),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              colorTextP3),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .schedule_outlined,
                                                                      size: 15,
                                                                      color:
                                                                          colorTextP3,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    sizeBoxInfoSensor /
                                                                        2.2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      "assets/icons/temperature.svg",
                                                                      color: temRed ==
                                                                              true
                                                                          ? cabinetRed
                                                                          : temYellow == true
                                                                              ? cabinetOrange
                                                                              : cabinetGreen2,
                                                                      height:
                                                                          sizePageWidth *
                                                                              0.06,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      "${snapshot.data!.docs[0].get('temperature').toStringAsFixed(0)}°C"
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color:
                                                                              colorSensorTem,
                                                                          fontSize:
                                                                              sizePageWidth * 0.07),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  return const SizedBox();
                                                }
                                              });
                                        }),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 170,
                                width: 2.5,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: colorTextP3,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
                              ),
                              const Spacer(),
                              Column(
                                //Humidity ----------------------------------------------------
                                children: [
                                  SizedBox(
                                    height: 205,
                                    width: sizeBoxInfoSensor / 2.1,
                                    child: ListView.builder(
                                        controller: _controllerTem,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: provider
                                            .getSensorIdInCabinet()
                                            .length,
                                        itemBuilder: (context, index) {
                                          final Stream<
                                                  QuerySnapshot<
                                                      Map<String, dynamic>>>
                                              sensorData = FirebaseFirestore
                                                  .instance
                                                  .collection('sensors')
                                                  .doc(provider
                                                          .getSensorIdInCabinet()[
                                                      index])
                                                  .collection('list_data')
                                                  // .where('time',
                                                  //     isLessThanOrEqualTo: DateTime.now())
                                                  .orderBy("time",
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots();
                                          return StreamBuilder(
                                              stream: sensorData,
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          QuerySnapshot<
                                                              Map<String,
                                                                  dynamic>>>
                                                      snapshot) {
                                                try {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  if (snapshot.hasError) {
                                                    return const Text(
                                                        'Something went wrong',
                                                        style: TextStyle(
                                                            color: Colors.red));
                                                  }
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Text(
                                                      "Loading",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    );
                                                  }
                                                  Timestamp time = snapshot
                                                      .data!.docs[0]
                                                      .get('time');

                                                  bool humRed = false;
                                                  bool humYellow = false;
                                                  if (snapshot.data!.docs[0]
                                                          .get('humidity') >
                                                      provider
                                                          .getHumidityMax()) {
                                                    notification();
                                                    humRed = true;

                                                    humYellow = false;
                                                  }
                                                  if (snapshot.data!.docs[0]
                                                              .get(
                                                                  'humidity') ==
                                                          provider
                                                              .getHumidityMax() ||
                                                      snapshot.data!.docs[0]
                                                              .get(
                                                                  'humidity') ==
                                                          provider.getHumidityMax() -
                                                              1) {
                                                    humRed = false;
                                                    humYellow = true;
                                                  }
                                                  return SizedBox(
                                                    height: 130,
                                                    width:
                                                        sizeBoxInfoSensor / 2.1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Row(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              SizedBox(
                                                                width:
                                                                    sizeBoxInfoSensor /
                                                                        2.3,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    GetCurrentSensorName(
                                                                        index),
                                                                    Spacer(),
                                                                    Text(
                                                                      formatDate
                                                                          .format(
                                                                              time.toDate()),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              colorTextP3),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .calendar_today,
                                                                      size: 15,
                                                                      color:
                                                                          colorTextP3,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    sizeBoxInfoSensor /
                                                                        2.3,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      formatTime
                                                                          .format(
                                                                              time.toDate()),
                                                                      style: const TextStyle(
                                                                          color:
                                                                              colorTextP3),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .schedule_outlined,
                                                                      size: 15,
                                                                      color:
                                                                          colorTextP3,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    sizeBoxInfoSensor /
                                                                        2.2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      "assets/icons/humidity.svg",
                                                                      color: humRed ==
                                                                              true
                                                                          ? cabinetRed
                                                                          : humYellow == true
                                                                              ? cabinetOrange
                                                                              : cabinetGreen2,
                                                                      height:
                                                                          sizePageWidth *
                                                                              0.06,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      "${snapshot.data!.docs[0].get('humidity').toStringAsFixed(0)}%"
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color:
                                                                              colorSensorHum,
                                                                          fontSize:
                                                                              sizePageWidth * 0.07),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  // กรณีที่มีเซนเซอร์แต่ไม่มีข้อมูลจะทำให้เกิด RangeError (index): Index out of range: no indices are valid: 0
                                                  // แก้ไขโดยใช้ try catch คุม
                                                  return SizedBox();
                                                }
                                              });
                                        }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
                // part 3 :=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:
                if (Responsive.isDesktop(context))
                  SizedBox(
                    //sensor data list responsive desktop only ===============================================
                    height: 215,
                    width: sizePageWidth * 0.36,
                    child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              SizedBox(
                                  //data sensor to list ===================
                                  height: 215,
                                  width: _widthListDataDesktop,
                                  child: ListView.builder(
                                      controller: _controllerListDataDesktop,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: provider
                                          .getSensorIdInCabinet()
                                          .length,
                                      itemBuilder: (context, index) {
                                        final Stream<
                                                QuerySnapshot<
                                                    Map<String, dynamic>>>
                                            sensorData =
                                            FirebaseFirestore
                                                .instance
                                                .collection('sensors')
                                                .doc(provider
                                                        .getSensorIdInCabinet()[
                                                    index])
                                                .collection('list_data')
                                                .orderBy("time",
                                                    descending: true)
                                                .snapshots();
                                        return provider.getResDataonlyone() ==
                                                true
                                            ? Row(
                                                children: [
                                                  StreamBuilder(
                                                      stream: sensorData,
                                                      builder: (context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot<
                                                                      Map<String,
                                                                          dynamic>>>
                                                              snapshot) {
                                                        if (snapshot.hasError) {
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
                                                                color: Colors
                                                                    .white),
                                                          );
                                                        }
                                                        return SizedBox(
                                                          height: 215,
                                                          width:
                                                              _widthListDataDesktop,
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height: 30,
                                                                width:
                                                                    _widthListDataDesktop,
                                                                child: Card(
                                                                  color:
                                                                      colorPriority4,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                        width: _widthListDataDesktop *
                                                                            0.25,
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .calendar_today,
                                                                          color:
                                                                              colorTextP2,
                                                                          size:
                                                                              19,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _widthListDataDesktop *
                                                                            0.15,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .schedule,
                                                                          color:
                                                                              colorTextP2,
                                                                          size:
                                                                              21,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _widthListDataDesktop *
                                                                            0.25,
                                                                        height:
                                                                            30,
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          "assets/icons/temperature.svg",
                                                                          color:
                                                                              colorTextP2,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _widthListDataDesktop *
                                                                            0.25,
                                                                        height:
                                                                            30,
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          "assets/icons/humidity.svg",
                                                                          color:
                                                                              colorTextP2,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 165,
                                                                width:
                                                                    _widthListDataDesktop,
                                                                child: ListView(
                                                                  children: snapshot
                                                                      .data!
                                                                      .docs
                                                                      .map((DocumentSnapshot
                                                                          document) {
                                                                    Map<String,
                                                                            dynamic>
                                                                        data =
                                                                        document.data()! as Map<
                                                                            String,
                                                                            dynamic>;
                                                                    return Container(
                                                                      color: data['temperature'] > provider.getTemperatureMax() ||
                                                                              data['temperature'] < provider.getTemperatureMin() ||
                                                                              data['humidity'] > provider.getHumidityMax()
                                                                          ? colorhighlightRed
                                                                          : Colors.white,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                _widthListDataDesktop * 0.25,
                                                                            child:
                                                                                Center(
                                                                              child: Text(formatDate.format(data['time'].toDate())),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                _widthListDataDesktop * 0.15,
                                                                            child:
                                                                                Center(
                                                                              child: Text(formatTime.format(data['time'].toDate())),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                _widthListDataDesktop * 0.25,
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "${data['temperature']}°C",
                                                                                style: TextStyle(color: data['temperature'] > provider.getTemperatureMax() || data['temperature'] < provider.getTemperatureMin() ? Colors.red : Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                _widthListDataDesktop * 0.25,
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "${data['humidity']}%",
                                                                                style: TextStyle(color: data['humidity'] > provider.getHumidityMax() ? Colors.red : Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              )
                                            : //Responsive a lot ==========================
                                            Row(
                                                children: [
                                                  StreamBuilder(
                                                      stream: sensorData,
                                                      builder: (context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot<
                                                                      Map<String,
                                                                          dynamic>>>
                                                              snapshot) {
                                                        if (snapshot.hasError) {
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
                                                                color: Colors
                                                                    .white),
                                                          );
                                                        }
                                                        return SizedBox(
                                                          height: 215,
                                                          width:
                                                              sizeBoxResDataalot,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              GetCurrentSensorName(
                                                                  index),
                                                              SizedBox(
                                                                height: 30,
                                                                width:
                                                                    sizeBoxResDataalot,
                                                                child: Card(
                                                                  color:
                                                                      colorPriority4,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: sizeBoxResDataalot *
                                                                            0.25,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            const Center(
                                                                          child:
                                                                              Icon(
                                                                            Icons.schedule,
                                                                            color:
                                                                                colorTextP2,
                                                                            size:
                                                                                21,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: sizeBoxResDataalot *
                                                                            0.32,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "assets/icons/temperature.svg",
                                                                            color:
                                                                                colorTextP2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: sizeBoxResDataalot *
                                                                            0.32,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "assets/icons/humidity.svg",
                                                                            color:
                                                                                colorTextP2,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 140,
                                                                width:
                                                                    sizeBoxResDataalot,
                                                                child: ListView(
                                                                  children: snapshot
                                                                      .data!
                                                                      .docs
                                                                      .map((DocumentSnapshot
                                                                          document) {
                                                                    Map<String,
                                                                            dynamic>
                                                                        data =
                                                                        document.data()! as Map<
                                                                            String,
                                                                            dynamic>;
                                                                    return Container(
                                                                      color: data['temperature'] > provider.getTemperatureMax() ||
                                                                              data['temperature'] < provider.getTemperatureMin() ||
                                                                              data['humidity'] > provider.getHumidityMax()
                                                                          ? colorhighlightRed
                                                                          : Colors.white,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                sizeBoxResDataalot * 0.25,
                                                                            child:
                                                                                Center(
                                                                              child: Text(formatTime.format(data['time'].toDate())),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                sizeBoxResDataalot * 0.32,
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "${data['temperature']}°C",
                                                                                style: TextStyle(color: data['temperature'] > provider.getTemperatureMax() || data['temperature'] < provider.getTemperatureMin() ? Colors.red : Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                sizeBoxResDataalot * 0.32,
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "${data['humidity']}%",
                                                                                style: TextStyle(color: data['humidity'] > provider.getHumidityMax() ? Colors.red : Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              );
                                      })),
                              const Spacer(),
                              SizedBox(
                                // menu function ==============================================================
                                height: 215,
                                width: 42,
                                child: Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {});
                                        showDialogConclusion();
                                      },
                                      icon: const Icon(
                                          Icons.description_outlined,
                                          size: 24,
                                          color: colorPriority2),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          provider.setResDataonlyone(true),
                                      icon: SvgPicture.asset(
                                        "assets/icons/11.svg",
                                        color:
                                            provider.getResDataonlyone() == true
                                                ? colorPriority1
                                                : colorPriority2,
                                        height: 24,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          provider.setResDataonlyone(false),
                                      icon: SvgPicture.asset(
                                        "assets/icons/12.svg",
                                        color: provider.getResDataonlyone() ==
                                                false
                                            ? colorPriority1
                                            : colorPriority2,
                                        height: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                //sensor data list responsive tablet only =================================================================
                if (Responsive.isTablet(context))
                  SizedBox(
                      height: 215,
                      width: sizePageWidth * 0.52,
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              SizedBox(
                                  //data sensor to list ===================
                                  height: 215,
                                  width: _widthListDataTablet,
                                  child: ListView.builder(
                                      controller: _controllerListDataTablet,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: provider
                                          .getSensorIdInCabinet()
                                          .length,
                                      itemBuilder: (context, index) {
                                        final Stream<
                                                QuerySnapshot<
                                                    Map<String, dynamic>>>
                                            sensorData =
                                            FirebaseFirestore
                                                .instance
                                                .collection('sensors')
                                                .doc(provider
                                                        .getSensorIdInCabinet()[
                                                    index])
                                                .collection('list_data')
                                                .orderBy("time",
                                                    descending: true)
                                                .limit(20)
                                                .snapshots();
                                        return provider.getResDataonlyone() ==
                                                true
                                            ? Row(
                                                children: [
                                                  StreamBuilder(
                                                      stream: sensorData,
                                                      builder: (context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot<
                                                                      Map<String,
                                                                          dynamic>>>
                                                              snapshot) {
                                                        if (snapshot.hasError) {
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
                                                                color: Colors
                                                                    .white),
                                                          );
                                                        }
                                                        return SizedBox(
                                                          height: 215,
                                                          width:
                                                              _widthListDataTablet,
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height: 30,
                                                                width:
                                                                    _widthListDataTablet,
                                                                child: Card(
                                                                  color:
                                                                      colorPriority4,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                        width: _widthListDataTablet *
                                                                            0.3,
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .calendar_today,
                                                                          color:
                                                                              colorTextP2,
                                                                          size:
                                                                              19,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _widthListDataTablet *
                                                                            0.2,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .schedule,
                                                                          color:
                                                                              colorTextP2,
                                                                          size:
                                                                              21,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _widthListDataTablet *
                                                                            0.15,
                                                                        height:
                                                                            30,
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          "assets/icons/temperature.svg",
                                                                          color:
                                                                              colorTextP2,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: _widthListDataTablet *
                                                                            0.15,
                                                                        height:
                                                                            30,
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          "assets/assets/icons/humidity.svg",
                                                                          color:
                                                                              colorTextP2,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 165,
                                                                width:
                                                                    _widthListDataTablet,
                                                                child: ListView(
                                                                  children: snapshot
                                                                      .data!
                                                                      .docs
                                                                      .map((DocumentSnapshot
                                                                          document) {
                                                                    Map<String,
                                                                            dynamic>
                                                                        data =
                                                                        document.data()! as Map<
                                                                            String,
                                                                            dynamic>;
                                                                    return Container(
                                                                      color: data['temperature'] > provider.getTemperatureMax() ||
                                                                              data['temperature'] < provider.getTemperatureMin() ||
                                                                              data['humidity'] > provider.getHumidityMax()
                                                                          ? colorhighlightRed
                                                                          : Colors.white,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                _widthListDataTablet * 0.3,
                                                                            child:
                                                                                Center(
                                                                              child: Text(formatDate.format(data['time'].toDate())),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                _widthListDataTablet * 0.2,
                                                                            child:
                                                                                Center(
                                                                              child: Text(formatTime.format(data['time'].toDate())),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                _widthListDataTablet * 0.15,
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "${data['temperature']}°C",
                                                                                style: TextStyle(color: data['temperature'] > provider.getTemperatureMax() || data['temperature'] < provider.getTemperatureMin() ? Colors.red : Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                _widthListDataTablet * 0.15,
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "${data['humidity']}%",
                                                                                style: TextStyle(color: data['humidity'] > provider.getHumidityMax() ? Colors.red : Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              )
                                            : //Responsive a lot ==========================
                                            Row(
                                                children: [
                                                  StreamBuilder(
                                                      stream: sensorData,
                                                      builder: (context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot<
                                                                      Map<String,
                                                                          dynamic>>>
                                                              snapshot) {
                                                        if (snapshot.hasError) {
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
                                                                color: Colors
                                                                    .white),
                                                          );
                                                        }
                                                        return SizedBox(
                                                          height: 215,
                                                          width:
                                                              sizeBoxResDataalot,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              GetCurrentSensorName(
                                                                  index),
                                                              SizedBox(
                                                                height: 30,
                                                                width:
                                                                    sizeBoxResDataalot,
                                                                child: Card(
                                                                  color:
                                                                      colorPriority4,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: sizeBoxResDataalot *
                                                                            0.3,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            const Center(
                                                                          child:
                                                                              Icon(
                                                                            Icons.schedule,
                                                                            color:
                                                                                colorTextP2,
                                                                            size:
                                                                                21,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: sizeBoxResDataalot *
                                                                            0.3,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "assets/icons/temperature.svg",
                                                                            color:
                                                                                colorTextP2,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: sizeBoxResDataalot *
                                                                            0.3,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            "assets/icons/humidity.svg",
                                                                            color:
                                                                                colorTextP2,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 140,
                                                                width:
                                                                    sizeBoxResDataalot,
                                                                child: ListView(
                                                                  children: snapshot
                                                                      .data!
                                                                      .docs
                                                                      .map((DocumentSnapshot
                                                                          document) {
                                                                    Map<String,
                                                                            dynamic>
                                                                        data =
                                                                        document.data()! as Map<
                                                                            String,
                                                                            dynamic>;
                                                                    return Container(
                                                                      color: data['temperature'] > provider.getTemperatureMax() ||
                                                                              data['temperature'] < provider.getTemperatureMin() ||
                                                                              data['humidity'] > provider.getHumidityMax()
                                                                          ? colorhighlightRed
                                                                          : Colors.white,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                sizeBoxResDataalot * 0.3,
                                                                            child:
                                                                                Center(
                                                                              child: Text(formatTime.format(data['time'].toDate())),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                sizeBoxResDataalot * 0.3,
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "${data['temperature']}°C",
                                                                                style: TextStyle(color: data['temperature'] > provider.getTemperatureMax() || data['temperature'] < provider.getTemperatureMin() ? Colors.red : Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                sizeBoxResDataalot * 0.3,
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "${data['humidity']}%",
                                                                                style: TextStyle(color: data['humidity'] > provider.getHumidityMax() ? Colors.red : Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              );
                                      })),
                              const Spacer(),
                              SizedBox(
                                // menu function ==============================================================
                                height: 215,
                                width: 42,

                                child: Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {});
                                        showDialogConclusion();
                                      },
                                      icon: const Icon(
                                          Icons.description_outlined,
                                          size: 24,
                                          color: colorPriority2),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          provider.setResDataonlyone(true),
                                      icon: SvgPicture.asset(
                                        "assets/icons/11.svg",
                                        color:
                                            provider.getResDataonlyone() == true
                                                ? colorPriority1
                                                : colorPriority2,
                                        height: 24,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          provider.setResDataonlyone(false),
                                      icon: SvgPicture.asset(
                                        "assets/icons/12.svg",
                                        color: provider.getResDataonlyone() ==
                                                false
                                            ? colorPriority1
                                            : colorPriority2,
                                        height: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
              ],
            ),
          ),
        // part 2 Responsive Mobile only :=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
        if (Responsive.isMobile(context))
          SizedBox(
              //Responsive sensor > 1 ==================================
              height: 215,
              width: double.infinity,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Column(
                      //Temperature ------------------------------------------🌡
                      children: [
                        SizedBox(
                          height: 139,
                          width: sizePageWidth / 2.2,
                          child: ListView.builder(
                              controller: _controllerTem,
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.getSensorIdInCabinet().length,
                              itemBuilder: (context, index) {
                                final Stream<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    sensorData = FirebaseFirestore.instance
                                        .collection('sensors')
                                        .doc(provider
                                            .getSensorIdInCabinet()[index])
                                        .collection('list_data')
                                        // .where('time',
                                        //     isLessThanOrEqualTo: DateTime.now())
                                        .orderBy("time", descending: true)
                                        .limit(1)
                                        .snapshots();

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
                                      Timestamp time =
                                          snapshot.data!.docs[0].get('time');

                                      bool temRed = false;
                                      bool temYellow = false;
                                      if (snapshot.data!.docs[0]
                                                  .get('temperature') >
                                              provider.getTemperatureMax() ||
                                          snapshot.data!.docs[0]
                                                  .get('temperature') <
                                              provider.getTemperatureMin()) {
                                        notification();
                                        temRed = true;
                                        temYellow = false;
                                      }
                                      if (snapshot.data!.docs[0]
                                                  .get('temperature') ==
                                              provider.getTemperatureMax() ||
                                          snapshot.data!.docs[0]
                                                  .get('temperature') ==
                                              provider.getTemperatureMin() ||
                                          snapshot.data!.docs[0]
                                                  .get('temperature') ==
                                              provider.getTemperatureMax() -
                                                  1 ||
                                          snapshot.data!.docs[0]
                                                  .get('temperature') ==
                                              provider.getTemperatureMin() -
                                                  1) {
                                        temRed = false;
                                        temYellow = true;
                                      }
                                      return SizedBox(
                                        height: 130,
                                        width: sizePageWidth / 2.1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            children: [
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    width: sizePageWidth / 2.3,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        GetCurrentSensorName(
                                                            index),
                                                        const Spacer(),
                                                        Text(
                                                          formatDate.format(
                                                              time.toDate()),
                                                          style: const TextStyle(
                                                              color:
                                                                  colorTextP3),
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        const Icon(
                                                          Icons.calendar_today,
                                                          size: 15,
                                                          color: colorTextP3,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: sizePageWidth / 2.3,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          formatTime.format(
                                                              time.toDate()),
                                                          style: const TextStyle(
                                                              color:
                                                                  colorTextP3),
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        const Icon(
                                                          Icons
                                                              .schedule_outlined,
                                                          size: 15,
                                                          color: colorTextP3,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: sizePageWidth / 2.2,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/temperature.svg",
                                                          color: temRed == true
                                                              ? cabinetRed
                                                              : temYellow ==
                                                                      true
                                                                  ? cabinetOrange
                                                                  : cabinetGreen2,
                                                          height: 70,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          "${snapshot.data!.docs[0].get('temperature').toStringAsFixed(0)}°C"
                                                              .toString(),
                                                          style: const TextStyle(
                                                              color:
                                                                  colorSensorTem,
                                                              fontSize: 68),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              }),
                        ),
                        if (provider.getSensorIdInCabinet().length > 1)
                          SizedBox(
                            height: 65,
                            width: sizePageWidth / 2.1,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    provider.getSensorIdInCabinet().length,
                                itemBuilder: (context, index) {
                                  final Stream<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      sensorData = FirebaseFirestore.instance
                                          .collection('sensors')
                                          .doc(provider
                                              .getSensorIdInCabinet()[index])
                                          .collection('list_data')
                                          // .where('time',
                                          //     isLessThanOrEqualTo: DateTime.now())
                                          .orderBy("time", descending: true)
                                          .limit(1)
                                          .snapshots();
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          );
                                        }
                                        bool temRed = false;
                                        bool temYellow = false;
                                        if (snapshot.data!.docs[0]
                                                    .get('temperature') >
                                                provider.getTemperatureMax() ||
                                            snapshot.data!.docs[0]
                                                    .get('temperature') <
                                                provider.getTemperatureMin()) {
                                          notification();
                                          temRed = true;
                                          temYellow = false;
                                        }
                                        if (snapshot.data!.docs[0]
                                                    .get('temperature') ==
                                                provider.getTemperatureMax() ||
                                            snapshot.data!.docs[0]
                                                    .get('temperature') ==
                                                provider.getTemperatureMin() ||
                                            snapshot.data!.docs[0]
                                                    .get('temperature') ==
                                                provider.getTemperatureMax() -
                                                    1 ||
                                            snapshot.data!.docs[0]
                                                    .get('temperature') ==
                                                provider.getTemperatureMin() -
                                                    1) {
                                          temRed = false;
                                          temYellow = true;
                                        }
                                        return Column(
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              width: 90,
                                              child: Card(
                                                color: temRed == true
                                                    ? cabinetRed
                                                    : temYellow == true
                                                        ? cabinetOrange
                                                        : cabinetDefault,
                                                elevation: 15,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9)),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                  onTap: () {
                                                    _animateGarphToIndex(index);
                                                    _animateTemToIndex(index);
                                                    if (Responsive.isDesktop(
                                                        context)) {
                                                      _animateListDataDesktop(
                                                          index);
                                                    }
                                                    if (Responsive.isDesktop(
                                                            context) &&
                                                        provider.getResDataonlyone() ==
                                                            false) {
                                                      _animateListDataDesktopAlot(
                                                          index);
                                                    }
                                                    if (Responsive.isTablet(
                                                        context)) {
                                                      _animateListDataTablet(
                                                          index);
                                                    }
                                                    if (Responsive.isTablet(
                                                            context) &&
                                                        provider.getResDataonlyone() ==
                                                            false) {
                                                      _animateListDataTabletAlot(
                                                          index);
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/temperature.svg",
                                                          color: cabinetGreen1,
                                                          height: 40,
                                                        ),
                                                        const SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          "${snapshot.data!.docs[0].get('temperature').toStringAsFixed(0)}°C"
                                                              .toString(),
                                                          style: const TextStyle(
                                                              color:
                                                                  colorTextP2,
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GetSensorName(index)
                                          ],
                                        );
                                      });
                                }),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 170,
                      width: 2.5,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: colorTextP3,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      //Humidity ------------------------------------------------
                      children: [
                        SizedBox(
                          height: 139,
                          width: sizePageWidth / 2.2,
                          child: ListView.builder(
                              controller: _controllerTem,
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.getSensorIdInCabinet().length,
                              itemBuilder: (context, index) {
                                final Stream<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    sensorData = FirebaseFirestore.instance
                                        .collection('sensors')
                                        .doc(provider
                                            .getSensorIdInCabinet()[index])
                                        .collection('list_data')
                                        // .where('time',
                                        //     isLessThanOrEqualTo: DateTime.now())
                                        .orderBy("time", descending: true)
                                        .limit(1)
                                        .snapshots();
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
                                      Timestamp time =
                                          snapshot.data!.docs[0].get('time');

                                      bool humRed = false;
                                      bool humYellow = false;
                                      if (snapshot.data!.docs[0]
                                              .get('humidity') >
                                          provider.getHumidityMax()) {
                                        notification();
                                        humRed = true;
                                        humYellow = false;
                                      }
                                      if (snapshot.data!.docs[0]
                                                  .get('humidity') ==
                                              provider.getHumidityMax() ||
                                          snapshot.data!.docs[0]
                                                  .get('humidity') ==
                                              provider.getHumidityMax() - 1) {
                                        humRed = false;
                                        humYellow = true;
                                      }
                                      return SizedBox(
                                        height: 130,
                                        width: sizePageWidth / 2.1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: SizedBox(
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          sizePageWidth / 2.3,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          GetCurrentSensorName(
                                                              index),
                                                          Spacer(),
                                                          Text(
                                                            formatDate.format(
                                                                time.toDate()),
                                                            style: const TextStyle(
                                                                color:
                                                                    colorTextP3),
                                                          ),
                                                          const SizedBox(
                                                            width: 2,
                                                          ),
                                                          const Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 15,
                                                            color: colorTextP3,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          sizePageWidth / 2.3,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            formatTime.format(
                                                                time.toDate()),
                                                            style: const TextStyle(
                                                                color:
                                                                    colorTextP3),
                                                          ),
                                                          const SizedBox(
                                                            width: 2,
                                                          ),
                                                          const Icon(
                                                            Icons
                                                                .schedule_outlined,
                                                            size: 15,
                                                            color: colorTextP3,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          sizePageWidth / 2.2,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/icons/humidity.svg",
                                                            color: humRed ==
                                                                    true
                                                                ? cabinetRed
                                                                : humYellow ==
                                                                        true
                                                                    ? cabinetOrange
                                                                    : cabinetGreen2,
                                                            height: 70,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "${snapshot.data!.docs[0].get('humidity').toStringAsFixed(0)}%"
                                                                .toString(),
                                                            style: const TextStyle(
                                                                color:
                                                                    colorSensorHum,
                                                                fontSize: 68),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              }),
                        ),
                        if (provider.getSensorIdInCabinet().length > 1)
                          SizedBox(
                            height: 65,
                            width: sizePageWidth / 2.2,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    provider.getSensorIdInCabinet().length,
                                itemBuilder: (context, index) {
                                  final Stream<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      sensorData = FirebaseFirestore.instance
                                          .collection('sensors')
                                          .doc(provider
                                              .getSensorIdInCabinet()[index])
                                          .collection('list_data')
                                          // .where('time',
                                          //     isLessThanOrEqualTo: DateTime.now())
                                          .orderBy("time", descending: true)
                                          .limit(1)
                                          .snapshots();
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          );
                                        }
                                        bool humRed = false;
                                        bool humYellow = false;
                                        if (snapshot.data!.docs[0]
                                                .get('humidity') >
                                            provider.getHumidityMax()) {
                                          notification();
                                          humRed = true;
                                          humYellow = false;
                                        }
                                        if (snapshot.data!.docs[0]
                                                    .get('humidity') ==
                                                provider.getHumidityMax() ||
                                            snapshot.data!.docs[0]
                                                    .get('humidity') ==
                                                provider.getHumidityMax() - 1) {
                                          humRed = false;
                                          humYellow = true;
                                        }
                                        return Column(
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              width: 90,
                                              child: Card(
                                                color: humRed == true
                                                    ? cabinetRed
                                                    : humYellow == true
                                                        ? cabinetOrange
                                                        : cabinetDefault,
                                                elevation: 15,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9)),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                  onTap: () {
                                                    _animateGarphToIndex(index);
                                                    _animateTemToIndex(index);
                                                    if (Responsive.isDesktop(
                                                        context)) {
                                                      _animateListDataDesktop(
                                                          index);
                                                    }
                                                    if (Responsive.isDesktop(
                                                            context) &&
                                                        provider.getResDataonlyone() ==
                                                            false) {
                                                      _animateListDataDesktopAlot(
                                                          index);
                                                    }
                                                    if (Responsive.isTablet(
                                                        context)) {
                                                      _animateListDataTablet(
                                                          index);
                                                    }
                                                    if (Responsive.isTablet(
                                                            context) &&
                                                        provider.getResDataonlyone() ==
                                                            false) {
                                                      _animateListDataTabletAlot(
                                                          index);
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/humidity.svg",
                                                          color: cabinetGreen1,
                                                          height: 40,
                                                        ),
                                                        const SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          "${snapshot.data!.docs[0].get('humidity').toStringAsFixed(0)}%"
                                                              .toString(),
                                                          style: const TextStyle(
                                                              color:
                                                                  colorTextP2,
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GetSensorName(index)
                                          ],
                                        );
                                      });
                                }),
                          ),
                      ],
                    ),
                  ],
                ),
              ))
      ],
    );
  }
}

class GetSensorName extends StatelessWidget {
  int index;
  GetSensorName(this.index);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProviderStatus>(context);
    Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream =
        FirebaseFirestore.instance
            .collection('sensors')
            .doc(provider.getSensorIdInCabinet()[index])
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
          return SizedBox(
            height: 20,
            child: Row(
              children: [
                const Icon(
                  Icons.memory_outlined,
                  color: colorTextP3,
                  size: 15,
                ),
                Text(snapshot.data!.get('name'),
                    style: const TextStyle(color: colorTextP3), maxLines: 1),
              ],
            ),
          );
        });
  }
}

class GetCurrentSensorName extends StatelessWidget {
  int index;
  GetCurrentSensorName(this.index);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProviderStatus>(context);
    Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream =
        FirebaseFirestore.instance
            .collection('sensors')
            .doc(provider.getSensorIdInCabinet()[index])
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
          return SizedBox(
            child: Card(
              color: colorSensor,
              child: Row(
                children: [
                  const Icon(
                    Icons.memory_outlined,
                    color: colorTextP2,
                    size: 15,
                  ),
                  Text(snapshot.data!.get('name'),
                      style: const TextStyle(color: colorTextP2), maxLines: 1),
                ],
              ),
            ),
          );
        });
  }
}
