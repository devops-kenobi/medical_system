import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/constants.dart';

import '../../../responsive.dart';

class HeaderSetting extends StatelessWidget {
  const HeaderSetting({Key? key}) : super(key: key);

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
          const Text(
            "Setting",
            style: TextStyle(color: colorPriority3),
          ),
        ],
      ),
    );
  }
}
