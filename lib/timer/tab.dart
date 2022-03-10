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

import 'dart:ui';
import 'dart:core';

import 'package:flutter/material.dart';

import './countdown.dart';
import './setTime.dart';
import '../keyboard.dart';

class TimerTab extends StatefulWidget {
  TimerTab({required this.keyboardEvents});

  final KeyboardEvents keyboardEvents;

  @override
  State<TimerTab> createState() => _TimerTabState();
}

Duration? duration;
DateTime? startTime;

class _TimerTabState extends State<TimerTab> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: duration != null
          ? CountDown(
              duration: duration!,
              startTime: startTime!,
              onDelete: () {
                duration = null;
                startTime = null;
                setState(() {});
              },
            )
          : SetTime(
              keyboardEvents: widget.keyboardEvents,
              setDuration: (Duration newDuration) {
                duration = newDuration;
                startTime = DateTime.now();
                setState(() {});
              },
            ),
    );
  }
}
