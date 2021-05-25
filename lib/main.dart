import 'package:flutter/material.dart';
import 'package:yaha/page/settings_page.dart';
import 'package:yaha/page/stories_page.dart';
import 'package:yaha/page/story_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YAHA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StoriesPage(),
        '/settings': (context) => SettingsPage(),
        '/story': (context) => StoryPage(),
      },
    );
  }
}

