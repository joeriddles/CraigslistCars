import "package:flutter/material.dart";

import 'RadioListTileGroup.dart';

class SearchDrawer extends StatefulWidget {
  final Map params;
  final void Function(Map) callback;
  SearchDrawer(this.params, {this.callback});

  @override
  State<StatefulWidget> createState() => _SearchDrawerState();
}

class _SearchDrawerState extends State<SearchDrawer> {
  int selectedSeller;
  Map params;

  final Map sellers = {
    "all":"cta",
    "owner":"cto",
    "dealer":"ctd"
  };

  @override
  Widget build(BuildContext context) {
    params = widget.params;

    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                RadioListTileGroup(
                  sellers,
                  selected: params["seller"],
                  callback: (newValue) {
                    setState(() {
                      params["seller"] = newValue;
                    });
                  },
                ),
                CheckboxListTile(
                  value: params["srchType"] == "true",
                  onChanged: (checked) {
                    setState(() {
                      params["srchType"] = checked
                          ? "true"
                          : "false";
                    });
                  },
                  title: Text("search titles only"),
                ),
                CheckboxListTile(
                  value: params["hasPic"] == "1",
                  onChanged: (checked) {
                    setState(() {
                      params["hasPic"] = checked
                          ? "1"
                          : "0";
                    });
                  },
                  title: Text("has image"),
                ),
                CheckboxListTile(
                  value: params["postedToday"] == "1",
                  onChanged: (checked) {
                    setState(() {
                      params["postedToday"] = checked
                          ? "1"
                          : "0";
                    });
                  },
                  title: Text("posted today"),
                ),
                CheckboxListTile(
                  value: params["bundleDuplicates"] == "1",
                  onChanged: (checked) {
                    setState(() {
                      params["bundleDuplicates"] = checked
                          ? "1"
                          : "0";
                    });
                  },
                  title: Text("bundle duplicates"),
                ),
                CheckboxListTile(
                  value: params["searchNearby"] == "1",
                  onChanged: (checked) {
                    setState(() {
                      params["searchNearby"] = checked
                          ? "1"
                          : "0";
                    });
                  },
                  title: Text("include nearby areas"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: new InputDecoration(
                            hintText: "miles"
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: new InputDecoration(
                            hintText: "from zip"
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            child: RaisedButton(
              child: Text("Save"),
              color: Colors.purpleAccent,
              onPressed: () {
                  // Close drawer -- Let's not do this, it's very unsmooth in the UI.
//                Navigator.pop(context);

                widget.callback(params);
              },
            ),
            width: double.infinity,
          )
        ],
      ),
    );
  }
}