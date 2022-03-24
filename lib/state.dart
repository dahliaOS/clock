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

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import './worldClock/timezones.dart';

// Config file contents:
/*
  {
    "timezones": ["Europe/Amsterdam"]
  }
*/

var appState = AppState.empty();

enum _UnableToLoadReason {
  IsWeb,
  LocationUnknown,
  FileDoesNotExist,
  JsonDecode,
}

class AppState {
  // Empty yields an empty instance of AppState
  AppState.empty();

  // Tries to load the appstate from the disk
  AppState.tryFromDisk() {
    if (kIsWeb) {
      // We are on the web so we can't load the appstate from disk, return an empty AppState
      _loadError = _UnableToLoadReason.IsWeb;
      return;
    }

    if (_appConfigLocation == null) {
      // The app config location is unknown, return an empty AppState
      _loadError = _UnableToLoadReason.LocationUnknown;
      return;
    }

    final File configFile = File(_appConfigLocation!);
    if (!configFile.existsSync()) {
      // Config file does not yet exist, return an empty AppState
      _loadError = _UnableToLoadReason.FileDoesNotExist;
      return;
    }

    try {
      final String configContents = configFile.readAsStringSync();
      dynamic config = jsonDecode(configContents);
      if (!(config is Map)) {
        throw 'config is not an object';
      }

      dynamic timezones = config['timezones'];
      if (timezones is List) {
        // Check if there are overlapping timezones from the config file and the timezones we know of
        for (var cityTimezone in timezonesOfCities) {
          for (var timezone in timezones) {
            if (timezone is String && cityTimezone.key == timezone) {
              _cityTimezones[timezone] = cityTimezone;
            }
          }
        }
      }
    } catch (e) {
      print("app state error: $e");
      _loadError = _UnableToLoadReason.JsonDecode;
    }
  }

  _UnableToLoadReason? _loadError;
  Map<String, CityTimeZone> _cityTimezones = {};

  _writeConfigToDisk() async {
    // Check for errors that will prevent writing to disk
    switch (_loadError) {
      case _UnableToLoadReason.IsWeb:
      case _UnableToLoadReason.LocationUnknown:
        // Do not write the config with these errors
        return;
      default:
        // Lets continue
        break;
    }

    final File configFile = File(_appConfigLocation!);
    try {
      if (!await configFile.exists()) {
        // The config file does not yet exist, lets create it
        await configFile.create();
      }
      String configFileContents = jsonEncode({
        'timezones': _cityTimezones.keys.toList(),
      });
      await configFile.writeAsString(configFileContents);
    } catch (e) {
      print("updating app config error: $e");
    }
  }

  List<CityTimeZone> get cityTimezones => _cityTimezones.values.toList();

  addCityTimezone(CityTimeZone entry) {
    _cityTimezones[entry.key] = entry;
    _writeConfigToDisk();
  }

  removeCityTimezone(CityTimeZone entry) {
    _cityTimezones.remove(entry.key);
    _writeConfigToDisk();
  }
}

String? get _appConfigLocation {
  String? homeDir =
      Platform.environment[Platform.isWindows ? 'UserProfile' : 'HOME'];
  return homeDir != null ? homeDir + "/.config/clock.json" : null;
}
