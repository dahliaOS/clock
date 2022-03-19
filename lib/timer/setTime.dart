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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../keyboard.dart';

class SetTime extends StatefulWidget {
  SetTime({required this.setDuration, required this.keyboardEvents});

  final void Function(Duration newDuration) setDuration;
  final KeyboardEvents keyboardEvents;

  @override
  State<SetTime> createState() => _SetTimeState();
}

class _SetTimeState extends State<SetTime> {
  List<int> input = [];
  bool get active => !input.isEmpty;
  List<int> get secondsMinutesHours {
    List<int> secondsMinutesHours = [0, 0, 0, 0, 0, 0];
    if (active) {
      for (int idx = 0; idx < input.length; idx++) {
        secondsMinutesHours[input.length - idx - 1] = input[idx];
      }
    }
    return secondsMinutesHours;
  }

  setNr(int nr) {
    if (input.length == 6) return;
    if (input.length == 0 && nr == 0) return;
    input.add(nr);
    setState(() {});
  }

  onBackspace() {
    if (input.length == 0) return;
    input.removeLast();
    setState(() {});
  }

  pressPlay() {
    if (!active) return;

    int seconds = secondsMinutesHours[0] + secondsMinutesHours[1] * 10;
    int minutes = secondsMinutesHours[2] + secondsMinutesHours[3] * 10;
    int hours = secondsMinutesHours[4] + secondsMinutesHours[5] * 10;

    // When the seconds and/or minutes are more than 60 the duration method adds an extra hour or minute and subtract 60 from the minutes and/or seconds
    widget.setDuration(Duration(
      seconds: seconds,
      minutes: minutes,
      hours: hours,
    ));
  }

  onKey(RawKeyEvent input) {
    if (!(input is RawKeyDownEvent)) return;

    final String key = input.logicalKey.keyLabel;
    switch (key) {
      case "0":
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        setNr(int.parse(key));
        break;
      case " ":
        setNr(0);
        break;
      case "Backspace":
        onBackspace();
        break;
      case "Enter":
        pressPlay();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = EdgeInsets.symmetric(vertical: 20);

    return KeyboardEventsListener(
      keyboardEvents: widget.keyboardEvents,
      onKey: onKey,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 700,
          ),
          child: Column(
            children: [
              Padding(
                padding: padding,
                child: _TimeDisplay(
                  secondsMinutesHours: secondsMinutesHours,
                  onBackspace: onBackspace,
                  active: active,
                ),
              ),
              _Divider(),
              Expanded(
                flex: 3,
                child: _TouchInputs(onInput: setNr),
              ),
              Padding(
                padding: padding,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: const EdgeInsets.all(22),
                    ),
                    onPressed: active ? pressPlay : null,
                    child: Icon(
                      Icons.play_arrow,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  const _TimeDisplay({
    required this.secondsMinutesHours,
    required this.onBackspace,
    required this.active,
  });

  final void Function() onBackspace;
  final List<int> secondsMinutesHours;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimeUnit(
              unit: 'h',
              value: secondsMinutesHours.getRange(4, 6).toList(),
              highlighted: active),
          _TimeUnit(
              unit: 'm',
              value: secondsMinutesHours.getRange(2, 4).toList(),
              highlighted: active),
          _TimeUnit(
              unit: 's',
              value: secondsMinutesHours.getRange(0, 2).toList(),
              highlighted: active),
          TextButton(
            onPressed: active ? onBackspace : null,
            style: TextButton.styleFrom(
              shape: CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: Icon(Icons.backspace_outlined),
          )
        ],
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  const _TimeUnit({
    required this.unit,
    required this.value,
    this.highlighted,
  });

  final String unit;
  final List<int> value;
  final bool? highlighted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          AnimatedDefaultTextStyle(
            child: Text(value[1].toString() + value[0].toString()),
            duration: Duration(milliseconds: 50),
            style: theme.textTheme.displayMedium?.copyWith(
                  color: highlighted == true ? theme.colorScheme.primary : null,
                  fontFeatures: [
                    // Make the text have a fixed width so the text doesn't shift around while setting a number
                    FontFeature.tabularFigures()
                  ],
                ) ??
                TextStyle(),
          ),
          AnimatedDefaultTextStyle(
            child: Text(unit),
            duration: Duration(milliseconds: 50),
            style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 20,
                  color: highlighted == true ? theme.colorScheme.primary : null,
                ) ??
                TextStyle(),
          ),
        ],
      ),
    );
  }
}

class _TouchInputs extends StatelessWidget {
  const _TouchInputs({required this.onInput});

  final void Function(int nr) onInput;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...List.generate(
          3,
          (y) {
            final int offset = y * 3;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (x) => _TouchInput(
                  onPressed: onInput,
                  nr: offset + x + 1,
                ),
              ),
            );
          },
        ),
        _TouchInput(
          onPressed: onInput,
          nr: 0,
        ),
      ],
    );
  }
}

class _TouchInput extends StatelessWidget {
  const _TouchInput({
    required this.onPressed,
    required this.nr,
  });

  final void Function(int nr) onPressed;
  final int nr;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onPressed(nr),
      style: TextButton.styleFrom(
        textStyle: Theme.of(context).textTheme.headline4,
        primary: Colors.white,
        shape: CircleBorder(),
        padding: const EdgeInsets.all(26),
      ),
      child: Text(nr.toString()),
    );
  }
}
