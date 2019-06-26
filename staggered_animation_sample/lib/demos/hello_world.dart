import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../staggered_animation.dart';

class HelloWorldPage extends StatelessWidget {
  HelloWorldPage({Key key}) : super(key: key);

  static PageRoute createRoute() =>
      MaterialPageRoute(builder: (c) => HelloWorldPage());

  @override
  Widget build(BuildContext context) {
    return StaggerIn(
        duration: const Duration(seconds: 3),
        child: Column(children: <Widget>[
          StaggerStep.fade(
              index: 0,
              steps: 3,
              child: Container(
                width: 100,
                height: 40,
                color: Colors.red,
              )),
          StaggerStep.slide(
              index: 1,
              steps: 1,
              child: Container(
                width: 100,
                height: 40,
                color: Colors.green,
              )),
        ]));
  }
}
