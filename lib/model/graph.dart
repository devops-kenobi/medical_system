import 'package:cloud_firestore/cloud_firestore.dart';

class Graph {
  double value;
  Timestamp dateTime;

  Graph({
    required this.value,
    required this.dateTime,
  });
}
