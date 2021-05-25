import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:yaha/entity/comment_entity.dart';
import 'package:yaha/entity/story_entity.dart';

class HackerNewsApi {
  static final String _baseUrl = "https://hacker-news.firebaseio.com/";

  Future<List<int>> getTopStories() async {
    var response = await http.get(Uri.parse(_baseUrl + 'v0/topstories.json'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      return List<int>.from(result);
    } else
      throw Exception("Failed to load top stories.");
  }

  Future<StoryEntity> getStory(int id) async {
    debugPrint("getting story id=$id");
    var response = await getItem(id);
    if (response.statusCode == 200) {
      return StoryEntity.fromJson(jsonDecode(response.body));
    } else
      throw Exception("Failed to load story");
  }

  Future<CommentEntity> getComment(int id) async {
    debugPrint("getting comment id=$id");
    var response = await getItem(id);
    if (response.statusCode == 200) {
      return CommentEntity.fromJson(jsonDecode(response.body));
    } else
      throw Exception("Failed to load comment");
  }

  Future<http.Response> getItem(int id) => http.get(Uri.parse(_baseUrl + "v0/item/$id.json"));
}
