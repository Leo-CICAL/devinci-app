import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/pages/logic/notes.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:easy_localization/easy_localization.dart';

Widget SemestreSelection(int sem) {
  return Expanded(
    child: Padding(
      padding: EdgeInsets.only(
          left: sem == 0 ? 20.0 : 10.0, top: 0, right: sem == 1 ? 20.0 : 10.0),
      child: Card(
        elevation: globals.currentTheme.isDark() ? 4 : 2,
        color: Theme.of(getContext()).cardColor,
        shape: currentSemester == sem
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                    color: Theme.of(getContext()).accentColor, width: 2.0))
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: InkWell(
          onTap: () {
            changeCurrentSemester(sem);
          }, // handle your onTap here
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 0.0, top: 6, right: 0),
                child: Text(
                  "S${2 * globals.user.notes[index]['name'] - 1 + sem}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 0.0, top: 3, right: 0, bottom: 14),
                child: Text(
                  's$sem',
                  style: TextStyle(
                      color: globals.currentTheme.isDark()
                          ? Color(0xffE1E2E1)
                          : Color(0xffACACAC),
                      fontSize: 16),
                ).tr(),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

Widget MatiereTile(int i, int j) {
  return Padding(
    padding: const EdgeInsets.only(left: 0.0, bottom: 5, right: 0),
    child: Card(
        elevation: globals.currentTheme.isDark() ? 4 : 2,
        color: Theme.of(getContext()).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: InkWell(
          onTap: globals
                  .user
                  .notes[index]['s'][currentSemester][i]['matieres'][j]['notes']
                  .isEmpty
              ? null
              : () => setState(() {
                    globals.user.notes[index]['s'][currentSemester][i]
                            ['matieres'][j]['c'] =
                        !globals.user.notes[index]['s'][currentSemester][i]
                            ['matieres'][j]['c'];
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
                        child: Container(
                          padding: EdgeInsets.only(right: 12),
                          child: Text(
                            removeGarbage(globals.user.notes[index]['s']
                                [currentSemester][i]['matieres'][j]['matiere']),
                            //overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Text(
                          getMatMoy(globals.user.notes[index]['s']
                                      [currentSemester][i]['matieres'][j]) ==
                                  null
                              ? ''
                              : (getMatMoy(globals.user.notes[index]['s'][currentSemester]
                                              [i]['matieres'][j]) ==
                                          100
                                      ? 'validated'.tr()
                                      : getMatMoy(globals.user.notes[index]['s']
                                          [currentSemester][i]['matieres'][j]))
                                  .toString(),
                          style: TextStyle(
                              color: (getMatMoy(globals.user.notes[index]['s']
                                                  [currentSemester][i]
                                              ['matieres'][j]) ??
                                          11) >=
                                      10
                                  ? Theme.of(getContext()).accentColor
                                  : getMatMoy(globals.user.notes[index]['s']
                                                  [currentSemester][i]
                                              ['matieres'][j]) ==
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
                                  .notes[index]['s'][currentSemester][i]
                                      ['matieres'][j]['notes']
                                  .isEmpty
                              ? SizedBox.shrink()
                              : Icon((globals.user.notes[index]['s']
                                      [currentSemester][i]['matieres'][j]['c'])
                                  ? Icons.expand_more_rounded
                                  : Icons.expand_less_rounded),
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

Widget NoteTile(int i, int j, int y) {
  return Visibility(
    visible: !globals.user.notes[index]['s'][currentSemester][i]['matieres'][j]
        ['c'],
    //true,
    child: Padding(
      padding: const EdgeInsets.only(left: 24.0, bottom: 5, right: 0),
      child: Card(
        elevation: globals.currentTheme.isDark() ? 4 : 1,
        color: Theme.of(getContext()).cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          height: 65,
          width: MediaQuery.of(getContext()).size.width,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 10, right: 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            removeGarbage(globals.user.notes[index]['s']
                                    [currentSemester][i]['matieres'][j]['notes']
                                [y]['nom']),
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
                              child: (globals.user.notes[index]['s']
                                              [currentSemester][i]['matieres']
                                          [j]['notes'][y]['note']) ==
                                      null
                                  ? SizedBox.shrink()
                                  : Text(
                                      (globals.user.notes[index]['s']
                                                              [currentSemester]
                                                          [i]['matieres'][j]
                                                      ['notes'][y]['note'] ==
                                                  0.12345
                                              ? 'Absence'
                                              : globals.user.notes[index]['s']
                                                          [currentSemester][i]
                                                      ['matieres'][j]['notes']
                                                  [y]['note'])
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: globals.user.notes[index]['s']
                                                        [currentSemester][i]['matieres']
                                                    [j]['notes'][y]['note'] >=
                                                10
                                            ? Theme.of(getContext()).accentColor
                                            : (globals.user.notes[index]['s']
                                                                [currentSemester]
                                                            [i]['matieres'][j]
                                                        ['notes'][y]['note'] ==
                                                    0
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
                        text: globals.user.notes[index]['s'][currentSemester][i]
                                    ['matieres'][j]['notes'][y]['noteP'] ==
                                null
                            ? ''
                            : 'promo_average'.tr(),
                        style:
                            TextStyle(color: Color(0xff787878), fontSize: 12),
                        children: <TextSpan>[
                          TextSpan(
                              text: globals.user.notes[index]['s']
                                              [currentSemester][i]['matieres']
                                          [j]['notes'][y]['noteP'] ==
                                      null
                                  ? ''
                                  : globals
                                      .user
                                      .notes[index]['s'][currentSemester][i]
                                          ['matieres'][j]['notes'][y]['noteP']
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

Widget YearsSelection() {
  Widget result = SizedBox.shrink();
  if (globals.isConnected && globals.user.years.isNotEmpty) {
    if (currentYear.isEmpty) {
      currentYear = globals.user.years[0];
    }
    result = Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 20, right: 20),
      child: DropdownButton<String>(
        isExpanded: true,
        value: currentYear,
        icon: Icon(Icons.expand_more_rounded),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: globals.currentTheme.isDark() ? Colors.white : Colors.black,
        ),
        underline: Container(
          height: 0,
          color: Theme.of(getContext()).accentColor,
        ),
        onChanged: (String newValue) async {
          setState(() {
            show = false;
          });
          currentYear = newValue;
          index = globals.user.years.indexOf(currentYear);
          try {
            await globals.user.getNotesList();
            currentYear = globals.user.notesList[index][0];
            try {
              await globals.user
                  .getNotes(globals.user.notesList[index][1], index);
            } catch (exception, stacktrace) {
              catcher(exception, stacktrace, '?my=notes', force: true);
            }
          } catch (exception, stacktrace) {
            catcher(exception, stacktrace, '?my=notes', force: true);
          }
          first = true;
          setState(() {
            show = true;
          });
        },
        items: globals.user.years.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
  return result;
}

Widget BonusSection() {
  Widget result = SizedBox.shrink();
  if (globals.isConnected &&
      globals.user.years.isNotEmpty &&
      globals.user.bonus != 0.0) {
    result = TitleSection('bonus'.plural(globals.user.bonus),
        padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20));
  }
  return result;
}
