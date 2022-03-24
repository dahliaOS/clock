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

import 'package:flutter/material.dart';

import './timezones.dart';

class AddTimezoneScreen extends StatefulWidget {
  const AddTimezoneScreen({required this.onSelect});

  final void Function(CityTimeZone cityTZ) onSelect;

  @override
  State<AddTimezoneScreen> createState() => _AddTimezoneScreenState();
}

class _AddTimezoneScreenState extends State<AddTimezoneScreen> {
  List<CityTimeZone> options = timezonesOfCities;

  onInput(String query) {
    String normalizedQuery = query.toLowerCase();
    options = timezonesOfCities
        .where((e) => e.city.toLowerCase().contains(normalizedQuery))
        .toList();
    setState(() {});
  }

  onSearchSubmit() {
    if (options.isNotEmpty) onSelect(options.first);
  }

  onSelect(CityTimeZone option) {
    widget.onSelect(option);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 75,
        title: Text('Choose a city'),
      ),
      body: Column(
        children: [
          _SearchField(
            onInput: onInput,
            onSubmit: onSearchSubmit,
          ),
          _Options(options: options, onSelect: onSelect),
        ],
      ),
    );
  }
}

class _Options extends StatelessWidget {
  const _Options({required this.options, this.onSelect});

  final List<CityTimeZone> options;
  final void Function(CityTimeZone)? onSelect;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final CityTimeZone option = options[index];

          return TextButton(
            key: Key(index.toString()),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.city,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  option.prettyUtcOffset,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            onPressed: onSelect != null ? () => onSelect!(option) : null,
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onInput, this.onSubmit});

  final void Function(String s) onInput;
  final void Function()? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(labelText: "City"),
        onChanged: onInput,
        onSubmitted: onSubmit != null ? (String s) => onSubmit!() : null,
      ),
    );
  }
}
