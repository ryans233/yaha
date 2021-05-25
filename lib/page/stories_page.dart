import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaha/entity/story_entity.dart';
import 'package:yaha/enum/story_type.dart';
import 'package:yaha/model/stories_model.dart';

class StoriesPage extends StatefulWidget {
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final keyRefreshIndicator = new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext _) => StoriesModel(),
      builder: (context, child) {
        var isLoadingMore =
            context.select((StoriesModel value) => value.isLoadingMore);
        var cachedStories =
            context.select((StoriesModel value) => value.cachedStories);
        var currentType =
            context.select((StoriesModel value) => value.currentType);

        return Scaffold(
            appBar: AppBar(
              title: DropdownButton(
                onChanged: (value) {
                  context.read<StoriesModel>().setType(value);
                  keyRefreshIndicator.currentState.show();
                },
                value: currentType,
                underline: SizedBox.shrink(),
                icon: SizedBox.shrink(),
                items: StoryType.values
                    .map(
                      (e) => DropdownMenuItem<StoryType>(
                        child: Text(
                          e.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                        value: e,
                      ),
                    )
                    .toList(),
              ),
              actions: _buildActions(context),
            ),
            body: RefreshIndicator(
              key: keyRefreshIndicator,
              onRefresh: () => context.read<StoriesModel>().getNewStories(),
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: context.watch<StoriesModel>().scrollController,
                itemCount: cachedStories.length + 1,
                itemBuilder: (context, index) {
                  if (cachedStories.isEmpty)
                    return Container(
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.accessibility,
                              size: 64,
                            ),
                            Text(
                              "Pull to refresh",
                              style: TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 100),
                    );
                  else if (index < cachedStories.length) {
                    return buildStoryListItem(cachedStories[index]);
                  } else if (isLoadingMore) {
                    return Container(
                      height: 50.0,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else
                    return SizedBox.shrink();
                },
              ),
            ));
      },
    );
  }

  Widget buildStoryListItem(StoryEntity item) {
    return Card(
      child: InkWell(
        child: Hero(
          child: Material(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Text(
                        item.by.toString(),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      Text(
                        (item.descendants == null || item.descendants == 0)
                            ? ""
                            : item.descendants.toString(),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          tag: item.id,
        ),
        onTap: () => Navigator.pushNamed(context, '/story', arguments: item),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.settings),
        color: Colors.white,
        tooltip: "Open settings page",
        onPressed: () => Navigator.pushNamed(context, "/settings"),
      ),
    ];
  }

}
