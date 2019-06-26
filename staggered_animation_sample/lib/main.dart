import 'package:flutter/material.dart';
import 'package:staggered_animation_sample/demos/hello_world.dart';
import 'package:staggered_animation_sample/demos/transition_counter.dart';

import 'demos/artist_page/data/mock_data.dart';
import 'demos/artist_page/ui/artist_detail_page.dart';
import 'demos/entrance_counter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staggered Animation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoPicker(),
    );
  }
}

class DemoPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Staggered animations")),
      body: ListView(children: <Widget>[
        DemoTile(
            "Hello World", (s) => HelloWorldPage.createRoute()),
        DemoTile(
            "Counter (Entrance)", (s) => EntranceCounterPage.createRoute()),
        DemoTile("Counter (Page transition)",
            (s) => TransitionCounterPage.createRoute()),
        DemoTile(
            "Artist page (based on Iiro's tutorial)",
            (s) => MaterialPageRoute(
                builder: (c) => ArtistDetailsPage(
                      artist: MockData.andy,
                    )))
      ]),
    );
  }
}

class DemoTile extends StatelessWidget {
  final RouteFactory route;
  final String title;

  DemoTile(this.title, this.route);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(this.title),
      onTap: () => Navigator.push(context, route(null)),
    );
  }
}
