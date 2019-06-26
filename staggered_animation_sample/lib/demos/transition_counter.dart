import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../staggered_animation.dart';

class TransitionCounterPage extends StatefulWidget {
  TransitionCounterPage({Key key}) : super(key: key);

  static PageRoute createRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, __) => Stagger(
      animation: animation,
      child: FadeTransition(
        opacity: animation,
                child: TransitionCounterPage())));
  }

  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<TransitionCounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: StaggerStep.fade(index: 0, child: Text("Staggered Counter")),
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
            ].asMap().entries.map((x) => StaggerStep.slide(index: x.key, child: x.value)).toList(),
          ),
        ),
        floatingActionButton: StaggerStep.slide(
            fading: false,
            index: 0,
            steps: 2,
            curve: Curves.elasticOut,
            child: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: StaggerStep.fade(index: 2, child: Icon(Icons.add)),
            )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
