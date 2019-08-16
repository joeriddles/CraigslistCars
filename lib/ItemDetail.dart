import "dart:async";

import "package:flutter/material.dart";
import 'package:transparent_image/transparent_image.dart';
import "package:flutter/services.dart";

import 'package:flutter_html/flutter_html.dart';

import 'main.dart';

class ItemDetail extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  String selectedImageUrl;
  Future fetchItemFuture;
  PageController imageController;

  @override
  Widget build(BuildContext context) {
    final Map itemInfo = ModalRoute.of(context).settings.arguments;

    if (fetchItemFuture == null) {
      fetchItemFuture = fetchCraigslistItem(CraigslistApp.platform, itemInfo['itemUrl']);
      imageController = PageController();
    }

    String images = itemInfo["img"];
    List<String> imgIds = images.split(",");

    selectedImageUrl = selectedImageUrl == null
        ? imgIds[0]
        : selectedImageUrl;

    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Card(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                child: Column(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 4/3,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imgIds.length,
                          physics: PageScrollPhysics(),
                          itemBuilder: (context, index) {
                            return AspectRatio(
                              aspectRatio: 4/3,
                              child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: "https://images.craigslist.org/" + imgIds[index] + "_600x450.jpg",
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                          controller: imageController,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          BoxDecoration border;
                          if (imgIds[index] == selectedImageUrl) {
                            border = BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: Colors.purpleAccent
                                )
                            );
                          }

                          return GestureDetector(
                            child: Container(
                              child: Image.network("https://images.craigslist.org/" + imgIds[index] + "_50x50c.jpg"),
                              decoration: border,
                            ),
                            onTap: () {
                              setState(() {
                                selectedImageUrl = imgIds[index];
                                imageController.animateToPage(
                                  index,
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.decelerate
                                );
                              });
                            },
                          );
                        },
                        itemCount: imgIds.length,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                        child: Text(
                          itemInfo['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 0, 8, 4),
                        child: Text(
                          itemInfo['price'],
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.red
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder(
                          future: fetchItemFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map data = snapshot.data;
                              if (data.containsKey('date'))
                                return Text(data['date']);
                            }
                            return Text('');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder(
              future: fetchItemFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map data = snapshot.data;
                  return chipsFromItem(data);
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map> fetchCraigslistItem(MethodChannel platform, String itemUrl) async {
  return await platform.invokeMapMethod("getItem", {"itemUrl":itemUrl});
}

Widget chipsFromItem(Map data) {
  List<Widget> chips = [AttributeChip(data['title'])];

  for (var item in data.entries) {
    if (item.key != 'postingbody' && item.key != 'title') {
      chips.add(AttributeChip(item.value));
    }
  }

  return Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Wrap(
          children: chips,
          spacing: 2,
          runSpacing: 2,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Html(
          data: data['postingbody'],
        ),
      ),
    ],
  );
}

class AttributeChip extends StatelessWidget {
  final String text;
  AttributeChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(text),
      ),
    );
  }

}