import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaha/entity/comment_entity.dart';
import 'package:yaha/repo/hacker_news_api.dart';

class CommentsModel with ChangeNotifier {
  final api = HackerNewsApi();

  final comments = Map<int, CommentEntity>();
  final depths = Map<int, int>();
  final Map<int, List<int>> _tempOrdering = Map();
  final List<int> orderedComments = List.empty(growable: true);
  List<int> hiddenComments = List.empty(growable: true);
  List<int> _tempHiddenComments = List.empty(growable: true);

  var isLoading = false;

  CommentsModel(int storyId) {
    debugPrint("creating CommentsModel(storyId=$storyId) hashCode=$hashCode");
    loadComments(storyId);
  }

  setLoading(bool enabled) {
    isLoading = enabled;
    notifyListeners();
  }

  Future<void> loadComments(int storyId) async {
    debugPrint("loadComments parentId=$storyId");
    setLoading(true);
    var storyEntity = await api.getStory(storyId);
    loadCommentWithChildren(1, storyEntity.id, storyEntity.kids).listen(null,
        onDone: () {
      orderComments(storyId);
      debugPrint("depth=" + depths.toString());
      debugPrint("orderedComments=" + orderedComments.toString());
      debugPrint("comments=" + comments.toString());
      setLoading(false);
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
            .flatMap((value) => api.getComment(value).asStream())
            .doOnData((event) {
              debugPrint(
                  "_api.getComment(value).asStream()).doOnData((event) = $event");
              if (event.id == 27204890) print("here");
              comments[event.id] = event;
              depths[event.id] = depth;
            })
            .flatMap((event) =>
                loadCommentWithChildren(depth + 1, event.id, event.kids));
  }

  orderComments(int parentId) {
    orderedComments.clear();
    var list = _tempOrdering.entries.toList();
    list.sort((a, b) => a.key.compareTo(b.key));
    orderedComments.addAll(list.fold<List<int>>(List.empty(growable: true),
        (previousValue, element) {
      if (element.key == parentId)
        previousValue.addAll(element.value);
      else
        previousValue.insertAll(
            previousValue.indexOf(element.key) + 1, element.value);
      return previousValue;
    }));
  }

  toggleCommentVisibility(int id, bool show) {
    _tempHiddenComments = List.from(hiddenComments);
    _toggleCommentVisibility(id, show);
    hiddenComments = _tempHiddenComments;
    notifyListeners();
  }

  _toggleCommentVisibility(int id, bool show) {
    debugPrint("id=$id show=$show");
    var kids = comments[id].kids;
    if (kids != null)
      kids.forEach((e) {
        show ? _tempHiddenComments.remove(e) : _tempHiddenComments.add(e);
        _toggleCommentVisibility(e, show);
      });
  }

  @override
  void dispose() {
    debugPrint("disposing CommentsModel hashCode=$hashCode");
    comments.clear();
    super.dispose();
  }
}
