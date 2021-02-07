import 'package:devinci/extra/classes.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/pages/logic/user.dart';
import 'package:flutter/material.dart';
//import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:recase/recase.dart';
import 'package:f_logs/f_logs.dart';

Widget InfoSection(String main, String second) {
  return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 38),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            // This does not give the tap position ...
            onLongPress: () {
              showCustomMenu(second, main);
            },
            // Have to remember it on tap-down.
            onTapDown: storePosition,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: main.tr + ': ',
                style: Theme.of(getContext()).textTheme.bodyText1,
                children: <TextSpan>[
                  TextSpan(
                      text: second,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      )),
                ],
              ),
            ),
          ),
        ],
      ));
}

Widget DocumentTile(
    String name, String subtitle, String frUrl, String enUrl, int id) {
  name = name.tr;
  return Padding(
    padding: const EdgeInsets.only(left: 0.0, bottom: 5, right: 0),
    child: Card(
      elevation: globals.currentTheme.isDark() ? 4 : 1,
      //color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () async {
          for (var i = 0; i < docCardDetail.length; i++) {
            if (i != id) docCardDetail[i] = false;
          }
          if (enUrl != '') {
            setState(() {
              docCardDetail[id] = !docCardDetail[id];
            });
          } else {
            setState(() {
              docCardData[id]['frShowButton'] = false;
            });
            FLog.info(
                className: 'UserPage Components',
                methodName: 'DocumentTile',
                text: frUrl);
            var rc = ReCase('${name}_$subtitle');
            var path;
            try {
              path = await downloadDocuments(frUrl, rc.camelCase);
            } catch (e) {
              FLog.info(
                  className: 'UserPage Components',
                  methodName: 'DocumentTile',
                  text: 'needs reconnection');
              Get.snackbar(
                null,
                'reconnecting'.tr,
                duration: const Duration(seconds: 10),
                snackPosition: SnackPosition.BOTTOM,
                borderRadius: 0,
                margin: EdgeInsets.only(
                    left: 8, right: 8, top: 0, bottom: globals.bottomPadding),
              );
              try {
                await globals.user.getTokens();
              } catch (e, stacktrace) {
                FLog.logThis(
                    className: 'DocumentTile',
                    methodName: '',
                    text: 'exception',
                    type: LogLevel.ERROR,
                    exception: Exception(e),
                    stacktrace: stacktrace);
                await reportError(e, stacktrace);
              }
              try {
                path = await downloadDocuments(frUrl, rc.camelCase);
              } catch (exception, stacktrace) {
                FLog.logThis(
                    className: 'DocumentTile',
                    methodName: '',
                    text: 'exception',
                    type: LogLevel.ERROR,
                    exception: Exception(e),
                    stacktrace: stacktrace);
              }
              Get.back();
            }
            setState(() {
              docCardData[id]['frShowButton'] = true;
            });
            if (path != '') {
              await Navigator.push(
                getContext(),
                MaterialPageRoute(builder: (context) => PDFScreen(path, name)),
              );
            }
          }
        }, // handle your onTap here
        child: (enUrl == '' && !docCardData[id]['frShowButton'])
            ? Container(
                height: 65,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                height: docCardDetail[id] ? 102 : 65,
                width: MediaQuery.of(getContext()).size.width,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15.0, top: 10, right: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(right: 10),
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            //Expanded(
                            //child:

                            //),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15.0, top: 4, right: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff787878),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: docCardDetail[id],
                      child: Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: docCardData[id]['frShowButton']
                                  ? TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          docCardData[id]['frShowButton'] =
                                              false;
                                        });
                                        FLog.info(
                                            className: 'UserPage Components',
                                            methodName: 'DocumentTile',
                                            text: frUrl);
                                        var rc = ReCase('${name}_$subtitle');
                                        var path = await downloadDocuments(
                                            frUrl, rc.camelCase);

                                        setState(() {
                                          docCardData[id]['frShowButton'] =
                                              true;
                                        });
                                        if (path != '') {
                                          await Navigator.push(
                                            getContext(),
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PDFScreen(path, name)),
                                          );
                                        }
                                      },
                                      child: Text(
                                          enUrl != '' ? 'Français' : 'open'.tr),
                                    )
                                  : Container(
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    ),
                            ),
                            Visibility(
                              visible: enUrl != '',
                              child: Expanded(
                                child: docCardData[id]['enShowButton']
                                    ? TextButton(
                                        onPressed: () async {
                                          setState(() {
                                            docCardData[id]['enShowButton'] =
                                                false;
                                          });
                                          FLog.info(
                                              className: 'UserPage Components',
                                              methodName: 'DocumentTile',
                                              text: enUrl);
                                          var rc =
                                              ReCase('${name}_${subtitle}_en');
                                          var path = await downloadDocuments(
                                              frUrl, rc.camelCase);

                                          setState(() {
                                            docCardData[id]['enShowButton'] =
                                                true;
                                          });
                                          if (path != '') {
                                            await Navigator.push(
                                              getContext(),
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PDFScreen(path, name)),
                                            );
                                          }
                                        },
                                        child: Text('English'),
                                      )
                                    : Container(
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    ),
  );
}
