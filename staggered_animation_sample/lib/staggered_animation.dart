import 'dart:math';

import 'package:flutter/widgets.dart';

class Staggered extends StatefulWidget {
  final Widget child;
  final Animation<double> animation;
  final int delay;

  Staggered({@required this.animation, this.delay = 0, @required this.child, Key key})
      : super(key: key);

  @override
  StaggeredState createState() => StaggeredState();
}

class StaggeredState extends State<Staggered> {
  final List<_AnimatedStepState> _steps = [];
  int _totalDuration;

  void _addStep(_AnimatedStepState step) {
    this._steps.add(step);
  }

  void _removeStep(_AnimatedStepState step) {
    this._steps.remove(step);
    this.setState(() {});
    _buildStepAnimations();
  }

  void _buildStepAnimations() {
    var autoIndex = 0;

    _totalDuration = 0;
    for (var i = 0; i < _steps.length; i++) {
      final step = _steps[i];
      final index = (step.widget.index ?? autoIndex++)  + (this.widget.delay ?? 0);
      final duration = step.widget.duration ?? 1;
      _totalDuration = max(_totalDuration, index + duration);

      step._startIndex = index;
      step._durationIndex = duration;
    }

    final interval = 1.0 / _totalDuration;

    _steps.forEach((step) {
      step._startTime = step._startIndex * interval;
      step._endTime = step._startTime + interval * (step._durationIndex ?? 1);
      step.setState(() {});
    });

    final animation = widget.animation;
    if (animation is AnimationController) {
      if (animation.duration == null) {
        animation.duration = Duration(milliseconds: 500 * this._totalDuration);
      }
    }
  }

  @override
  void initState() {
    _planifyUpdate();
    super.initState();
  }

  void _planifyUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _buildStepAnimations();
        setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return this.widget.child;
  }
}

class StaggeredEntrance extends StatefulWidget {
  final Duration duration;
  final Widget child;
  final int delay;

  StaggeredEntrance({this.duration, this.delay = 0, @required this.child, Key key})
      : super(key: key);

  @override
  _StaggeredEntranceState createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Staggered(
      delay: widget.delay,
      animation: _controller,
      child: widget.child,
    );
  }
}

class AnimatedStep extends StatefulWidget {
  final int index;
  final int duration;
  final Widget child;
  final Curve curve;
  final StepTransitionBuilder builder;

  AnimatedStep(
      {@required this.child,
      Key key,
      this.index,
      this.duration,
      @required this.builder,
      this.curve = Curves.easeOut})
      : super(key: key);

  factory AnimatedStep.fade(
      {@required Widget child,
      Key key,
      int index,
      int duration,
      Curve curve = Curves.easeIn}) {
    return AnimatedStep(
      key: key,
      child: child,
      index: index,
      duration: duration,
      curve: curve,
      builder: (context, child, time) => Opacity(child: child, opacity: time),
    );
  }

  factory AnimatedStep.slide(
      {@required Widget child,
      Key key,
      Alignment from = Alignment.bottomCenter,
      int index,
      int duration = 1,
      bool fading = true,
      Curve curve = Curves.easeInOut}) {
    return AnimatedStep(
      key: key,
      child: child,
      index: index,
      duration: duration,
      curve: curve,
      builder: (context, child, time) {
        Widget result = FractionalTranslation(
            translation: Offset.lerp(Offset(from.x, from.y), Offset.zero, time),
            child: child);

        if (fading) {
          result = Opacity(child: result, opacity: time.clamp(0.0, 1.0));
        }
        return result;
      },
    );
  }

  @override
  _AnimatedStepState createState() => _AnimatedStepState();
}

class _AnimatedStepState extends State<AnimatedStep> {
  StaggeredState _animationStateAncestor;
  int _startIndex;
  int _durationIndex;
  double _startTime;
  double _endTime;

  @override
  void initState() {
    _animationStateAncestor = this
            .context
            .ancestorStateOfType(const TypeMatcher<StaggeredState>())
        as StaggeredState;
    assert(_animationStateAncestor != null);
    _animationStateAncestor._addStep(this);
    super.initState();
  }

  @override
  void dispose() {
    _animationStateAncestor._removeStep(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedStep oldWidget) {
    if (oldWidget.index != widget.index) {
      _animationStateAncestor._planifyUpdate();
    } else if (oldWidget.curve != widget.curve) {
      this.setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {

    final animation = _startTime != null ? Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationStateAncestor.widget.animation,
          curve: Interval(
            _startTime,
            _endTime,
            curve: widget.curve,
          ),
        ),
      ) : ConstantAnimation(0.0);

    return AnimatedBuilder(
      builder: (context, child) =>
          this.widget.builder(context, child, animation.value),
      animation: animation,
      child: this.widget.child,
    );
  }
}

typedef StepTransitionBuilder = Widget Function(
    BuildContext context, Widget child, double amount);

class ConstantAnimation<T> extends Animation<T> {
  const ConstantAnimation(this._value);

  final T _value;

  @override
  void addListener(listener) {}

  @override
  void addStatusListener(listener) {}

  @override
  void removeListener(listener) {}

  @override
  void removeStatusListener(listener) {}

  @override
  AnimationStatus get status => AnimationStatus.completed;

  @override
  T get value => _value;
}
