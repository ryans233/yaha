import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yaha/model/comment_entity.dart';
import 'package:yaha/repo/hacker_news_api.dart';

class CommentsPage extends StatefulWidget {
  CommentsPage({Key key, @required this.commentIds}) : super(key: key);
  final List<int> commentIds;

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  var api = HackerNewsApi();
  var _isLoading = false;
  List<CommentEntity> cachedComments = List();

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CupertinoActivityIndicator(),)
        : ListView.builder(
            itemBuilder: (context, index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  "${cachedComments[index].by}: ${cachedComments[index].text}",maxLines: 3,
                )),
            itemCount: cachedComments.length,
          );
  }

  Future<List<CommentEntity>> fetchComments(List<int> ids) async {
    var random = Random();
    List<CommentEntity> list = List();
    await Future.wait(ids.map((int e) => Future.delayed(
            Duration(milliseconds: random.nextInt(100)),
            () => api.getComment(e))))
        .then((List<CommentEntity> value) =>
            list.addAll(value..sort((a, b) => b.id.compareTo(a.id))))
        .catchError(print);
    return Future.value(list);
  }

  void loadComments() {
    cachedComments.clear();
    setState(() {
      _isLoading = true;
    });
    fetchComments(widget.commentIds).then((value) {
      setState(() {
        cachedComments.addAll(value);
        _isLoading = false;
      });
    });
  }
}
