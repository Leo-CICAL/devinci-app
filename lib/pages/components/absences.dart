import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/pages/logic/absences.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;

Widget SemestreSelection(String sem, String subtitle) {
  return Expanded(
    child: Padding(
      padding: EdgeInsets.only(
          left: sem == 's1' ? 20.0 : 10.0,
          top: 0,
          right: sem == 's2' ? 20.0 : 10.0),
      child: Card(
        elevation: globals.currentTheme.isDark() ? 4 : 2,
        color: Theme.of(getContext()).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                    color: MediaQuery.of(globals
                                    .absencesPageKey.currentState.context)
                                .platformBrightness ==
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
  var duration = Duration(
      hours:
          int.parse(globals.user.absences['liste'][i]['duree'].split(':')[0]),
      minutes:
          int.parse(globals.user.absences['liste'][i]['duree'].split(':')[1]),
      seconds:
          int.parse(globals.user.absences['liste'][i]['duree'].split(':')[2]));
  List<String> jours = globals.user.absences['liste'][i]['jour'].split('-');
  List<String> creneaux =
      globals.user.absences['liste'][i]['creneau'].split(':');
  var date =
      '${jours[2]}/${jours[1]}/${jours[0]} ${creneaux[0]}:${creneaux[1]}';
  return Padding(
    padding: const EdgeInsets.only(left: 0.0, bottom: 5, right: 0),
    child: Card(
      elevation: globals.currentTheme.isDark() ? 4 : 1,
      color: Theme.of(getContext()).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        height: 65,
        width: MediaQuery.of(getContext()).size.width,
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
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          globals.user.absences['liste'][i]['cours'],
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
                              'h' +
                              ((duration.inMinutes -
                                          (duration.inHours * 60.0)) >
                                      0
                                  ? (duration.inMinutes -
                                          (duration.inHours * 60.0))
                                      .toString()
                                      .split('.')[0]
                                  : ''),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(globals
                                    .absencesPageKey.currentState.context)
                                .accentColor,
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
                                .user.absences['liste'][i]['modalite']
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
