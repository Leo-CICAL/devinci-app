import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

// ignore: non_constant_identifier_names
Widget TitleSection(String title,
    {Widget iconButton = const SizedBox.shrink(),
    EdgeInsets padding = const EdgeInsets.only(top: 20.0, left: 20),
    bool noTr = false}) {
  return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            noTr ? title : title.tr,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(padding: EdgeInsets.only(left: 4, top: 1), child: iconButton),
        ],
      ));
}
