import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:yaha/entity/story_entity.dart';
import 'package:yaha/enum/story_type.dart';
import 'package:yaha/model/app_settings_model.dart';
import 'package:yaha/repo/hacker_news_api.dart';

class StoriesModel with ChangeNotifier {
  final AppSettingsModel settingsModel;

  final ScrollController scrollController = ScrollController();

  final api = HackerNewsApi();
  var isLoadingMore = false;
  var isUpdating = false;

  List<int> ids = List.empty();
  List<StoryEntity> cachedStories = List.empty();

  StoryType currentType = StoryType.TOP;

  StoriesModel(this.settingsModel) {
    scrollController.addListener(() {
      if (scrollController.position.pixels + 200 >=
          scrollController.position.maxScrollExtent) {
        loadMoreStories();
      }
    });
  }

  setLoadingMore(bool enabled) {
    isLoadingMore = enabled;
    notifyListeners();
  }

  getNewStories() async {
    if (!isUpdating) {
      isUpdating = true;
      ids = await api.getStories(currentType);
      cachedStories = await fetchStories(ids.sublist(cachedStories.length,
          cachedStories.length + settingsModel.amountStoriesPerLoad));
      isUpdating = false;
      notifyListeners();
    }
  }

  loadMoreStories() async {
    if (!isLoadingMore && !isUpdating) {
      setLoadingMore(true);
      cachedStories = List.from(cachedStories)
        ..addAll(await fetchStories(ids.sublist(cachedStories.length,
            cachedStories.length + settingsModel.amountStoriesPerLoad)));
      setLoadingMore(false);
    }
  }

  Future<List<StoryEntity>> fetchStories(List<int> ids) =>
      Future.wait(ids.map((int e) => api.getStory(e)));

  setType(StoryType e) {
    currentType = e;
    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  onSettingsChanged() {
    debugPrint("StoriesModel: onSettingsChanged");
  }
}
