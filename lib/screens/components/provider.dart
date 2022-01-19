import 'package:flutter/cupertino.dart';

class ProviderStatus extends ChangeNotifier {
  int page = 1;
  int pageUser = 1;
  bool cabinetDetellsPage = false;
  List<dynamic> sensorIdInCabinet = [];
  String cabinetName = "";
  double temperatureMax = 0;
  double temperatureMin = 0;
  double humidityMax = 0;
  bool resDataOnlyOne = true;

  void setPage(page) {
    this.page = page;
    notifyListeners();
  }

  int getPage() {
    return page;
  }

  void setPageUser(pageUser) {
    this.pageUser = pageUser;
    notifyListeners();
  }

  int getPageUser() {
    return pageUser;
  }

  void setCabinetDetellsPage(status) {
    cabinetDetellsPage = status;
    notifyListeners();
  }

  bool getCabinetDetellsPage() {
    return cabinetDetellsPage;
  }

  void setSensorIdInCabinet(sensorID) {
    sensorIdInCabinet = sensorID;
    notifyListeners();
  }

  List<dynamic> getSensorIdInCabinet() {
    return sensorIdInCabinet;
  }

  void setStatusCabinet(
      cabinetName, temperatureMax, temperatureMin, humidityMax) {
    this.cabinetName = cabinetName;
    this.temperatureMax = temperatureMax;
    this.temperatureMin = temperatureMin;
    this.humidityMax = humidityMax;
    notifyListeners();
  }

  String getCabinetName() {
    return cabinetName;
  }

  double getTemperatureMax() {
    return temperatureMax;
  }

  double getTemperatureMin() {
    return temperatureMin;
  }

  double getHumidityMax() {
    return humidityMax;
  }

  void setResDataonlyone(value) {
    resDataOnlyOne = value;
    notifyListeners();
  }

  bool getResDataonlyone() {
    return resDataOnlyOne;
  }
}
