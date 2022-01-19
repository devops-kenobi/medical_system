import 'package:flutter/material.dart';
import 'package:flutter_temperature_humidity_system/screens/components/provider.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import 'components/body_detells.dart';
import 'components/body_home.dart';
import 'components/header.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  // final _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProviderStatus>(context);
    return provider.getCabinetDetellsPage() == false
        ? SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    const HeaderHome(),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    BodyHome()
                  ],
                )),
          )
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  const HeaderHome(),
                  const SizedBox(
                    height: defaultPadding,
                  ),
                  BodyDetellsCabinet(),
                ],
              ),
            ),
          );
  }
}
