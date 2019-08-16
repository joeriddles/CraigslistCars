import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";

import 'ItemDetail.dart';
import 'SearchDrawer.dart';

void main() {
//  debugPaintSizeEnabled = true;
  runApp(CraigslistApp());
}

class CraigslistApp extends StatefulWidget {

  static const platform = const MethodChannel("com.example.flutter.dev/craigslist");

  CraigslistApp({Key key}) : super(key: key);

  @override
  _CraigslistAppState createState() => _CraigslistAppState();
}

class _CraigslistAppState extends State<CraigslistApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.purpleAccent,
    ));
    return MaterialApp(
      title: "Craigslist App",
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder> {
        "/": (context) => CraigslistHome(),
        "/item": (context) => ItemDetail(),
      },
    );
  }
}

class CraigslistHome extends StatefulWidget {
  CraigslistHome({Key key}) : super(key: key);

  @override
  _CraigslistHomeState createState() => _CraigslistHomeState();
}

class _CraigslistHomeState extends State<CraigslistHome> {
  bool searchVisible = false;
  IconData searchIcon = Icons.search;

  SearchDrawer drawer;

  Map params = {
    "query":"",
    "seller":"cto",
    "srchType":"false",
    "hasPic":"0",
    "postedToday":"0",
    "bundleDuplicates":"0",
    "searchNearby":"0"
  };

  void onDrawerClosed(Map newParams) {
    setState(() {
      params = newParams;
    });
  }

  @override
  Widget build(BuildContext context) {
    drawer = SearchDrawer(
        params,
        callback: onDrawerClosed
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Craigslist Cars"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  params["query"] = "";
                });
              },
            ),
            SearchIcon(searchIcon,
              setSearchVisible,
              key: UniqueKey(),
            ),
          ],
        ),
        body: Stack (
          children: <Widget>[
            CraigslistItems(params),
            HideableSearchBar(searchVisible, onSearch: onSearch),
          ],
        ),
        drawer: drawer,
      ),
    );
  }

  void setSearchVisible({bool visibility}) {
    setState(() {
      searchVisible = visibility != null
          ? visibility
          : !searchVisible;

      searchIcon = searchVisible
          ? Icons.close
          : Icons.search;
    });
  }

  void onSearch(String query) {
    setState(() {
      params["query"] = query;
      setSearchVisible();
    });
  }

}

class SearchIcon extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onPressed;
  SearchIcon(this.iconData, this.onPressed, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData),
      onPressed: onPressed,
    );
  }
}

class HideableSearchBar extends StatefulWidget {
  final bool visible;
  final void Function(String) onSearch;

  HideableSearchBar(this.visible, {this.onSearch, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HideableSearchBarState();
}

class _HideableSearchBarState extends State<HideableSearchBar> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(192, 255, 255, 255)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  onChanged: (text) {
                    query = text;
                  },
                  textInputAction: TextInputAction.search,
                  onSubmitted: (text) {
                    widget.onSearch(text);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  widget.onSearch(query);
                },
              ),
            ],
          ),
        ),
      ),
      visible: widget.visible,
    );
  }
}

class CraigslistItem extends StatelessWidget {
  final String imageUrl;
  final Map info;
  CraigslistItem(this.info, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(128, 0, 0, 0)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          info["title"],
                          style: TextStyle(color: Color.fromARGB(255, 175, 255, 255)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          info["price"],
                          style: TextStyle(color: Colors.yellowAccent),
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/item',
          arguments: info);
      },
    );
  }

}

Future<List<Map>> fetchCraigslistItems(MethodChannel platform, {Map params}) async {
  List<dynamic> ret = await platform.invokeListMethod("getItems", {"params":params});

  final List<Map> maps = List<Map>();
  for (var obj in ret) {
    maps.add(Map<String,dynamic>.from(obj));
  }

  return maps;
}

class CraigslistItems extends StatelessWidget {
  final Map params;
  CraigslistItems(this.params);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: fetchCraigslistItems(CraigslistApp.platform, params: params),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GridView.builder(
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 4/3,
            ),
            itemBuilder: (context, index) {
              String images = snapshot.data[index]["img"];
              String imgId = images.split(",")[0];
              String imageUrl = imgId.isNotEmpty
                  ? "https://images.craigslist.org/" + imgId + "_600x450.jpg"
                  : "https://picsum.photos/600/";

              return CraigslistItem(snapshot.data[index], imageUrl);
            },
          );
        }
        // If fail to load any images, default to return progress indicator.
        return CircularProgressIndicator();
      },
    );
  }

}

/*
Future<List<Post>> fetchPosts() async {
  final response = await http.get("https://jsonplaceholder.typicode.com/albums/1/photos?_start=0&_limit=100");
  if (response.statusCode == 200) {
    final responseJson = json.decode(response.body);
    final posts = <Post>[];
    for (var item in responseJson) {
      posts.add(Post.fromJson(item));
    }
    return posts;
  } else {
    throw Exception("Failed to load posts.");
  }
}

Future<Post> fetchPost() async {
  final response = await http.get("https://jsonplaceholder.typicode.com/albums/1/photos?_start=0&_limit=1");
  if (response.statusCode == 200) {
    final responseJson = json.decode(response.body);
    return Post.fromJson(responseJson[0]);
  } else {
    throw Exception("Failed to load post.");
  }
}

class PostsView extends StatelessWidget {
  final List<Post> posts;

  PostsView(this.posts);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostView(posts[index]);
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.black,
      ),
    );
  }
}

class PostView extends StatelessWidget {
  final Post post;

  PostView(this.post);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          post.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        post.urlImage,
      ],
    );
  }
}

class Post {
  final int albumId;
  final int id;
  final String title;
  final Uri url;
  final Uri thumbnailUrl;
  final Image urlImage;

  // Braces around arguments mean optional named arguments.
  Post({this.albumId, this.id, this.title, this.url, this.thumbnailUrl, this.urlImage});

  factory Post.fromJson(var json) {
    return Post(
        albumId: json["albumId"],
        id: json["id"],
        title: json["title"],
        url: Uri.parse(json["url"]),
        thumbnailUrl: Uri.parse(json["thumbnailUrl"]),
        urlImage: Image.network(json["url"])
    );
  }
}
*/