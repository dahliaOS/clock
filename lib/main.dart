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

import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import './keyboard.dart';
import './timer/tab.dart';

void main() {
  runApp(Clock());
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
    return MaterialApp(
        title: 'Clock',
        theme: ThemeData(
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
  bool use24HourFormat = false;

  @override
  Widget build(BuildContext context) {
    final TabController tcon = TabController(length: 3, vsync: this);

    final KeyboardEvents keyboardEvents = KeyboardEvents();

    return RawKeyboardListener(
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
                          return StatefulBuilder(
                            builder: (context, setState2) {
                              return AlertDialog(
                                title: Text("Settings"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SwitchListTile(
                                      title: Text("24-hour format"),
                                      subtitle: Text("At this time, settings will be cleared when the app is closed."),
                                      value: use24HourFormat,
                                      onChanged: (bool newValue) {
                                        //this._dateTimeString = DateTime.now().toString();
                                        setState(() {
                                          use24HourFormat = newValue;
                                        });
                                        setState2(() {});
                                      }
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            }
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
                WorldClockTab(use24HourFormat: use24HourFormat),
                AlarmsTab(),
                TimerTab(keyboardEvents: keyboardEvents)
              ],
            )));
  }
}

class WorldClockTab extends StatefulWidget {
  final bool use24HourFormat;
  WorldClockTab({Key? key, this.use24HourFormat = false}) : super(key: key);

  @override
  _WorldClockTabState createState() => _WorldClockTabState();
}

class _WorldClockTabState extends State<WorldClockTab> {
  //DateTime _datetime = DateTime.now();
  String _dateTimeString = "";
  Timer? _ctimer;

  @override
  void deactivate() {
    _ctimer?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.use24HourFormat)
      _dateTimeString = DateFormat.jms().format(DateTime.now());
    else
      _dateTimeString = DateFormat.Hms().format(DateTime.now());
      // _dateTimeString =
      //     "${_datetime.hour}:${_datetime.minute < 10 ? "0" + _datetime.minute.toString() : _datetime.minute}:${_datetime.second < 10 ? "0" + _datetime.second.toString() : _datetime.second}";

    if (_ctimer == null)
      _ctimer = Timer.periodic(Duration(seconds: 1), (me) {
        setState(() {});
      });
    return Material(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          this._dateTimeString,
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat.yMMMMd().format(DateTime.now()),
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
        ),
      ]),
    );
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
