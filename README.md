# flutter_staggered_animation

Recently I had to achieve various entrance animations in my app and came accross several articles :

* [Flutter Documentation : Staggered Animations](https://flutter.dev/docs/development/ui/animations/staggered-animations)
* [Iiro Krankka : Orchestrating multiple animations and creating a visual enter animation in Flutter](https://iirokrankka.com/2018/03/14/orchestrating-multiple-animations-into-visual-enter-animation/)

I love how free you are with Flutter animations, but it becomes a real mess as soon as you have multiple coordinated animations.

I ended with a solution that makes it easier to declare such staggered animations, but based on indexes.

# Stagger

```dart
StaggerIn(
  duration: const Duration(seconds: 3), // <- Total animation duration (here, each step is 5 / 3 = 1 second)
  child: Column(children: <Widget>[
    StaggerStep.fade(
        index: 0, // <- Starts at 1
        steps: 3, // <- Ends at 3
        child: Container(
          width: 100,
          height: 40,
          color: Colors.red,
        )),
    StaggerStep.slide(
        index: 1, // <- Start at 1
        steps: 1, // <- Ends at 2
        child: Container(
          width: 100,
          height: 40,
          color: Colors.green,
        )),
  ]))
```

You can also use `Stagger` with a custom `Animation<double>` instead of a `StaggerIn` which is based on a duration.

More examples : [Page transition](https://github.com/aloisdeniel/flutter_staggered_animation/blob/master/staggered_animation_sample/lib/demos/transition_counter.dart), [Iiro's artist page](https://github.com/aloisdeniel/flutter_staggered_animation/blob/master/staggered_animation_sample/lib/demos/artist_page/ui/artist_detail_page.dart)
