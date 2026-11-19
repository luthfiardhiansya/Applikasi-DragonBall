import 'package:flutter/material.dart';

import 'package:ujian_projek/navigation/menu.dart';
import 'package:ujian_projek/pages/dragonball_page.dart';

class AppRoute {
  static const menu = '/';
  static const dragonballLoading = '/dragonball-loading';
  static const dragonball = '/dragonball';

  static final Map<String, WidgetBuilder> routes = {
    menu: (context) => const Menu(),
    dragonballLoading: (context) => const DragonballLoadingPage(),
    dragonball: (context) => const DragonballPage(),
  };
}
