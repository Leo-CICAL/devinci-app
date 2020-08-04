import 'dart:convert';
import 'dart:io';
import 'package:devinci/extra/CommonWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';

class AbsencesPage extends StatefulWidget {
  AbsencesPage({Key key}) : super(key: key);

  @override
  _AbsencesPageState createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  bool show = false;

  void runBeforeBuild() async {
    //print(globals.user.absences["liste"]);
    if (!globals.user.absences["done"]) {
      try {
        await globals.user.getAbsences();
      } catch (exception, stacktrace) {
        HttpClient client = new HttpClient();
        HttpClientRequest req = await client.getUrl(
          Uri.parse('https://www.leonard-de-vinci.net/?my=abs'),
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
            "absences.dart | _AbsencesPageState | runBeforeBuild() | user.getAbsences() => $exception",
            stacktrace);
      }

      setState(() {
        show = true;
      });
    } else {
      setState(() {
        show = true;
      });
    }
  }

  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;

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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 6, right: 0),
                  child: Text(
                    sem.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 0.0, top: 3, right: 0, bottom: 14),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Color(0xffE1E2E1)
                            : Color(0xffACACAC),
                        fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    Widget AbsenceTile(int i) {
      Duration duration = Duration(
          hours: int.parse(
              globals.user.absences["liste"][i]["duree"].split(":")[0]),
          minutes: int.parse(
              globals.user.absences["liste"][i]["duree"].split(":")[1]),
          seconds: int.parse(
              globals.user.absences["liste"][i]["duree"].split(":")[2]));
      List<String> jours = globals.user.absences["liste"][i]["jour"].split("-");
      List<String> creneaux =
          globals.user.absences["liste"][i]["creneau"].split(":");
      String date =
          "${jours[2]}/${jours[1]}/${jours[0]} ${creneaux[0]}:${creneaux[1]}";
      return Padding(
        padding: const EdgeInsets.only(left: 0.0, bottom: 5, right: 0),
        child: Card(
          elevation: globals.currentTheme.isDark() ? 4 : 1,
          color: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            height: 65,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 10, right: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: new Container(
                            padding: new EdgeInsets.only(right: 10),
                            child: Text(
                              globals.user.absences["liste"][i]["cours"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        //Expanded(
                        //child:
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              duration.inHours.toString() +
                                  "h" +
                                  ((duration.inMinutes -
                                              (duration.inHours * 60.0)) >
                                          0
                                      ? (duration.inMinutes -
                                              (duration.inHours * 60.0))
                                          .toString()
                                          .split(".")[0]
                                      : ""),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                        ),
                        //),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 2, right: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff787878),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                capitalize(globals
                                    .user.absences["liste"][i]["modalite"]
                                    .toLowerCase()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff787878),
                                ),
                              ),
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
      );
    }

    return show
        ? CupertinoScrollbar(
            child: globals.user.absences["liste"].length > 0
                ? ListView(
                    shrinkWrap: false,
                    children: <Widget>[
                      TitleSection("Semestres"),

                      //SECTION BLOCK selection du semestre
                      Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: <Widget>[
                              SemestreSelection("s1",
                                  "${globals.user.absences["s1"]} absence${globals.user.absences["s1"] > 1 ? "s" : ""}"),
                              SemestreSelection("s2",
                                  "${globals.user.absences["s2"]} absence${globals.user.absences["s2"] > 1 ? "s" : ""}")
                            ],
                          )),

                      //!SECTION
                      //SECTION BLOCK Absences text
                      TitleSection("Absences"),

                      //!SECTION
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 20, right: 20),
                        child: new ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: globals.user.absences["liste"].length,
                            itemBuilder: (BuildContext ctxt, int i) {
                              return AbsenceTile(i);
                            }),
                      )
                    ],
                  )
                : Padding(
                    padding: EdgeInsets.only(bottom: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Container(
                            height: 150,
                            width: 150,
                            child: Center(
                              child: SvgPicture.asset(
                                MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark
                                    ? "assets/absencesok.svg"
                                    : "assets/absencesok2.svg",
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 28),
                          child: Text(
                            "Aucune absence",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
          )
        : Center(child: CupertinoActivityIndicator());
  }
}
