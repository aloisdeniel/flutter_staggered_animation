import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../staggered_animation.dart';

class EntranceCounterPage extends StatefulWidget {
  EntranceCounterPage({Key key}) : super(key: key);

  static PageRoute createRoute() =>
      MaterialPageRoute(builder: (c) => EntranceCounterPage());

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<EntranceCounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredEntrance(
      duration: const Duration(seconds: 1),
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedStep.fade(index: 0, child: Text("Staggered Counter")),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.display1,
              ),
            ].map((x) => AnimatedStep.slide(child: x)).toList(),
          ),
        ),
        floatingActionButton: AnimatedStep.slide(
            fading: false,
            index: 0,
            duration: 2,
            curve: Curves.elasticOut,
            child: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: AnimatedStep.fade(index: 2, child: Icon(Icons.add)),
            )), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
