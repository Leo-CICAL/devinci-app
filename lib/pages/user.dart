import 'dart:convert';
import 'dart:io';
import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/extra/classes.dart';
import 'package:devinci/pages/timechef.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/services.dart';
import 'package:recase/recase.dart';
import 'package:share_extend/share_extend.dart';
import 'package:sembast/sembast.dart';
import 'package:easy_localization/easy_localization.dart';

Map<String, dynamic> documents;

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool show = false;
  bool pad = false;
  double cardSize = 85;
  List<bool> docCardDetail = <bool>[];
  List<Map<String, dynamic>> docCardData = <Map<String, dynamic>>[];
  var _tapPosition;
  @override
  void initState() {
    super.initState();
    globals.isLoading.addListener(() async {
      if (globals.isLoading.state(4)) {
        try {
          await globals.user.getDocuments();
        } catch (exception, stacktrace) {
          var client = HttpClient();
          var req = await client.getUrl(
            Uri.parse('https://www.leonard-de-vinci.net/?my=docs'),
          );
          req.followRedirects = false;
          req.cookies.addAll([
            Cookie('alv', globals.user.tokens['alv']),
            Cookie('SimpleSAML', globals.user.tokens['SimpleSAML']),
            Cookie('uids', globals.user.tokens['uids']),
            Cookie('SimpleSAMLAuthToken',
                globals.user.tokens['SimpleSAMLAuthToken']),
          ]);
          var res = await req.close();
          globals.feedbackNotes = await res.transform(utf8.decoder).join();

          await reportError(
              'user.dart | _UserPageState | runBeforeBuild() | user.getDocuments() => $exception',
              stacktrace);
        }
        if (mounted) {
          setState(() {
            show = true;
          });
        }
        globals.isLoading.setState(4, false);
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void runBeforeBuild() async {
    for (var i = 0; i < 10; i++) {
      docCardDetail.add(false);
      docCardData.add({'frShowButton': true, 'enShowButton': true});
    }

    if (globals.user.documents['certificat']['annee'] == '') {
      documents = await globals.store.record('documents').get(globals.db);
      if (documents == null) {
        try {
          await globals.user.getDocuments();
        } catch (exception, stacktrace) {
          var client = HttpClient();
          var req = await client.getUrl(
            Uri.parse('https://www.leonard-de-vinci.net/?my=docs'),
          );
          req.followRedirects = false;
          req.cookies.addAll([
            Cookie('alv', globals.user.tokens['alv']),
            Cookie('SimpleSAML', globals.user.tokens['SimpleSAML']),
            Cookie('uids', globals.user.tokens['uids']),
            Cookie('SimpleSAMLAuthToken',
                globals.user.tokens['SimpleSAMLAuthToken']),
          ]);
          var res = await req.close();
          globals.feedbackNotes = await res.transform(utf8.decoder).join();

          await reportError(
              'user.dart | _UserPageState | runBeforeBuild() | user.getDocuments() => $exception',
              stacktrace);
        }
      }
      if (mounted) {
        setState(() {
          show = true;
        });
      }
      await Future.delayed(Duration(milliseconds: 200));
      globals.isLoading.setState(4, true);
    } else {
      if (mounted) {
        setState(() {
          show = true;
        });
      }
    }
  }

  ScrollController scroll = ScrollController();

  void _showCustomMenu(String data, String title) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    showMenu(
            context: context,
            items: <PopupMenuEntry<int>>[ContextEntry()],
            position: RelativeRect.fromRect(
                _tapPosition & Size(40, 40), // smaller rect, the touch area
                Offset.zero & overlay.size // Bigger rect, the entire screen
                ))
        // This is how you handle user selection
        .then<void>((int delta) {
      // delta would be null if user taps on outside the popup menu
      // (causing it to close without making selection)
      if (delta == null) return;

      setState(() {
        if (delta == 1) {
          Clipboard.setData(ClipboardData(text: data));
          final snackBar = SnackBar(content: Text('copied').tr(args: [title]));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          ShareExtend.share(data, 'text', sharePanelTitle: title);
        }
      });
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    Widget InfoSection(String main, String second) {
      return Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 38),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                // This does not give the tap position ...
                onLongPress: () {
                  _showCustomMenu(second, main);
                },

                // Have to remember it on tap-down.
                onTapDown: _storePosition,
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: main.tr() + ': ',
                    style: Theme.of(context).textTheme.bodyText1,
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

    // ignore: non_constant_identifier_names
    Widget DocumentTile(
        String name, String subtitle, String frUrl, String enUrl, int id) {
      name = name.tr();
      return Padding(
        padding: const EdgeInsets.only(left: 0.0, bottom: 5, right: 0),
        child: Card(
          elevation: globals.currentTheme.isDark() ? 4 : 1,
          //color: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                l(frUrl);
                var rc = ReCase('${name}_$subtitle');
                var path = await downloadDocuments(frUrl, rc.camelCase);
                setState(() {
                  docCardData[id]['frShowButton'] = true;
                });
                if (path != '') {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PDFScreen(path, name)),
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
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, top: 10, right: 4),
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
                          padding: const EdgeInsets.only(
                              left: 15.0, top: 4, right: 4),
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
                                            l(frUrl);
                                            var rc =
                                                ReCase('${name}_$subtitle');
                                            var path = await downloadDocuments(
                                                frUrl, rc.camelCase);

                                            setState(() {
                                              docCardData[id]['frShowButton'] =
                                                  true;
                                            });
                                            if (path != '') {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PDFScreen(path, name)),
                                              );
                                            }
                                          },
                                          child: Text(enUrl != ''
                                              ? 'Français'
                                              : 'open'.tr()),
                                        )
                                      : Container(
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                ),
                                Visibility(
                                  visible: enUrl != '',
                                  child: Expanded(
                                    child: docCardData[id]['enShowButton']
                                        ? TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                docCardData[id]
                                                    ['enShowButton'] = false;
                                              });
                                              l(enUrl);
                                              var rc = ReCase(
                                                  '${name}_${subtitle}_en');
                                              var path =
                                                  await downloadDocuments(
                                                      frUrl, rc.camelCase);

                                              setState(() {
                                                docCardData[id]
                                                    ['enShowButton'] = true;
                                              });
                                              if (path != '') {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PDFScreen(
                                                              path, name)),
                                                );
                                              }
                                            },
                                            child: Text('English'),
                                          )
                                        : Container(
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator()),
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

    globals.currentContext = context;
    if (show) {
      return CupertinoScrollbar(
        controller: scroll,
        child: ListView(
          controller: scroll,
          children: <Widget>[
            ExpansionTile(
              title: Text(
                'private_info',
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ).tr(),
              children: <Widget>[
                InfoSection('id', globals.user.tokens['uids']),
                InfoSection('#card', globals.user.data['badge']),
                InfoSection('#client', globals.user.data['client']),
                InfoSection('id_admin', globals.user.data['idAdmin']),
                InfoSection('INE', globals.user.data['ine']),
              ],
              onExpansionChanged: (expanded) {
                setState(() {
                  pad = expanded;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: (pad ? 20 : 0)),
              child: TimeChefPage(),
            ),
            TitleSection('documents',
                padding: EdgeInsets.only(left: 16, top: 20)),
            Padding(
              padding: EdgeInsets.only(top: 12, left: 20, right: 20),
              child: DocumentTile(
                  'school_certificate',
                  (globals.user.documents['certificat']['annee'] != ''
                      ? globals.user.documents
                      : documents)['certificat']['annee'],
                  (globals.user.documents['certificat']['annee'] != ''
                      ? globals.user.documents
                      : documents)['certificat']['fr_url'],
                  (globals.user.documents['certificat']['annee'] != ''
                      ? globals.user.documents
                      : documents)['certificat']['en_url'],
                  0),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0, left: 20, right: 20),
              child: DocumentTile(
                  'imaginr_certificate',
                  (globals.user.documents['certificat']['annee'] != ''
                      ? globals.user.documents
                      : documents)['imaginr']['annee'],
                  (globals.user.documents['certificat']['annee'] != ''
                      ? globals.user.documents
                      : documents)['imaginr']['url'],
                  '',
                  1),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0, left: 20, right: 20),
              child: DocumentTile(
                  'academic_calendar',
                  (globals.user.documents['certificat']['annee'] != ''
                      ? globals.user.documents
                      : documents)['calendrier']['annee'],
                  (globals.user.documents['certificat']['annee'] != ''
                      ? globals.user.documents
                      : documents)['calendrier']['url'],
                  '',
                  2),
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: (globals.user.documents['certificat']['annee'] != ''
                        ? globals.user.documents
                        : documents)['bulletins']
                    .length,
                itemBuilder: (BuildContext ctxt, int i) {
                  return Padding(
                    padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                    child: DocumentTile(
                        (globals.user.documents['certificat']['annee'] != ''
                            ? globals.user.documents
                            : documents)['bulletins'][i]['name'],
                        (globals.user.documents['certificat']['annee'] != ''
                            ? globals.user.documents
                            : documents)['bulletins'][i]['sub'],
                        (globals.user.documents['certificat']['annee'] != ''
                            ? globals.user.documents
                            : documents)['bulletins'][i]['fr_url'],
                        (globals.user.documents['certificat']['annee'] != ''
                            ? globals.user.documents
                            : documents)['bulletins'][i]['en_url'],
                        3 + i),
                  );
                }),
          ],
        ),
      );
    } else {
      return Center(child: CupertinoActivityIndicator());
    }
  }
}
