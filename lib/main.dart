import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaha/db/db_manager.dart';
import 'package:yaha/model/app_settings_model.dart';
import 'package:yaha/page/settings_page.dart';
import 'package:yaha/page/stories_page.dart';
import 'package:yaha/page/story_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbManager.instance.initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsModel()),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
