import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yaha/model/story_entity.dart';

class HackerNewsApi {
  final String _baseUrl = "https://hacker-news.firebaseio.com/";

  Future<List<int>> getTopStories() async {
    var response = await http.get(_baseUrl + 'v0/topstories.json');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      return List<int>.from(result);
    } else
      throw Exception("Failed to load top stories.");
  }

  Future<StoryEntity> getStory(int id) async {
    var response = await http.get(_baseUrl + "v0/item/$id.json");
    if (response.statusCode == 200) {
      return StoryEntity.fromJson(jsonDecode(response.body));
    } else
      throw Exception("Failed to load story");
  }
}
