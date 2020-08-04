import 'package:flutter/material.dart';

Widget TitleSection(String title,
    {Widget iconButton = const SizedBox.shrink(),
    EdgeInsets padding = const EdgeInsets.only(top: 20.0, left: 20)}) {
  return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(padding: EdgeInsets.only(left: 4, top: 1), child: iconButton),
        ],
      ));
}
