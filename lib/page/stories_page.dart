import 'dart:math';

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
  var _isLoadingMore = false;
  final _NUM_LOAD_MORE = 20;

  List<int> ids = List();
  List<StoryEntity> cachedStories = List();
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_onScrollStoriesList);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollStoriesList);
    super.dispose();
  }

  void _onScrollStoriesList() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      loadMoreStories();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: ids.isEmpty
            ? Center(
                child: InkWell(
                  onTap: getNewStories,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.refresh),
                      Text("Click to refresh")
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: getNewStories,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: this.cachedStories.length + 1,
                  itemBuilder: (context, index) {
                    if (index < cachedStories.length) {
                      return buildStoryListItem(cachedStories[index]);
                    } else if (_isLoadingMore) {
                      return Container(
                        height: 50.0,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else
                      return Container(
                        height: 50,
                      );
                  },
                ),
              ));
  }

  Future<void> getNewStories() async {
    this.cachedStories.clear();
    this.ids = await api.getTopStories();
    fetchStories(this.ids.sublist(
            cachedStories.length, cachedStories.length + _NUM_LOAD_MORE))
        .then((value) {
      setState(() {
        cachedStories.addAll(value);
        _isLoadingMore = false;
      });
    });
  }

  Future<void> loadMoreStories() {
    if (_isLoadingMore == false) {
      setState(() {
        _isLoadingMore = true;
      });
      fetchStories(this.ids.sublist(
              cachedStories.length, cachedStories.length + _NUM_LOAD_MORE))
          .then((value) {
        setState(() {
          cachedStories.addAll(value);
          _isLoadingMore = false;
        });
      });
    }
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

  Future<List<StoryEntity>> fetchStories(List<int> ids) async {
    var random = Random();
    List<StoryEntity> list = List();
    await Future.wait(ids.map((int e) => Future.delayed(
            Duration(milliseconds: random.nextInt(100)),
            () => api.getStory(e))))
        .then((List<StoryEntity> value) =>
            list.addAll(value..sort((a, b) => b.id.compareTo(a.id))))
        .catchError(print);
    return Future.value(list);
  }
}
