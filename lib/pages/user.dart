import 'dart:convert';
import 'dart:io';

import 'package:devinci/extra/CommonWidgets.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:ota_update/ota_update.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:recase/recase.dart';
import 'package:share_extend/share_extend.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool show = false;
  bool showUpdate = false;
  String updateTitle = "Une mise à jour est disponible";
  String updateNumber = "";
  String moreText = "en savoir plus";
  String updateContent = "";
  String updateDescription = "";
  String updateSize = "";
  String updateUrl = "";
  double cardSize = 85;
  List<bool> docCardDetail = new List<bool>();
  List<Map<String, dynamic>> docCardData = new List<Map<String, dynamic>>();
  bool showPersonnalData = false;
  var _tapPosition;
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void runBeforeBuild() async {
    for (int i = 0; i < 10; i++) {
      docCardDetail.add(false);
      docCardData.add({"frShowButton": true, "enShowButton": true});
    }
    if (globals.user.documents["certificat"]["annee"] == "") {
      try {
        await globals.user.getDocuments();
      } catch (exception, stacktrace) {
        HttpClient client = new HttpClient();
        HttpClientRequest req = await client.getUrl(
          Uri.parse('https://www.leonard-de-vinci.net/?my=docs'),
        );
        req.followRedirects = false;
        req.cookies.addAll([
          new Cookie('alv', globals.user.tokens["alv"]),
          new Cookie('SimpleSAML', globals.user.tokens["SimpleSAML"]),
          new Cookie('uids', globals.user.tokens["uids"]),
          new Cookie('SimpleSAMLAuthToken',
              globals.user.tokens["SimpleSAMLAuthToken"]),
        ]);
        HttpClientResponse res = await req.close();
        globals.feedbackNotes = await res.transform(utf8.decoder).join();

        await reportError(
            "user.dart | _UserPageState | runBeforeBuild() | user.getDocuments() => $exception",
            stacktrace);
      }
    }
    if (Platform.isAndroid && globals.isConnected) {
      HttpClient client = new HttpClient();
      HttpClientRequest req = await client.getUrl(
        Uri.parse('https://devinci.araulin.tech/ota.json'),
      );
      HttpClientResponse res = await req.close();
      String body = await res.transform(utf8.decoder).join();
      Map<String, dynamic> otas = json.decode(body);
      print("last update : ${otas["last"]}");
      updateNumber = otas["last"];
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      print(version + " :: " + otas["last"]);
      if (version != otas["last"]) {
        updateDescription = otas["otas"][otas["last"]]["description"];
        updateSize = otas["otas"][otas["last"]]["size"];
        print("there is a new version");

        updateUrl = otas["otas"][otas["last"]]["url"];
        String ignoredUpdate = globals.prefs.getString('ignored') ?? "";
        if (ignoredUpdate != updateNumber) {
          setState(() {
            showUpdate = true;
          });
        }
      }
    }
    setState(() {
      show = true;
    });
  }

  ScrollController scroll = new ScrollController();
  ScrollController scrollMark = new ScrollController();

  Future<String> downloadDocuments(String url, String filename) async {
    HttpClient client = new HttpClient();
    Directory directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final String path = directory.path;

    var fileSave = new File(path + '/' + removeDiacritics(filename) + ".pdf");
    if (globals.isConnected) {
      if (await fileSave.exists()) {
        return fileSave.path;
      }
      //check if all tokens are still valid:
      if (globals.user.tokens["SimpleSAML"] != "" &&
          globals.user.tokens["alv"] != "" &&
          globals.user.tokens["uids"] != "" &&
          globals.user.tokens["SimpleSAMLAuthToken"] != "" &&
          globals.user.error == false) {
        globals.user.error = false;
        globals.user.code = 200;

        HttpClientRequest request = await client.getUrl(
          Uri.parse(url),
        );
        //request.followRedirects = false;
        request.cookies.addAll([
          new Cookie('alv', globals.user.tokens["alv"]),
          new Cookie('SimpleSAML', globals.user.tokens["SimpleSAML"]),
          new Cookie('uids', globals.user.tokens["uids"]),
          new Cookie('SimpleSAMLAuthToken',
              globals.user.tokens["SimpleSAMLAuthToken"]),
        ]);
        HttpClientResponse response = await request.close();
        if (response.headers.value("content-type").indexOf("html") > -1) {
          //c'est du html, mais bordel ou est le fichier ?
          String body = await response.transform(utf8.decoder).join();
          print(body);
        } else {
          var bytes = await consolidateHttpClientResponseBytes(response);
          await fileSave.writeAsBytes(bytes);
          return fileSave.path;
        }
      } else {
        globals.user.error = true;
        globals.user.code = 400;
        throw Exception("missing parameters");
      }
    } else if (await fileSave.exists()) {
      return fileSave.path;
    } else {
      final snackBar = SnackBar(content: Text('Non disponible hors ligne'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
      Scaffold.of(globals.currentContext).showSnackBar(snackBar);
    }
    return "";
  }

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
          Clipboard.setData(new ClipboardData(text: data));
          final snackBar = SnackBar(content: Text('$title copié'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          ShareExtend.share(data, "text", sharePanelTitle: title);
        }
      });
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    Widget InfoSection(String main, String second) {
      return Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 38),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              new GestureDetector(
                // This does not give the tap position ...
                onLongPress: () {
                  _showCustomMenu(second, main);
                },

                // Have to remember it on tap-down.
                onTapDown: _storePosition,
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: main + ": ",
                    style: Theme.of(context).textTheme.bodyText1,
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              showPersonnalData ? second : "•" * second.length,
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
      return Padding(
        padding: const EdgeInsets.only(left: 0.0, bottom: 5, right: 0),
        child: Card(
          elevation: globals.currentTheme.isDark() ? 4 : 1,
          //color: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: InkWell(
            onTap: () async {
              for (int i = 0; i < docCardDetail.length; i++) {
                if (i != id) docCardDetail[i] = false;
              }
              if (enUrl != "") {
                setState(() {
                  docCardDetail[id] = !docCardDetail[id];
                });
              } else {
                setState(() {
                  docCardData[id]["frShowButton"] = false;
                });
                print(frUrl);
                ReCase rc = new ReCase('${name}_$subtitle');
                String path = await downloadDocuments(frUrl, rc.camelCase);
                setState(() {
                  docCardData[id]["frShowButton"] = true;
                });
                if (path != "") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PDFScreen(path, name)),
                  );
                }
              }
            }, // handle your onTap here
            child: (enUrl == "" && !docCardData[id]["frShowButton"])
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
                                  child: new Container(
                                    padding: new EdgeInsets.only(right: 10),
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
                                  child: docCardData[id]["frShowButton"]
                                      ? FlatButton(
                                          onPressed: () async {
                                            setState(() {
                                              docCardData[id]["frShowButton"] =
                                                  false;
                                            });
                                            print(frUrl);
                                            ReCase rc =
                                                new ReCase('${name}_$subtitle');
                                            String path =
                                                await downloadDocuments(
                                                    frUrl, rc.camelCase);

                                            setState(() {
                                              docCardData[id]["frShowButton"] =
                                                  true;
                                            });
                                            if (path != "") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PDFScreen(path, name)),
                                              );
                                            }
                                          },
                                          child: Text(enUrl != ""
                                              ? "Français"
                                              : "Ouvrir"),
                                        )
                                      : Container(
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                ),
                                Visibility(
                                  visible: enUrl != "",
                                  child: Expanded(
                                    child: docCardData[id]["enShowButton"]
                                        ? FlatButton(
                                            onPressed: () async {
                                              setState(() {
                                                docCardData[id]
                                                    ["enShowButton"] = false;
                                              });
                                              print(enUrl);
                                              ReCase rc = new ReCase(
                                                  '${name}_${subtitle}_en');
                                              String path =
                                                  await downloadDocuments(
                                                      frUrl, rc.camelCase);

                                              setState(() {
                                                docCardData[id]
                                                    ["enShowButton"] = true;
                                              });
                                              if (path != "") {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PDFScreen(
                                                              path, name)),
                                                );
                                              }
                                            },
                                            child: Text("English"),
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
    return show
        ? CupertinoScrollbar(
            controller: scroll,
            child: ListView(
              controller: scroll,
              children: <Widget>[
                Visibility(
                  visible: showUpdate,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Card(
                      child: Container(
                        height: cardSize,
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 16, top: 12),
                                child: Text(updateTitle,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 0, top: 4),
                                child: CupertinoScrollbar(
                                  controller: scrollMark,
                                  child: Markdown(
                                    data: updateContent,
                                    controller: scrollMark,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      showUpdate = false;
                                      globals.prefs
                                          .setString('ignored', updateNumber);
                                    });
                                  },
                                  child: Text("ignorer"),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          if (moreText == "installer") {
                                            moreText = "updating";
                                            OtaUpdate()
                                                .execute(updateUrl,
                                                    destinationFilename:
                                                        'devinci-${updateNumber.replaceAll(".", "-")}.apk')
                                                .listen(
                                              (OtaEvent event) {
                                                print(
                                                    'EVENT: ${event.status} : ${event.value}');
                                                if (event.status !=
                                                    OtaStatus.DOWNLOADING) {
                                                  setState(() {
                                                    moreText = "installer";
                                                  });
                                                }
                                              },
                                            );
                                          } else {
                                            updateTitle =
                                                "Version $updateNumber";
                                            moreText = "installer";
                                            cardSize = 250;
                                            updateContent =
                                                "Description :\n\n$updateDescription\n\nTaille : **$updateSize**";
                                          }
                                        });
                                      },
                                      child: moreText == "updating"
                                          ? LinearProgressIndicator(
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(
                                                Theme.of(context).accentColor,
                                              ),
                                            )
                                          : Text(
                                              moreText,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                TitleSection("Informations personnelles",
                    iconButton: IconButton(
                        icon: Icon(showPersonnalData
                            ? OMIcons.visibilityOff
                            : OMIcons.visibility),
                        onPressed: () {
                          setState(() {
                            showPersonnalData = !showPersonnalData;
                          });
                        })),
                InfoSection("Identifiant", globals.user.tokens["uids"]),
                InfoSection("Numéro de badge", globals.user.data["badge"]),
                InfoSection("Numéro client", globals.user.data["client"]),
                InfoSection("Id. Administratif", globals.user.data["idAdmin"]),
                InfoSection("INE/BEA", globals.user.data["ine"]),
                TitleSection("Documents"),
                Padding(
                  padding: EdgeInsets.only(top: 12, left: 20, right: 20),
                  child: DocumentTile(
                      "Certificat de scolarité",
                      globals.user.documents["certificat"]["annee"],
                      globals.user.documents["certificat"]["fr_url"],
                      globals.user.documents["certificat"]["en_url"],
                      0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                  child: DocumentTile(
                      "Certificat ImaginR",
                      globals.user.documents["imaginr"]["annee"],
                      globals.user.documents["imaginr"]["url"],
                      "",
                      1),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                  child: DocumentTile(
                      "Calendrier académique",
                      globals.user.documents["calendrier"]["annee"],
                      globals.user.documents["calendrier"]["url"],
                      "",
                      2),
                ),
                new ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: globals.user.documents["bulletins"].length,
                    itemBuilder: (BuildContext ctxt, int i) {
                      return Padding(
                        padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                        child: DocumentTile(
                            globals.user.documents["bulletins"][i]["name"],
                            globals.user.documents["bulletins"][i]["sub"],
                            globals.user.documents["bulletins"][i]["fr_url"],
                            globals.user.documents["bulletins"][i]["en_url"],
                            3 + i),
                      );
                    }),
              ],
            ),
          )
        : Center(child: CupertinoActivityIndicator());
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  String title = "";
  PDFScreen(this.pathPDF, this.title);

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        globals.currentTheme.isDark());
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).scaffoldBackgroundColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        globals.currentTheme.isDark());
    return PDFViewerScaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              //change your color here
              ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: <Widget>[
            IconButton(
              icon: IconTheme(
                data: Theme.of(context).accentIconTheme,
                child: Icon(
                  OMIcons.share,
                ),
              ),
              onPressed: () {
                ShareExtend.share(pathPDF, title);
              },
            ),
          ],
        ),
        path: pathPDF);
  }
}

class ContextEntry extends PopupMenuEntry<int> {
  @override
  double height = 50;
  // height doesn't matter, as long as we are not giving
  // initialValue to showMenu().

  @override
  bool represents(int n) => n == 1 || n == -1;

  @override
  ContextEntryState createState() => ContextEntryState();
}

class ContextEntryState extends State<ContextEntry> {
  void copy() {
    // This is how you close the popup menu and return user selection.
    Navigator.pop<int>(context, 1);
  }

  void share() {
    Navigator.pop<int>(context, -1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 20,
            child: FlatButton(
              onPressed: copy,
              child: Text('Copier'),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 20,
            child: FlatButton(
              onPressed: share,
              child: Text('Partager'),
            ),
          ),
        ),
      ],
    );
  }
}
