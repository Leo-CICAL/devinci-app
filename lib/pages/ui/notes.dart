import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/extra/measureSize.dart';
import 'package:devinci/pages/components/notes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:devinci/pages/logic/notes.dart';
import 'package:easy_localization/easy_localization.dart';

class NotesPage extends StatefulWidget {
  NotesPage({Key key}) : super(key: key);

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    super.initState();
    globals.isLoading.addListener(() async {
      if (globals.isLoading.state(1)) {
        await getData(force: true);
        globals.isLoading.setState(1, false);
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  Widget build(BuildContext context) {
    Widget result = SizedBox
        .shrink(); //de base je met un SizedBox.shrink() parce que c'est l'"équivalent" du null en widget sans que ca casse tout si c'est ca qui est renvoyé.

    return OrientationBuilder(builder: (context, orientation) {
      if (show) {
        if (!globals.isConnected && globals.user.notes.isEmpty) {
          //hors-connexion et pas de données backup
          return Center(
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
          if (MediaQuery.of(context).size.width > 1000) {
            return CupertinoScrollbar(
              child: SmartRefresher(
                enablePullDown: true,
                header: ClassicHeader(),
                controller: refreshController,
                onRefresh: onRefresh,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.13,
                  ),
                  child: ListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    children: <Widget>[
                      MeasureSize(
                        child: YearsSelection(),
                        onChange: (size) {
                          if (first) {
                            scrollController.jumpTo(size.height);
                            first = false;
                          }
                        },
                      ),
                      TitleSection('semesters',
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 20, right: 20)),
                      Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: <Widget>[
                              SemestreSelection(0),
                              SemestreSelection(1)
                            ],
                          )),
                      TitleSection('grades'),
                      globals.user.notes[index]['s'][currentSemester].length !=
                              0
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0, left: 20, right: 20, bottom: 48),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: globals.user
                                    .notes[index]['s'][currentSemester].length,
                                itemBuilder: (BuildContext ctxt, int i) {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    primary: false,
                                    scrollDirection: Axis.vertical,
                                    itemCount: globals
                                        .user
                                        .notes[index]['s'][currentSemester][i]
                                            ['matieres']
                                        .length,
                                    itemBuilder: (BuildContext ctxt, int j) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          MatiereTile(i, j),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            primary: false,
                                            scrollDirection: Axis.vertical,
                                            itemCount: globals
                                                .user
                                                .notes[index]['s']
                                                    [currentSemester][i]
                                                    ['matieres'][j]['notes']
                                                .length,
                                            itemBuilder:
                                                (BuildContext ctxt, int y) {
                                              return NoteTile(i, j, y);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 52),
                              child: Container(
                                height: 200,
                                width: 200,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/free.svg',
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          } else {}
        }
      } else {
        return Center(
          child: CupertinoActivityIndicator(),
        );
      }
    });
  }
}
