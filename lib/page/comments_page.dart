import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:yaha/model/comment_entity.dart';
import 'package:yaha/model/story_entity.dart';
import 'package:yaha/repo/hacker_news_api.dart';

class CommentsPage extends StatefulWidget {
  CommentsPage({Key key, @required this.storyEntity}) : super(key: key);
  final StoryEntity storyEntity;

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  var api = HackerNewsApi();
  var _isLoading = false;
  var cachedComments = Map<int, List<CommentEntity>>();
  var htmlUnecapse = HtmlUnescape();
  var fetchingList = Map<int, bool>();

  @override
  void initState() {
    super.initState();
    loadComments(widget.storyEntity.id, widget.storyEntity.kids);
  }

  @override
  void dispose() {
    super.dispose();
    fetchingList.clear();
    cachedComments.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Center(child: CupertinoActivityIndicator());
    else
      return _buildCommentsListView(widget.storyEntity.id, true);
  }

  Future<void> loadComments(int parentId, List<int> commentIds) async {
    setState(() {
      _isLoading = true;
    });

    fetchComments(parentId, commentIds)
        .then((value) => cachedComments[parentId] = value)
        .catchError((e) {
      setState(() {
        _isLoading = false;
        print("error: $e");
        cachedComments.remove(parentId);
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<List<CommentEntity>> fetchComments(
      int parentId, List<int> commentIds) async {
    if (cachedComments.containsKey(parentId) &&
        cachedComments[parentId] != null &&
        cachedComments[parentId].isNotEmpty)
      return Future.value(cachedComments[parentId]);
    else
      return Future.wait(commentIds.map((e) => api.getComment(e)));
  }

  Widget _buildCommentsListView(int parentId, bool isFirstLevel) {
    return ListView.builder(
        shrinkWrap: !isFirstLevel,
        physics: isFirstLevel
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            _buildCommentItem(cachedComments[parentId][index]),
        itemCount: cachedComments[parentId].length);
  }

  Widget _buildCommentItem(CommentEntity comment) {
    return Container(
        margin: EdgeInsets.only(top: 10.0, left: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (comment.deleted != null && comment.deleted)
              Text(
                "**Deleted**",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            else
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: comment.by, style: TextStyle(color: Colors.blue)),
                  TextSpan(text: ": "),
                  TextSpan(text: htmlUnecapse.convert(comment.text)),
                ]),
              ),
            if (comment.kids != null)
              if (fetchingList[comment.id] == null &&
                  cachedComments[comment.id] == null)
                Center(
                  child: GestureDetector(
                    child: Padding(
                      child: Text(
                        "Load more",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      padding: EdgeInsets.only(top: 10),
                    ),
                    onTap: () {
                      setState(() {
                        fetchingList[comment.id] = true;
                      });
                    },
                  ),
                )
              else if (cachedComments[comment.id] != null)
                _buildCommentsListView(comment.id, false)
              else
                FutureBuilder(
                  future: fetchComments(comment.id, comment.kids),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: Padding(
                          child: CupertinoActivityIndicator(),
                          padding: EdgeInsets.only(top: 10),
                        ),);
                        break;
                      case ConnectionState.done:
                        if (snapshot.hasError) return Text("error");
                        if (snapshot.hasData) {
                          fetchingList.remove(comment.id);
                          List<CommentEntity> list = snapshot.data;
                          cachedComments[comment.id] = list;
                          return _buildCommentsListView(comment.id, false);
                        } else
                          return Container();
                        break;
                      default:
                        return Container();
                        break;
                    }
                  },
                )
          ],
        ));
  }
}
