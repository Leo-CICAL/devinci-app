import 'dart:convert';
import 'dart:io';
import 'package:devinci/extra/CommonWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sembast/sembast.dart';

Map<String, dynamic> notes;

class NotesPage extends StatefulWidget {
  NotesPage({Key key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool show = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String currentSemester = "s1";
  bool changed = false;

  void initState() {
    super.initState();
    globals.isLoading.addListener(() async {
      print("isLoading2");
      if (globals.isLoading.state(1)) {
        if (!globals.noteLocked) {
          globals.noteLocked = true;
          try {
            await globals.user.getNotes(load: true);
          } catch (exception, stacktrace) {
            if (globals.isConnected) {
              HttpClient client = new HttpClient();
              HttpClientRequest req = await client.getUrl(
                Uri.parse('https://www.leonard-de-vinci.net/?my=notes'),
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
                  "notes.dart | _NotesPageState | runBeforeBuild() | user.getNotes() => $exception",
                  stacktrace);
            }
          }
          globals.noteLocked = false;
        }
        if (mounted) {
          setState(() {
            if (!globals.user.notes["s2"].isEmpty && !changed)
              currentSemester = "s2";
          });
        }
        globals.isLoading.setState(1, false);
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void changeCurrentSemester(String sem) {
    setState(() {
      currentSemester = sem;
      if (!changed) changed = true;
    });
  }

  void _onRefresh() async {
    print("refresh");
    // monitor network fetch
    if (!globals.noteLocked) {
      globals.noteLocked = true;
      try {
        await globals.user.getNotes(load: true);
      } catch (exception, stacktrace) {
        if (globals.isConnected) {
          HttpClient client = new HttpClient();
          HttpClientRequest req = await client.getUrl(
            Uri.parse('https://www.leonard-de-vinci.net/?my=notes'),
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
              "notes.dart | _NotesPageState | runBeforeBuild() | user.getNotes() => $exception",
              stacktrace);
        }
      }
      globals.noteLocked = false;
    }
    if (mounted) {
      setState(() {
        if (!globals.user.notes["s2"].isEmpty && !changed)
          currentSemester = "s2";
        _refreshController.refreshCompleted();
      });
    }
  }

  void runBeforeBuild() async {
    print(globals.user.notesFetched);
    if (!globals.user.notesFetched) {
      notes = await globals.store.record('notes').get(globals.db)
          as Map<String, dynamic>;
      if (notes == null) {
        //il n'existe pas de backup hors connexion des notes
        try {
          await globals.user.getNotes(load: true);
        } catch (exception, stacktrace) {
          if (globals.isConnected) {
            HttpClient client = new HttpClient();
            HttpClientRequest req = await client.getUrl(
              Uri.parse('https://www.leonard-de-vinci.net/?my=notes'),
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
                "notes.dart | _NotesPageState | runBeforeBuild() | user.getNotes() => $exception",
                stacktrace);
          }
        }
      }
      if (mounted)
        setState(() {
          if (!globals.user.notes["s2"].isEmpty && !changed)
            currentSemester = "s2";
          show = true;
        });
      globals.user.notes.copy(notes);

      if (!globals.noteLocked) {
        if (globals.user.notesFetched) {
          if (mounted)
            setState(() {
              if (!globals.user.notes["s2"].isEmpty && !changed)
                currentSemester = "s2";
              show = true;
            });
        } else {
          globals.isLoading.setState(1, true);
        }
      } else {
        globals.isLoading.setState(1, true);
      }
    } else {
      setState(() {
        if (!globals.user.notes["s2"].isEmpty && !changed)
          currentSemester = "s2";
        show = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;

    // ignore: non_constant_identifier_names
    Widget SemestreSelection(String sem, String subtitle) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
              left: sem == "s1" ? 20.0 : 10.0,
              top: 0,
              right: sem == "s2" ? 20.0 : 10.0),
          child: Card(
            elevation: globals.currentTheme.isDark() ? 4 : 2,
            color: Theme.of(context).cardColor,
            shape: currentSemester == sem
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: new BorderSide(
                        color: Theme.of(context).accentColor, width: 2.0))
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
            child: InkWell(
              onTap: () {
                changeCurrentSemester(sem);
              }, // handle your onTap here
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 6, right: 0),
                    child: Text(
                      sem.toUpperCase(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0.0, top: 3, right: 0, bottom: 14),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                          color: globals.currentTheme.isDark()
                              ? Color(0xffE1E2E1)
                              : Color(0xffACACAC),
                          fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ignore: non_constant_identifier_names
    Widget MatiereTile(int i, int j) {
      return Padding(
        padding: const EdgeInsets.only(left: 0.0, bottom: 5, right: 0),
        child: Card(
            elevation: globals.currentTheme.isDark() ? 4 : 2,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: InkWell(
              onTap: globals.user
                      .notes[currentSemester][i]["matieres"][j]['notes'].isEmpty
                  ? null
                  : () => setState(() {
                        if (globals.user.notesFetched) {
                          globals.user.notes[currentSemester][i]["matieres"][j]
                                  ["c"] =
                              !globals.user.notes[currentSemester][i]
                                  ["matieres"][j]["c"];
                        } else {
                          notes[currentSemester][i]["matieres"][j]["c"] =
                              !notes[currentSemester][i]["matieres"][j]["c"];
                        }
                      }), // handle your onTap here
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, top: 10, right: 0, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: new Container(
                              padding: new EdgeInsets.only(right: 12),
                              child: Text(
                                removeGarbage(globals.user.notesFetched
                                    ? globals.user.notes[currentSemester][i]
                                        ["matieres"][j]["matiere"]
                                    : notes[currentSemester][i]["matieres"][j]
                                        ["matiere"]),
                                //overflow: TextOverflow.ellipsis,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Text(
                              getMatMoy(globals.user.notesFetched
                                          ? globals.user.notes[currentSemester]
                                              [i]["matieres"][j]
                                          : notes[currentSemester][i]
                                              ["matieres"][j]) ==
                                      null
                                  ? ""
                                  : getMatMoy(globals.user.notesFetched
                                          ? globals.user.notes[currentSemester]
                                              [i]["matieres"][j]
                                          : notes[currentSemester][i]
                                              ["matieres"][j])
                                      .toString(),
                              style: new TextStyle(
                                  color: (getMatMoy(globals.user.notesFetched
                                                  ? globals.user
                                                          .notes[currentSemester]
                                                      [i]["matieres"][j]
                                                  : notes[currentSemester][i]
                                                      ["matieres"][j]) ??
                                              11) >=
                                          10
                                      ? Theme.of(context).accentColor
                                      : getMatMoy(globals.user.notesFetched ? globals.user.notes[currentSemester][i]["matieres"][j] : notes[currentSemester][i]["matieres"][j]) ==
                                              0
                                          ? Color(0xffCA3E47)
                                          : (globals.currentTheme.isDark()
                                              ? Color(0xffFFDE03)
                                              : Color(0xffFF8A5C)),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: globals
                                      .user
                                      .notes[currentSemester][i]["matieres"][j]
                                          ['notes']
                                      .isEmpty
                                  ? SizedBox.shrink()
                                  : Icon((globals.user.notesFetched
                                          ? globals.user.notes[currentSemester]
                                              [i]["matieres"][j]["c"]
                                          : notes[currentSemester][i]
                                              ["matieres"][j]["c"])
                                      ? Icons.expand_more
                                      : Icons.expand_less),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      );
    }

    // ignore: non_constant_identifier_names
    Widget NoteTile(int i, int j, int y) {
      return Visibility(
        visible: globals.user.notesFetched
            ? !globals.user.notes[currentSemester][i]["matieres"][j]["c"]
            : !notes[currentSemester][i]["matieres"][j]["c"],
        //true,
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, bottom: 5, right: 0),
          child: Card(
            elevation: globals.currentTheme.isDark() ? 4 : 1,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              height: 65,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15.0, top: 10, right: 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: new Container(
                              padding: new EdgeInsets.only(right: 10),
                              child: Text(
                                removeGarbage(globals.user.notesFetched
                                    ? globals.user.notes[currentSemester][i]
                                        ["matieres"][j]["notes"][y]["nom"]
                                    : notes[currentSemester][i]["matieres"][j]
                                        ["notes"][y]["nom"]),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: (globals.user.notesFetched
                                              ? globals.user.notes[
                                                          currentSemester][i]
                                                      ["matieres"][j]["notes"]
                                                  [y]["note"]
                                              : notes[currentSemester][i]
                                                      ["matieres"][j]["notes"]
                                                  [y]["note"]) ==
                                          null
                                      ? SizedBox.shrink()
                                      : Text(
                                          (globals.user.notesFetched
                                                  ? globals.user.notes[currentSemester]
                                                          [i]["matieres"][j]
                                                      ["notes"][y]["note"]
                                                  : (notes[currentSemester][i]
                                                                      ["matieres"]
                                                                  [j]["notes"]
                                                              [y]["note"] ==
                                                          0.12345
                                                      ? "Absence"
                                                      : notes[currentSemester]
                                                              [i]["matieres"][j]
                                                          ["notes"][y]["note"]))
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: (globals.user.notesFetched
                                                        ? globals.user.notes[currentSemester]
                                                                [i]["matieres"][j]
                                                            ["notes"][y]["note"]
                                                        : notes[currentSemester]
                                                                        [i]
                                                                    ["matieres"]
                                                                [j]["notes"][y]
                                                            ["note"]) >=
                                                    10
                                                ? Theme.of(context).accentColor
                                                : ((globals.user.notesFetched ? globals.user.notes[currentSemester][i]["matieres"][j]["notes"][y]["note"] : notes[currentSemester][i]["matieres"][j]["notes"][y]["note"]) == 0
                                                    ? Color(0xffCA3E47)
                                                    : (globals.currentTheme.isDark()
                                                        ? Color(0xffFFDE03)
                                                        : Color(0xffFF8A5C))),
                                          ),
                                        )))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: RichText(
                          text: TextSpan(
                            text: (globals.user.notesFetched
                                        ? globals.user.notes[currentSemester][i]
                                            ["matieres"][j]["notes"][y]["noteP"]
                                        : notes[currentSemester][i]["matieres"]
                                            [j]["notes"][y]["noteP"]) ==
                                    null
                                ? ''
                                : 'moy. de la promo : ',
                            style: TextStyle(
                                color: Color(0xff787878), fontSize: 12),
                            children: <TextSpan>[
                              TextSpan(
                                  text: (globals.user.notesFetched
                                              ? globals.user.notes[currentSemester][i]["matieres"]
                                                  [j]["notes"][y]["noteP"]
                                              : notes[currentSemester][i]["matieres"]
                                                  [j]["notes"][y]["noteP"]) ==
                                          null
                                      ? ''
                                      : (globals.user.notesFetched
                                              ? globals.user.notes[currentSemester]
                                                      [i]["matieres"][j]
                                                  ["notes"][y]["noteP"]
                                              : notes[currentSemester][i]["matieres"]
                                                  [j]["notes"][y]["noteP"])
                                          .toString(),
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
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

    return show
        ? CupertinoScrollbar(
            child: SmartRefresher(
              enablePullDown: true,
              header: ClassicHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  TitleSection("Semestres"),

                  Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: <Widget>[
                          SemestreSelection("s1", "Sept. - Janvier"),
                          SemestreSelection("s2", "Janvier - Juin")
                        ],
                      )),

                  TitleSection("Notes"),

                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                    child: new ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: globals.user.notesFetched
                          ? globals.user.notes[currentSemester].length
                          : notes[currentSemester].length,
                      itemBuilder: (BuildContext ctxt, int i) {
                        return new ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          scrollDirection: Axis.vertical,
                          itemCount: globals.user.notesFetched
                              ? globals.user
                                  .notes[currentSemester][i]["matieres"].length
                              : notes[currentSemester][i]["matieres"].length,
                          itemBuilder: (BuildContext ctxt, int j) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                MatiereTile(i, j),
                                new ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  scrollDirection: Axis.vertical,
                                  itemCount: globals.user.notesFetched
                                      ? globals
                                          .user
                                          .notes[currentSemester][i]["matieres"]
                                              [j]["notes"]
                                          .length
                                      : notes[currentSemester][i]["matieres"][j]
                                              ["notes"]
                                          .length,
                                  itemBuilder: (BuildContext ctxt, int y) {
                                    return NoteTile(i, j, y);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  //!SECTION
                ],
              ),
            ),
          )
        : Center(
            child: CupertinoActivityIndicator(),
          );
  }
}
