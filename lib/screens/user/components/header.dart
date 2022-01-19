import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/constants.dart';

import '../../../responsive.dart';
import '../user.dart';

class HeaderUser extends StatelessWidget {
  final header;
  HeaderUser(this.header);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(
                icon: const Icon(Icons.menu),
                color: colorTextP2,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                }),
          Text(
            header,
            style: const TextStyle(color: colorPriority3),
          ),
        ],
      ),
    );
  }
}
