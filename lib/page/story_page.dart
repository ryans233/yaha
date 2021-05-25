import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:yaha/entity/story_entity.dart';
import 'package:yaha/page/comments_page.dart';
import 'package:yaha/util/toast_utils.dart';
import 'package:yaha/util/url_utils.dart';

class StoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final StoryEntity story = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text(story.title),
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildStoryTitle(context, story),
            buildStoryUrl(context, story),
            buildStoryMiscData(context, story),
            buildDivider(),
            Expanded(
              child: CommentsPage(storyEntity: story),
            )
          ],
        ));
  }

  Widget buildStoryTitle(BuildContext context, StoryEntity story) => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Hero(
          child: Material(
            child: Text(
              story.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          tag: story.id,
        ),
      );

  Widget buildStoryUrl(BuildContext context, StoryEntity story) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: GestureDetector(
            child: Text(
              story.url,
              maxLines: 3,
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
            onTap: () => launchUrl(story.url),
            onLongPress: () => _showDialog(context, story)),
      );

  Widget buildStoryMiscData(BuildContext context, StoryEntity story) {
    var postDateTime = DateTime.fromMillisecondsSinceEpoch(story.time * 1000);
    var dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child:
          Text("Posted by ${story.by} • ${dateFormatter.format(postDateTime)}"),
    );
  }

  Widget buildDivider() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Divider(height: 3, color: Colors.grey),
      );

  void _showDialog(BuildContext context, StoryEntity story) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: <Widget>[
          SimpleDialogOption(
            child: Text("OK"),
            onPressed: () {
              ToastUtils.show(context, msg: "OK");
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
