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

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CityTimeZone {
  CityTimeZone(this.key, this.timezoneLocation, this.city);

  final String key;
  final tz.Location timezoneLocation;
  final String city;

  DateTime get now => tz.TZDateTime.now(timezoneLocation);

  tz.TimeZone get timezone => timezoneLocation.zones.last;

  // prettyOffset generate a human readable offset
  // The result is in the form of "+H:MM" or "-H:MM"
  // By the default UTC +0 is taken as the base value used to generate the offset from
  // If you want a different base value you can set the base argument to do so
  String prettyOffset([Duration? base]) {
    final int extraOffset = base?.inMilliseconds ?? 0;
    final int totalOffsetMinutes =
        (timezone.offset - extraOffset) ~/ 1000 ~/ 60;
    final int offsetHours = totalOffsetMinutes ~/ 60;
    final String offsetMinutes =
        (totalOffsetMinutes % 60).toString().padLeft(2, '0');

    return "${offsetHours >= 0 ? "+" : ""}$offsetHours:$offsetMinutes H";
  }

  // Yields a human readable Utc offset based on UTC +0
  // If there is a zone abbreviation available it's placed before the value
  String get prettyUtcOffset {
    final abbreviation = timezone.abbreviation;
    final String zoneNamePrefix = abbreviation.isNotEmpty &&
            abbreviation[0] != '-' &&
            abbreviation[0] != '+'
        ? abbreviation + ' '
        : '';

    return zoneNamePrefix + prettyOffset();
  }
}

List<CityTimeZone> timezonesOfCities = [];

setupTimezoneInfo() {
  tz.initializeTimeZones();
  tz.timeZoneDatabase.locations.forEach((key, value) {
    timezonesOfCities.add(CityTimeZone(
      key,
      value,
      key.split('/').last.replaceAll('_', ' '),
    ));
  });
}
