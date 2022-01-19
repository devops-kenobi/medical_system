import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_temperature_humidity_system/constants.dart';
import 'package:flutter_temperature_humidity_system/responsive.dart';
import 'package:flutter_temperature_humidity_system/screens/components/provider.dart';
import 'package:provider/provider.dart';

class HeaderHome extends StatelessWidget {
  const HeaderHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProviderStatus>(context);
    return SizedBox(
      child: Row(
        children: [
          if (provider.getCabinetDetellsPage() == true)
            Card(
                color: colorBlue,
                child: InkWell(
                  child: const Icon(
                    Icons.chevron_left_outlined,
                    color: Colors.white,
                  ),
                  onTap: () => provider.setCabinetDetellsPage(false),
                )),
          if (!Responsive.isDesktop(context))
            IconButton(
                icon: const Icon(Icons.menu),
                color: colorTextP2,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                }),
          const Text(
            "Home",
            style: TextStyle(color: colorPriority3),
          ),
          const Spacer(),
          if (provider.getCabinetDetellsPage() == true)
            SizedBox(
              child: Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    color: colorTextP2,
                    size: 20,
                  ),
                  Text(
                    provider.getCabinetName(),
                    style: const TextStyle(color: colorTextP2, fontSize: 13),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  SvgPicture.asset(
                    "icon/temMax.svg",
                    color: colorTextP2,
                    height: 17,
                  ),
                  Text(
                    "${provider.getTemperatureMax()}°C".toString(),
                    style: const TextStyle(color: colorTextP2, fontSize: 13),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  SvgPicture.asset(
                    "icon/temMin.svg",
                    color: colorTextP2,
                    height: 17,
                  ),
                  Text(
                    "${provider.getTemperatureMin()}°C".toString(),
                    style: const TextStyle(color: colorTextP2, fontSize: 13),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  SvgPicture.asset(
                    "icon/humidityMax.svg",
                    color: colorTextP2,
                    height: 17,
                  ),
                  Text(
                    "${provider.getHumidityMax()}%".toString(),
                    style: const TextStyle(color: colorTextP2, fontSize: 13),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
