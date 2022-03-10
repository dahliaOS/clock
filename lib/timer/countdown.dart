/*
Copyright 2022 The dahliaOS Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'dart:math';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';

class CountDown extends StatelessWidget {
  CountDown({
    required this.duration,
    required this.startTime,
    required this.onDelete,
  });

  final Duration duration;
  final DateTime startTime;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = EdgeInsets.symmetric(vertical: 20);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: padding,
                child: _Counter(
                  duration: duration,
                  startTime: startTime,
                )),
            Padding(
                padding: padding,
                child: _Actions(
                  onDelete: onDelete,
                )),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatefulWidget {
  _Counter({required this.duration, required this.startTime});

  final Duration duration;
  final DateTime startTime;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter>
    with SingleTickerProviderStateMixin {
  Timer? timer;
  bool completeTextBlinkVisible = true;
  AnimationController? animationController;
  double lastProgress = 0;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    super.initState();
  }

  @override
  void deactivate() {
    timer?.cancel();
    animationController?.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    timer?.cancel();

    int durationMicroseconds = widget.duration.inMicroseconds;
    int expiredMicroseconds =
        DateTime.now().difference(widget.startTime).inMicroseconds;
    final int remainingMicroseconds =
        durationMicroseconds - expiredMicroseconds;

    final ThemeData theme = Theme.of(context);

    final int remainingSeconds;
    final Color textColor;

    if (remainingMicroseconds > 0) {
      animationController!.reset();
      animationController!.forward();

      textColor = theme.colorScheme.primary;
      remainingSeconds = (remainingMicroseconds / 1000000).round();

      // We should update the clock once the timer goes down by one second
      // Because of this we cannot use the Timer.periodic as when a computer is slow there could be a time delay between what's on screen and the real value
      //
      // Here we're calculating how many microseconds it takes until the next second and set a timer for that amount.
      // This makes it so that when a computer is slow and the timer will fix itself
      timer = Timer(
        Duration(microseconds: remainingMicroseconds % 1000000),
        () => setState(() {}),
      );
    } else {
      timer = Timer(
        Duration(milliseconds: 700),
        () {
          completeTextBlinkVisible = !completeTextBlinkVisible;
          setState(() {});
        },
      );

      textColor = theme.colorScheme.onPrimary
          .withAlpha(completeTextBlinkVisible ? 255 : 50);
      remainingSeconds = 0;
    }

    return SizedBox(
      height: 300,
      width: 300,
      child: CustomPaint(
        willChange: true,
        painter: _ProgressCircle(
          theme: theme,
          progressionBegin: remainingSeconds == 0
              ? 1
              : 1 / durationMicroseconds * expiredMicroseconds,
          progressionEnd: remainingSeconds == 0
              ? 1
              : 1 / durationMicroseconds * (expiredMicroseconds + 1000000),
          animation: animationController!.view,
        ),
        child: Center(
          child: _CounterText(
            remainingSeconds: remainingSeconds,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ProgressCircle extends CustomPainter {
  _ProgressCircle({
    required this.theme,
    required double progressionBegin,
    required double progressionEnd,
    required Animation<double> animation,
  })  : _progress = Tween<double>(begin: progressionBegin, end: progressionEnd)
            .animate(animation),
        super(repaint: animation);

  final ThemeData theme;
  // Should be a number between 0 and 1
  final Animation<double> _progress;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  final Paint remainderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..color = Colors.grey.withAlpha(100)
    ..strokeWidth = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = theme.colorScheme.primary
      ..isAntiAlias = true;

    double radius = size.width / 2;
    if (_progress.value < 1) {
      canvas.drawCircle(
        Offset(radius, radius),
        radius,
        remainderPaint,
      );

      double radiant = 2 * pi * (_progress.value - 0.25);

      Path progressPath = Path();
      progressPath.moveTo(radius, 0);

      if (_progress.value > 0.5) {
        progressPath.arcToPoint(
          Offset(radius, radius * 2),
          radius: Radius.circular(size.height / 2),
        );
      }
      progressPath.arcToPoint(
        Offset(cos(radiant) * radius + radius, sin(radiant) * radius + radius),
        radius: Radius.circular(size.height / 2),
      );

      canvas.drawPath(progressPath, progressPaint);
    } else {
      canvas.drawCircle(
        Offset(radius, radius),
        radius,
        progressPaint,
      );
    }
  }
}

class _CounterText extends StatelessWidget {
  _CounterText({
    required this.remainingSeconds,
    required this.color,
  });

  final int remainingSeconds;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final int seconds = remainingSeconds % 60;
    final int totalMinutes = remainingSeconds ~/ 60;
    final int minutes = totalMinutes % 60;
    final int hours = totalMinutes ~/ 60;

    return AnimatedDefaultTextStyle(
      child: Text(hours > 0
          ? '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
          : minutes > 0
              ? '$minutes:${seconds.toString().padLeft(2, '0')}'
              : '$seconds'),
      duration: Duration(milliseconds: 50),
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  _Actions({required this.onDelete});

  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: const EdgeInsets.all(22),
        ),
        onPressed: onDelete,
        child: Icon(
          Icons.delete_outline,
          size: 30,
        ),
      ),
    );
  }
}
