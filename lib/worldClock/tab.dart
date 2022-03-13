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

import 'dart:async';

import 'package:flutter/material.dart';

import './timezones.dart';
import './utils.dart';
import './addTimezoneScreen.dart';
import '../state.dart';

class WorldClockTab extends StatefulWidget {
  @override
  _WorldClockTabState createState() => _WorldClockTabState();
}

class _WorldClockTabState extends State<WorldClockTab> {
  DateTime datetime = DateTime.now();
  Timer? timer;

  @override
  void deactivate() {
    timer?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (timer == null)
      timer = Timer.periodic(Duration(seconds: 1), (me) {
        datetime = DateTime.now();
        setState(() {});
      });

    return Material(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ListView(
            children: [
              _LocalTime(datetime: datetime, key: Key('local-time')),
              ...appState.cityTimezones
                  .map((cityTZ) => _UTCTime(
                        key: Key(cityTZ.key),
                        city: cityTZ,
                        localCurrentTime: datetime,
                        onRemove: () => setState(
                          () => appState.removeCityTimezone(cityTZ),
                        ),
                      ))
                  .toList(),
              Container(height: 70, key: Key('bottom-spacer')),
            ],
          ),
          _AddButton(
            onAdd: (CityTimeZone cityTimezone) => setState(
              () => appState.addCityTimezone(cityTimezone),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onAdd});

  final void Function(CityTimeZone cityTimezone) onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const CircleBorder(), padding: const EdgeInsets.all(14)),
        child: Icon(
          Icons.add,
          size: 32,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddTimezoneScreen(onSelect: onAdd)),
        ),
      ),
    );
  }
}

class _LocalTime extends StatelessWidget {
  _LocalTime({required this.datetime, Key? key}) : super(key: key);

  final DateTime datetime;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _formatTime(datetime, true),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text(
                "${weekDayToString[datetime.weekday]} ${datetime.day} ${monthToString[datetime.month]} ${datetime.year}",
                style: Theme.of(context).textTheme.caption),
          ],
        ));
  }
}

class _UTCTime extends StatelessWidget {
  const _UTCTime({
    required this.city,
    required this.localCurrentTime,
    required this.onRemove,
    Key? key,
  }) : super(key: key);

  final DateTime localCurrentTime;
  final CityTimeZone city;
  final void Function() onRemove;

  @override
  Widget build(BuildContext context) {
    final DateTime timeInCity = city.now;

    final String dayDiff = timeInCity.day == localCurrentTime.day
        ? 'Today'
        : timeInCity.isBefore(localCurrentTime)
            ? 'Yesterday'
            : 'Tomorrow';

    return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city.city, style: Theme.of(context).textTheme.headline6),
                  Text(
                      "${dayDiff}, ${city.prettyOffset(localCurrentTime.timeZoneOffset)}"),
                ],
              ),
              Spacer(),
              Text(
                _formatTime(timeInCity, false),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              _UTCTimeOptions(onRemove: onRemove),
            ],
          ),
        ));
  }
}

enum _UTCTimeOptionsEnum {
  Remove,
}

class _UTCTimeOptions extends StatelessWidget {
  const _UTCTimeOptions({required this.onRemove});

  final void Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_UTCTimeOptionsEnum>(
      icon: Icon(Icons.more_vert),
      onSelected: (_UTCTimeOptionsEnum result) => onRemove(),
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<_UTCTimeOptionsEnum>(
          value: _UTCTimeOptionsEnum.Remove,
          child: Text('Remove'),
        ),
      ],
    );
  }
}

String _formatTime(DateTime dt, bool showSeconds) {
  var resp =
      "${dt.hour}:${dt.minute < 10 ? "0" + dt.minute.toString() : dt.minute}";

  return showSeconds
      ? resp + ":${dt.second < 10 ? "0" + dt.second.toString() : dt.second}"
      : resp;
}
