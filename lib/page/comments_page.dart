import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yaha/entity/story_entity.dart';
import 'package:yaha/model/comments_model.dart';
import 'package:yaha/util/url_utils.dart';

class CommentsPage extends StatelessWidget {
  CommentsPage({Key key, @required this.storyEntity}) : super(key: key);

  final StoryEntity storyEntity;
  final dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<CommentsModel>(
        create: (_) => CommentsModel(storyEntity.id),
        builder: (context, child) {
          var isLoading =
              context.select((CommentsModel value) => value.isLoading);
          var comments =
              context.select((CommentsModel value) => value.comments);
          var orderedComments =
              context.select((CommentsModel value) => value.orderedComments);
          if (isLoading)
            return Center(
              child: CircularProgressIndicator(),
            );
          else if (comments.isEmpty)
            return Center(
              child: Text("No comment"),
            );
          else
            return ListView.builder(
              itemBuilder: (context, index) => _buildCommentItem(index),
              itemCount: orderedComments.length,
            );
        },
      );

  Widget _buildCommentItem(int index) =>
      Builder(builder: (BuildContext context) {
        debugPrint("_buildCommentItem");

        var orderedComment = context
            .select((CommentsModel value) => value.orderedComments)[index];
        var comment = context
            .select((CommentsModel value) => value.comments)[orderedComment];
        var depths = context.select((CommentsModel value) => value.depths);

        return Selector<CommentsModel, List<int>>(
          selector: (_, model) => model.hiddenComments,
          builder: (context, value, child) {
            return value.contains(comment.id)
                ? SizedBox.shrink()
                : Container(
                    margin: EdgeInsets.only(
                      left: (depths[orderedComment] - 1) * 12.0 + 8,
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
                                    onLinkTap:
                                        (url, context, attributes, element) =>
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
                                                value: !comment.kids.any(
                                                    (element) => value
                                                        .contains(element)),
                                                onChanged: (show) => context
                                                    .read<CommentsModel>()
                                                    .toggleCommentVisibility(
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
          },
        );
      });
}
