import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:yaha/model/app_settings_model.dart';

class SettingsPage extends StatelessWidget {
  final String title = "Settings";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Amount Stories Per Load"),
            trailing: DropdownButton<int>(
              value: context.select(
                  (AppSettingsModel value) => value.amountStoriesPerLoad),
              items: <int>[10, 20, 30, 40]
                  .map(
                    (e) => DropdownMenuItem<int>(
                      value: e,
                      child: Text(e.toString()),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  context.read<AppSettingsModel>().amountStoriesPerLoad = value,
            ),
          )
        ],
      ),
    );
  }
}
