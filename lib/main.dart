/*
Copyright 2019 The dahliaOS Authors

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

import 'package:flutter/material.dart';

import './timer/tab.dart';
import './keyboard.dart';
import './worldClock/tab.dart';
import './worldClock/timezones.dart';
import './state.dart';

void main() {
  setupTimezoneInfo();
  appState = AppState.tryFromDisk();
  runApp(new Clock());
}

class Clock extends StatelessWidget {
  /* final Widget Function() customBar = ({ //customBar in lib/window/window.dart
  /// The function called to close the window.
  Function close,
  /// The function called to minimize the window.
  Function minimize,
  /// The function called to maximize or restore the window.
  Function maximize,
  /// The getter to determine whether or not the window is maximized.
  bool Function() maximizeState}) {
    return ClockBar(close: close, minimize: minimize, maximize: maximize);
  };
  final Color customBackground = const Color(0xFFfafafa);*/

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Clock',
        theme: new ThemeData(
            platform: TargetPlatform.fuchsia,
            primaryColor: Colors.blue[900],
            brightness: Brightness.dark),
        home: ClockApp());
  }
}

class ClockApp extends StatefulWidget {
  @override
  _ClockApp createState() => _ClockApp();
}

class _ClockApp extends State<ClockApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final TabController tcon = TabController(length: 3, vsync: this);

    final KeyboardEvents keyboardEvents = KeyboardEvents();

    return new RawKeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        autofocus: true,
        onKey: keyboardEvents.onKey,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              toolbarHeight: 75,
              title: Row(children: [
                TabBar(
                  controller: tcon,
                  indicator: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                  ),
                  isScrollable: true,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.access_time),
                      text: "Clock",
                    ),
                    Tab(
                      icon: Icon(Icons.alarm),
                      text: "Alarms",
                    ),
                    Tab(
                      icon: Icon(Icons.hourglass_empty),
                      text: "Timer",
                    )
                  ],
                ),
                Expanded(child: Container()),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => <PopupMenuEntry>[
                    PopupMenuItem(child: Text("Settings"), value: "settings")
                  ],
                  onSelected: (value) {
                    if (value == "settings")
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Error"),
                            content: new Text("ERROR FEATURE NOT IMPLEMENTED"),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              new FlatButton(
                                child: new Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    ;
                  },
                ),
              ]),
            ),
            body: TabBarView(
              controller: tcon,
              children: [
                WorldClockTab(),
                AlarmsTab(),
                TimerTab(keyboardEvents: keyboardEvents)
              ],
            )));
  }
}

class AlarmsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(child: Icon(Icons.timer_rounded)),
    );
  }
}
