import 'package:flutter/material.dart';

class RadioListTileGroup extends StatefulWidget {
  final Map items;
  final String selected;
  final Function callback;

  RadioListTileGroup(this.items, {this.selected, this.callback, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RadioListTileGroupState();

}

class _RadioListTileGroupState extends State<RadioListTileGroup> {
  @override
  Widget build(BuildContext context) {
    String selected = widget.selected;
    List<Widget> tiles = [];
    
    widget.items.forEach((k,v) {
      tiles.add(RadioListTile(
        title: Text(k),
        value: v,
        groupValue: selected,
        onChanged: (newValue) {
          widget.callback(v);
        },
        selected: v == selected,
      ));
    });
    
    return Column(
      children: tiles,
    );
  }
}