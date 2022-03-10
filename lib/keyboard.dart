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

class KeyboardEvents {
  List<void Function(RawKeyEvent input)> listeners = [];

  onKey(RawKeyEvent input) {
    for (var listener in listeners) {
      listener(input);
    }
  }
}

class KeyboardEventsListener extends StatefulWidget {
  KeyboardEventsListener({
    required this.keyboardEvents,
    required this.child,
    required this.onKey,
  });

  final KeyboardEvents keyboardEvents;
  final Widget child;
  final void Function(RawKeyEvent input) onKey;

  @override
  State<KeyboardEventsListener> createState() => _KeyboardEventsListenerState();
}

class _KeyboardEventsListenerState extends State<KeyboardEventsListener> {
  @override
  void initState() {
    widget.keyboardEvents.listeners.add(widget.onKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void deactivate() {
    widget.keyboardEvents.listeners.remove(widget.onKey);
    super.deactivate();
  }
}
