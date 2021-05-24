import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaha/model/comment_entity.dart';
import 'package:yaha/model/story_entity.dart';
import 'package:yaha/repo/hacker_news_api.dart';
import 'package:yaha/util/url_utils.dart';

class CommentsPage extends StatefulWidget {
  CommentsPage({Key key, @required this.storyEntity}) : super(key: key);
  final StoryEntity storyEntity;

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _api = HackerNewsApi();
  final dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  final _comments = Map<int, CommentEntity>();
  final _depth = Map<int, int>();
  final Map<int, List<int>> _tempOrdering = Map();
  final List<int> _orderedComments = List.empty(growable: true);
  final List<int> _hiddenComments = List.empty(growable: true);

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadComments(widget.storyEntity.id);
  }

  @override
  void dispose() {
    super.dispose();
    _comments.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Center(
        child: CircularProgressIndicator(),
      );
    else if (_comments.isEmpty)
      return Center(
        child: Text("No comment"),
      );
    else
      return _buildComments();
  }

  Future<void> loadComments(int parentId) async {
    debugPrint("loadComments parentId=$parentId");
    setState(() {
      _isLoading = true;
    });
    loadCommentWithChildren(1, widget.storyEntity.id, widget.storyEntity.kids)
        .listen((event) {
      print(event);
    }, onDone: () {
      print("tt onDone");
      _orderComments();
      debugPrint("depth=" + _depth.toString());
      debugPrint("_orderedComments=" + _orderedComments.toString());
      debugPrint("_comments=" + _comments.toString());
      setState(() {
        _isLoading = false;
      });
    });
  }

  Stream loadCommentWithChildren(int depth, int parentId, List<int> ids) {
    if (ids != null)
      _tempOrdering
          .putIfAbsent(parentId, () => List.empty(growable: true))
          .addAll(ids);
    return ids == null
        ? Stream.empty()
        : Stream.fromIterable(ids)
            .flatMap((value) => _api.getComment(value).asStream())
            .doOnData((event) {
              debugPrint(
                  "_api.getComment(value).asStream()).doOnData((event) = $event");
              if (event.id == 27204890) print("here");
              _comments[event.id] = event;
              _depth[event.id] = depth;
            })
            .flatMap((event) =>
                loadCommentWithChildren(depth + 1, event.id, event.kids))
            .doOnDone(() {
              debugPrint("onDone");
            });
  }

  Widget _buildComments() => ListView.builder(
        itemBuilder: (context, index) => _buildCommentItem(index),
        itemCount: _orderedComments.length,
      );

  Widget _buildCommentItem(int index) {
    debugPrint("building ${_orderedComments[index]}");
    final comment = _comments[_orderedComments[index]];
    return _hiddenComments.contains(comment.id)
        ? SizedBox.shrink()
        : Container(
            margin: EdgeInsets.only(
              left: (_depth[_orderedComments[index]] - 1) * 12.0 + 8,
              right: 8.0,
              top: 2,
              bottom: 2,
            ),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(8),
                child: comment.deleted == true
                    ? Text("***Deleted***")
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${comment.by} ${dateFormatter.format(DateTime.fromMillisecondsSinceEpoch(comment.time * 1000))}:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Html(
                            data: comment.text,
                            onLinkTap: (url, context, attributes, element) =>
                                launchUrl(url),
                          ),
                          // Text(
                          //   comment.text
                          // ),
                          comment.kids != null
                              ? Container(
                                  margin: EdgeInsets.all(4),
                                  child: Row(
                                    children: [
                                      Switch(
                                        value: !comment.kids.any((element) =>
                                            _hiddenComments.contains(element)),
                                        onChanged: (show) =>
                                            toggleCommentVisibility(
                                                comment.id, show),
                                      ),
                                      Text("Show/Hide"),
                                    ],
                                  ),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
              ),
            ),
          );
  }

  toggleCommentVisibility(int id, bool show) {
    setState(() {
      _toggleCommentVisibility(id, show);
    });
  }

  _toggleCommentVisibility(int id, bool show) {
    debugPrint("id=$id show=$show");
    var kids = _comments[id].kids;
    if (kids != null)
      kids.forEach((e) {
        show ? _hiddenComments.remove(e) : _hiddenComments.add(e);
        return _toggleCommentVisibility(e, show);
      });
  }

  _orderComments() {
    _orderedComments.clear();
    var list = _tempOrdering.entries.toList();
    list.sort((a, b) => a.key.compareTo(b.key));
    _orderedComments.addAll(list.fold<List<int>>(List.empty(growable: true),
        (previousValue, element) {
      if (element.key == widget.storyEntity.id)
        previousValue.addAll(element.value);
      else
        previousValue.insertAll(
            previousValue.indexOf(element.key) + 1, element.value);
      return previousValue;
    }));
  }
}
