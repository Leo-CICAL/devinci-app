import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/pages/components/absences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:devinci/pages/logic/absences.dart';

Map<String, dynamic> absences;

class AbsencesPage extends StatefulWidget {
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
        await getData(force: true);
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
                child: Text('Hors connexion'),
              ),
            ],
          ),
        );
      } else {
        result = CupertinoScrollbar(
          child: (globals.user.absences['done']
                      ? globals.user.absences['liste'].length
                      : (absences == null ? 0 : absences['liste'].length)) >
                  0
              ? SmartRefresher(
                  enablePullDown: true,
                  header: ClassicHeader(),
                  controller: refreshController,
                  onRefresh: onRefresh,
                  child: ListView(
                    shrinkWrap: false,
                    children: <Widget>[
                      TitleSection('Semestres'),

                      //SECTION BLOCK selection du semestre
                      Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: <Widget>[
                              SemestreSelection('s1',
                                  "${(globals.user.absences["done"] ? globals.user.absences["s1"] : absences["s1"])} absence${(globals.user.absences["done"] ? globals.user.absences["s1"] : absences["s1"]) > 1 ? "s" : ""}"),
                              SemestreSelection('s2',
                                  "${(globals.user.absences["done"] ? globals.user.absences["s2"] : absences["s2"])} absence${(globals.user.absences["done"] ? globals.user.absences["s2"] : absences["s2"]) > 1 ? "s" : ""}"),
                            ],
                          )),

                      //!SECTION
                      //SECTION BLOCK Absences text
                      TitleSection('Absences'),

                      //!SECTION
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 20, right: 20),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: (globals.user.absences['done']
                                ? globals.user.absences['liste'].length
                                : absences['liste'].length),
                            itemBuilder: (BuildContext ctxt, int i) {
                              return AbsenceTile(i);
                            }),
                      )
                    ],
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
                          'Aucune absence',
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 20),
                        ),
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
