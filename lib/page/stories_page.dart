import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yaha/enum/story_type.dart';
import 'package:yaha/model/story_entity.dart';
import 'package:yaha/repo/hacker_news_api.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage({Key key, @required this.type}) : super(key: key);
  final StoryType type;

  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage>
    with AutomaticKeepAliveClientMixin {
  var api = HackerNewsApi();
  var _isLoading = false;

  String text;
  List<int> ids = List(0);
  Map<int, StoryEntity> cachedStories = Map();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: _isLoading
            ? Center(child: CupertinoActivityIndicator())
            : RefreshIndicator(
                onRefresh: getNewStories,
                child: ListView.builder(
                  itemCount: this.ids.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: api.getStory(ids[index]),
                      builder: (context, snapshot) {
                        if (cachedStories[index] != null) {
                          return buildStoryListItem(cachedStories[index]);
                        } else {
                          if (snapshot.hasData && snapshot.data != null) {
                            var item = snapshot.data;
                            cachedStories[index] = item;
                            return buildStoryListItem(item);
                          } else if (snapshot.hasError) {
                            return Container(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                  child: Text(
                                "Error loading story ${this.ids[index]}",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w300),
                              )),
                            );
                          } else {
                            return Container(
                              padding: EdgeInsets.all(32.0),
                              child: Card(
                                margin: EdgeInsets.all(10),
                                child: CupertinoActivityIndicator(),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ));
  }

  @override
  void initState() {
    super.initState();
    text = "I\'m from ${widget.type.toString()}";
    getNewStories();
  }

  Future<void> getNewStories() async {
    setState(() {
      _isLoading = true;
    });
    var s = await api.getTopStories();
    ids = s;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildStoryListItem(StoryEntity item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(item.title),
      ),
    );
  }
}
