import 'dart:convert';
import 'dart:io';

import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/pages/components/absences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:matomo/matomo.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:devinci/pages/logic/absences.dart';
import 'package:f_logs/f_logs.dart';

class AbsencesPage extends TraceableStatefulWidget {
  AbsencesPage({Key key}) : super(key: key);

  @override
  AbsencesPageState createState() => AbsencesPageState();
}

class AbsencesPageState extends State<AbsencesPage> {
  @override
  void initState() {
    super.initState();
    globals.isLoading.addListener(() async {
      if (globals.isLoading.state(2)) {
        try {
          await getData(force: true);
        } catch (e) {
          FLog.info(
              className: 'AbsencesPageState',
              methodName: 'initState',
              text: 'needs reconnection');
          final snackBar = SnackBar(
            content: Text('reconnecting').tr(),
            duration: const Duration(seconds: 10),
          );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
          Scaffold.of(getContext()).showSnackBar(snackBar);
          try {
            await globals.user.getTokens();
          } catch (e, stacktrace) {
            FLog.logThis(
                className: 'AbsencesPage ui',
                methodName: 'initState',
                text: 'exception',
                type: LogLevel.ERROR,
                exception: Exception(e),
                stacktrace: stacktrace);
          }
          try {
            await getData(force: true);
          } catch (exception, stacktrace) {
            FLog.logThis(
                className: 'AbsencesPage ui',
                methodName: 'initState',
                text: 'exception',
                type: LogLevel.ERROR,
                exception: Exception(e),
                stacktrace: stacktrace);
            var client = HttpClient();
            var req = await client.getUrl(
              Uri.parse('https://www.leonard-de-vinci.net/?my=abs'),
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

            await reportError(exception, stacktrace);
          }
          Scaffold.of(getContext()).removeCurrentSnackBar();
        }
        globals.isLoading.setState(2, false);
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  Widget build(BuildContext context) {
    Widget result = SizedBox
        .shrink(); //de base je met un SizedBox.shrink() parce que c'est l'"équivalent" du null en widget sans que ca casse tout si c'est ca qui est renvoyé.
    if (show) {
      if (globals.user.absences == null) {
        //hors-connexion et pas de données backup
        result = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 32),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('offline').tr(),
              ),
            ],
          ),
        );
      } else {
        var padding = 0.0;
        if (MediaQuery.of(context).size.width > 1000) {
          padding = MediaQuery.of(context).size.width * 0.13;
        } else if (MediaQuery.of(context).size.width > 800) {
          padding = MediaQuery.of(context).size.width * 0.1;
        } else if (MediaQuery.of(context).size.width > 600) {
          padding = MediaQuery.of(context).size.width * 0.08;
        }

        result = CupertinoScrollbar(
          child: (globals.user.absences['done']
                      ? globals.user.absences['liste'].length
                      : 0) >
                  0
              ? SmartRefresher(
                  enablePullDown: true,
                  header: ClassicHeader(),
                  controller: refreshController,
                  onRefresh: onRefresh,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding,
                    ),
                    child: ListView(
                      shrinkWrap: false,
                      children: <Widget>[
                        TitleSection('semesters'),

                        //SECTION BLOCK selection du semestre
                        Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              children: <Widget>[
                                SemestreSelection(
                                    's1',
                                    'nabsence'
                                        .plural(globals.user.absences['s1'])),
                                SemestreSelection(
                                    's2',
                                    'nabsence'
                                        .plural(globals.user.absences['s2'])),
                              ],
                            )),

                        //!SECTION
                        //SECTION BLOCK Absences text
                        TitleSection('absences'),

                        //!SECTION
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 20, right: 20),
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount:
                                  (globals.user.absences['liste'].length),
                              itemBuilder: (BuildContext ctxt, int i) {
                                return AbsenceTile(i);
                              }),
                        )
                      ],
                    ),
                  ),
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
                              globals.currentTheme.isDark()
                                  ? 'assets/absencesok.svg'
                                  : 'assets/absencesok2.svg',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 28),
                        child: Text(
                          'no_absence',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 20),
                        ).tr(),
                      ),
                    ],
                  ),
                ),
        );
      }
    } else {
      result = Center(
        child: CupertinoActivityIndicator(),
      );
    }
    return result;
  }
}
