import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yaha/enum/story_type.dart';
import 'package:yaha/page/stories_page.dart';

class HomePage extends StatefulWidget {
  final String title = "YAHA";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: _buildActions(context),
      ),
      body: buildPageView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: buildBottomNavBarItems(),
        onTap: (index) => _pageController.jumpToPage(index),
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

  Widget buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) => changePage(index),
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        StoriesPage(type: StoryType.NEW),
        StoriesPage(type: StoryType.TOP),
        StoriesPage(type: StoryType.BEST),
      ],
    );
  }

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          icon: new Icon(Icons.new_releases), title: new Text('New')),
      BottomNavigationBarItem(
        icon: new Icon(Icons.vertical_align_top),
        title: new Text('Top'),
      ),
      BottomNavigationBarItem(icon: Icon(Icons.check), title: Text('Best'))
    ];
  }

  void changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}
