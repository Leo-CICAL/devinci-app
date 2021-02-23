import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:devinci/extra/themes.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
            noTr ? title : title.tr(),
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(padding: EdgeInsets.only(left: 4, top: 1), child: iconButton),
        ],
      ));
}

Widget BicolorButton({
  @required Widget childA,
  @required Widget childB,
  @required double height,
  @required double width,
  @required Color colorA,
  @required Color colorB,
  @required void Function() onPressed,
  @required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 7, top: 1),
    child: Material(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), side: BorderSide.none),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              height: height,
              width: width / 2 + 8,
              child: Diagonal(
                clipHeight: 16,
                axis: Axis.vertical,
                position: DiagonalPosition.BOTTOM_RIGHT,
                child: Container(
                    height: height,
                    width: width / 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25)),
                      color: colorA,
                    ),
                    child: Stack(children: <Widget>[
                      Positioned(
                        height: height,
                        width: width,
                        child: Center(
                          child: childA,
                        ),
                      )
                    ])),
              ),
            ),
            Positioned(
              top: 0,
              left: width / 2 - 8,
              height: height,
              width: width / 2 + 8,
              child: Diagonal(
                clipHeight: 16,
                axis: Axis.vertical,
                position: DiagonalPosition.TOP_LEFT,
                child: Container(
                  height: height,
                  width: width / 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                    color: colorB,
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                      left: -(width / 2 - 8),
                      height: height,
                      width: width,
                      child: Center(
                        child: childB,
                      ),
                    )
                  ]),
                ),
              ),
            ),
            Positioned.fill(
                child: Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide.none),
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      splashColor:
                          Theme.of(context).accentColor.withOpacity(0.25),
                      onTap: onPressed,
                    ))),
          ],
        ),
      ),
    ),
  );
}
