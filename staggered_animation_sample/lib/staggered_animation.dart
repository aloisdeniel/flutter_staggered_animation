import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class Stagger extends StatefulWidget {
  final Widget child;
  final Animation<double> animation;
  final int stepDelay;
  final Curve defaultCurve;
  final StepTransitionBuilder defaultTransition;

  Stagger(
      {@required this.animation,
      this.stepDelay = 0,
      this.defaultCurve = Curves.easeInOut,
      this.defaultTransition = StepTransitions.fade,
      @required this.child,
      Key key})
      : assert(stepDelay != null),
        assert(defaultCurve != null),
        assert(animation != null),
        assert(child != null),
        super(key: key);

  @override
  StaggerState createState() => StaggerState();
}

class StaggerState extends State<Stagger> {
  final _steps = <StaggerStep>[];

  int get totalSteps {
    return this.widget.stepDelay +
        _steps.fold(0, (previous, step) {
          final stepEnd = step.index + step.steps;
          return math.max(previous, stepEnd);
        });
  }

  void addStep(StaggerStep step) {
    _steps.add(step);
    WidgetsBinding.instance.addPostFrameCallback((_) => this.setState(() {}));
  }

  void updateStep(StaggerStep oldStep, StaggerStep newStep) {
    _steps.remove(oldStep);
    _steps.add(newStep);
    this.setState(() {});
  }

  void removeStep(StaggerStep step) {
    _steps.remove(step);
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStagger(
      steps: this._steps.toList(),
      animation: this.widget.animation,
      child: this.widget.child,
      stepDelay: this.widget.stepDelay,
      totalSteps: this.totalSteps,
      defaultCurve: this.widget.defaultCurve,
      defaultTransition: this.widget.defaultTransition,
    );
  }
}

class _InheritedStagger extends InheritedWidget {
  final Animation<double> animation;
  final int stepDelay;
  final int totalSteps;
  final Curve defaultCurve;
  final StepTransitionBuilder defaultTransition;
  final List<StaggerStep> steps;

  _InheritedStagger(
      {@required Widget child,
      @required this.steps,
      @required this.defaultCurve,
      @required this.defaultTransition,
      @required this.animation,
      @required this.stepDelay,
      @required this.totalSteps})
      : super(child: child);

  static _InheritedStagger of(BuildContext context) {
    final result = context.inheritFromWidgetOfExactType(_InheritedStagger);
    assert(result != null);
    return result;
  }

  @override
  bool updateShouldNotify(_InheritedStagger oldWidget) {
    return oldWidget.totalSteps != this.totalSteps ||
        oldWidget.animation != this.animation;
  }
}

class StaggerStep extends StatefulWidget {
  final int index;
  final int steps;
  final Widget child;
  final Curve curve;
  final StepTransitionBuilder transition;

  StaggerStep(
      {@required this.child,
      Key key,
      int index = 0,
      int steps = 1,
      this.transition = StepTransitions.fade,
      this.curve = Curves.easeOut})
      : this.index = math.max(0, index),
        this.steps = math.max(1, steps ?? 1),
        super(key: key);

  factory StaggerStep.fade(
      {@required Widget child,
      Key key,
      int index = 0,
      int steps = 1,
      Curve curve = Curves.easeOut}) {
    return StaggerStep(
      key: key,
      child: child,
      index: index,
      steps: steps,
      curve: curve,
      transition: StepTransitions.fade,
    );
  }

  factory StaggerStep.slide(
      {@required Widget child,
      Key key,
      Alignment position = Alignment.bottomCenter,
      int index = 0,
      int steps = 1,
      bool fading = true,
      Curve curve = Curves.easeOut}) {
    return StaggerStep(
      key: key,
      child: child,
      index: index,
      steps: steps,
      curve: curve,
      transition: StepTransitions.slide(position, fading),
    );
  }

  @override
  _StaggerStepState createState() => _StaggerStepState();
}

class _StaggerStepState extends State<StaggerStep> {
  StaggerState _staggeredState;

  @override
  void didUpdateWidget(StaggerStep oldWidget) {
    if (oldWidget.index != this.widget.index ||
        oldWidget.steps != this.widget.steps) {
      _staggeredState.updateStep(oldWidget, this.widget);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _staggeredState = this
        .context
        .ancestorStateOfType(const TypeMatcher<StaggerState>()) as StaggerState;
    assert(_staggeredState != null);
    _staggeredState.addStep(this.widget);
    super.initState();
  }

  @override
  void dispose() {
    _staggeredState.removeStep(this.widget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staggered = _InheritedStagger.of(context);

    Animation<double> animation;

    if (staggered.steps.any((step) =>
        step.index == this.widget.index && step.steps == this.widget.steps)) {
      final startTime =
          (staggered.stepDelay + this.widget.index) / staggered.totalSteps;
      final endTime = startTime + (this.widget.steps / staggered.totalSteps);
      animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: staggered.animation,
          curve: Interval(
            startTime,
            endTime,
            curve: widget.curve ?? staggered.defaultCurve,
          ),
        ),
      );
    } else {
      animation = const AlwaysStoppedAnimation(0.0);
    }

    final transition = this.widget.transition ?? staggered.defaultTransition;

    return AnimatedBuilder(
      builder: (context, child) => transition(context, child, animation.value),
      animation: animation,
      child: this.widget.child,
    );
  }
}

typedef StepTransitionBuilder = Widget Function(
    BuildContext context, Widget child, double amount);

abstract class StepTransitions {
  static Widget fade(context, child, time) =>
      Opacity(child: child, opacity: time);

  static StepTransitionBuilder slide(Alignment position, bool fading) =>
      (context, child, time) {
        Widget result = FractionalTranslation(
            translation:
                Offset.lerp(Offset(position.x, position.y), Offset.zero, time),
            child: child);

        if (fading) {
          result = Opacity(child: result, opacity: time.clamp(0.0, 1.0));
        }
        return result;
      };
}

class StaggerIn extends StatefulWidget {
  final Duration duration;
  final Widget child;
  final int stepDelay;
  final Curve defaultCurve;
  final StepTransitionBuilder defaultTransition;

  StaggerIn(
      {@required this.duration,
      @required this.child,
      this.stepDelay = 0,
      this.defaultCurve = Curves.easeInOut,
      this.defaultTransition,
      Key key})
      : super(key: key);

  @override
  _StaggerInState createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stagger(
      stepDelay: widget.stepDelay,
      defaultCurve: widget.defaultCurve,
      defaultTransition: widget.defaultTransition,
      animation: _controller,
      child: widget.child,
    );
  }
}
