import 'dart:async';
import 'package:devinci/extra/CommonWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:devinci/extra/classes.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:intl/intl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:sembast/sembast.dart';

Function setAgendaHeaderState;

Color _selectedColor;
MeetingDataSource _events;
Cours _selectedCours;
DateTime _from;
TimeOfDay _startTime;
DateTime _to;
TimeOfDay _endTime;
bool _isAllDay;
String _title = '';
String _location = '';
String _prof = '';
String _flag = '';
String flag = '';
String _uid = '';
String _groupe = '';

class AgendaHeader extends StatefulWidget {
  AgendaHeader({Key key}) : super(key: key);
  @override
  _AgendaHeaderState createState() => _AgendaHeaderState();
}

class _AgendaHeaderState extends State<AgendaHeader> {
  _AgendaHeaderState();

  void initState() {
    setAgendaHeaderState = setState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TitleSection(globals.agendaTitle.headerText,
        padding: const EdgeInsets.only(top: 8.0, left: 16, bottom: 8));
  }
}

class AgendaPage extends StatefulWidget {
  AgendaPage({Key key}) : super(key: key);
  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  bool show = false;
  String date;

  _AgendaPageState();

  Future<void> getCalendar() async {
    if (globals.lastFetchAgenda == null) {
      globals.lastFetchAgenda = DateTime.now();
      String icalUrl = globals.user.data["edtUrl"];
      try {
        globals.cours = await parseIcal(icalUrl);
      } catch (exception, stacktrace) {
        await reportError(
            "agenda.dart | _AgendaPageState | getCalendar() | parseIcal() => $exception",
            stacktrace);
        return;
      }
      setState(() {
        show = true;
      });
      globals.isLoading.setState(0, true);
    } else {
      setState(() {
        show = true;
      });
    }
    return;
  }

  void initState() {
    Intl.defaultLocale = "fr_FR";
    _selectedCours = null;
    _title = '';
    globals.calendarController = CalendarController();
    super.initState();
    globals.isLoading.addListener(() async {
      print("isLoading");
      if (globals.isLoading.state(0)) {
        try {
          globals.cours =
              await parseIcal(globals.user.data["edtUrl"], load: true);
        } catch (exception, stacktrace) {
          await reportError(
              "agenda.dart | _AgendaPageState | getCalendar() | parseIcal() => $exception",
              stacktrace);
          return;
        }
        if (mounted) {
          setState(() {});
        }
        globals.isLoading.setState(0, false);
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) => getCalendar());
  }

  void onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    /// Condition added to open the editor, when the calendar elements tapped
    /// other than the header.
    if (calendarTapDetails.targetElement == CalendarElement.header) {
      return;
    }

    _selectedCours = null;
    _isAllDay = false;
    _title = '';
    _location = '';
    _prof = '';
    _flag = '';
    _uid = '';
    _groupe = '';

    if (calendarTapDetails.appointments != null &&
        calendarTapDetails.targetElement == CalendarElement.appointment) {
      final Cours appointment = calendarTapDetails.appointments[0];
      _from = appointment.from;
      _to = appointment.to;
      _isAllDay = appointment.isAllDay;
      _prof = appointment.prof;
      _flag = appointment.flag;
      flag = _flag == 'distanciel'
          ? 'Distanciel'
          : (_flag == 'presentiel' ? 'Présentiel' : 'Non spécifié');
      _selectedColor = appointment.background;
      _title = appointment.title == '' ? '' : appointment.title;
      _uid = appointment.uid;
      _groupe = appointment.groupe;
      _location = appointment.location;
      _selectedCours = appointment;

    } else {
      final DateTime date = calendarTapDetails.date;
      _from = date;
      _to = date.add(const Duration(hours: 1));
      flag = 'Non spécifié';
    }

    _startTime = TimeOfDay(hour: _from.hour, minute: _from.minute);
    _endTime = TimeOfDay(hour: _to.hour, minute: _to.minute);

    Navigator.push<Widget>(
      context,
      // ignore: always_specify_types
      MaterialPageRoute(builder: (BuildContext context) => CoursEditor()),
    );
  }

  @override
  Widget build(BuildContext context) {
    globals.currentContext = context;

    return show
        ? Column(children: <Widget>[
            AgendaHeader(),
            Expanded(
              child: SfCalendar(
                view: globals.calendarView,
                onTap: onCalendarTapped,
                controller: globals.calendarController,
                dataSource: MeetingDataSource(globals.cours),
                headerHeight: 0,
                timeSlotViewSettings: TimeSlotViewSettings(
                  startHour: 7,
                  endHour: 23,
                  nonWorkingDays: <int>[DateTime.sunday],
                  timeFormat: 'HH:mm',
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                firstDayOfWeek: 1,
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                      color: globals.currentTheme.isDark()
                          ? Colors.white
                          : Colors.black,
                      width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),
                onViewChanged: (ViewChangedDetails viewChangedDetails) {
                  globals.agendaTitle.headerText = DateFormat('MMMM yyyy')
                      .format(viewChangedDetails.visibleDates[
                          viewChangedDetails.visibleDates.length ~/ 2])
                      .toString()
                      .capitalize();
                  SchedulerBinding.instance.addPostFrameCallback((duration) {
                    setAgendaHeaderState(() {});
                  });
                },
              ),
            )
          ])
        : Center(child: CupertinoActivityIndicator());
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Cours> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    String title = '';
    if (appointments[index].type != 'NR')
      title += '(${appointments[index].type}) ';
    title += appointments[index].title;
    if (globals.calendarView == CalendarView.day) {
      title += '\n${appointments[index].location}';
      if (appointments[index].site != '' &&
          appointments[index].site != 'La Défense' &&
          appointments[index].site != 'Online') {
        title += '- site: ' + appointments[index].site;
      }
      title += '\n${appointments[index].prof}';
    } else if (globals.calendarView == CalendarView.month) {
      appointments[index].location = appointments[index].location.split('-')[0];
      title += ' - ${appointments[index].location}';
    } else {
      appointments[index].location = appointments[index].location.split('-')[0];
      title += '\n${appointments[index].location}';
    }
    return title;
  }

  @override
  Color getColor(int index) {
    Color color =
        (globals.currentTheme.isDark() ? Colors.blueAccent : Colors.blue);
    if (appointments[index].flag == 'distanciel') {
      color = (globals.currentTheme.isDark()
          ? Colors.deepOrangeAccent.shade400
          : Colors.deepOrange);
    } else if (appointments[index].flag == 'presentiel') {
      color = Colors.teal;
    }
    return color;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

class CoursEditor extends StatefulWidget {
  final bool addButton;
  const CoursEditor({Key key, this.addButton = false}) : super(key: key);
  @override
  CoursEditorState createState() => CoursEditorState(this.addButton);
}

class CoursEditorState extends State<CoursEditor> {
  final bool addButton;

  CoursEditorState(this.addButton);

  Widget _getAppointmentEditor(
      BuildContext context, Color backgroundColor, Color defaultColor) {
    if (_startTime == null || addButton) {
      _selectedCours = null;
      _isAllDay = false;
      _title = '';
      _location = '';
      _prof = '';
      _flag = '';
      _uid = '';
      _groupe = '';
      final DateTime date = DateTime.now();
      _from = date;
      _to = date.add(const Duration(hours: 1));
      flag = 'Non spécifié';

      _startTime = TimeOfDay(hour: _from.hour, minute: _from.minute);
      _endTime = TimeOfDay(hour: _to.hour, minute: _to.minute);
    }
    Color color =
        (globals.currentTheme.isDark() ? Colors.blueAccent : Colors.blue);
    if (flag == 'Distanciel') {
      color = (globals.currentTheme.isDark()
          ? Colors.deepOrangeAccent.shade400
          : Colors.deepOrange);
    } else if (flag == 'Présentiel') {
      color = Colors.teal;
    }

    return Container(
        color: backgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text(''),
              title: TextField(
                controller: TextEditingController(text: _title),
                onChanged: (String value) {
                  _title = value;
                },
                enabled: _uid.indexOf(':') > -1 ? false : true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 20,
                    color: defaultColor,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Titre',
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: IconTheme(
                data: Theme.of(context).accentIconTheme,
                child: Icon(
                  Icons.perm_identity,
                ),
              ),
              title: TextField(
                controller: TextEditingController(text: _prof),
                onChanged: (String value) {
                  _prof = value;
                },
                enabled: _uid.indexOf(':') > -1 ? false : true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 16,
                    color: defaultColor,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Professeur',
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: IconTheme(
                data: Theme.of(context).accentIconTheme,
                child: Icon(
                  OMIcons.locationOn,
                ),
              ),
              title: TextField(
                controller: TextEditingController(text: _location),
                onChanged: (String value) {
                  _location = value;
                },
                enabled: _uid.indexOf(':') > -1 ? false : true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 16,
                    color: defaultColor,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Emplacement',
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: IconTheme(
                data: Theme.of(context).accentIconTheme,
                child: Icon(
                  OMIcons.group,
                ),
              ),
              title: TextField(
                controller: TextEditingController(text: _groupe),
                onChanged: (String value) {
                  _groupe = value;
                },
                enabled: _uid.indexOf(':') > -1 ? false : true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 16,
                    color: defaultColor,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Groupe',
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: IconTheme(
                  data: Theme.of(context).accentIconTheme,
                  child: Icon(
                    Icons.restore,
                  ),
                ),
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                            child: Text(
                                DateFormat('EEEE dd MMM yyyy').format(_from),
                                textAlign: TextAlign.left),
                            onTap: _uid.indexOf(':') > -1
                                ? null
                                : () async {
                                    final DateTime date = await showDatePicker(
                                        context: context,
                                        initialDate: _from,
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100),
                                        builder: (BuildContext context,
                                            Widget child) {
                                          return Theme(
                                            data: ThemeData(
                                              brightness:
                                                  globals.currentTheme.isDark()
                                                      ? Brightness.dark
                                                      : Brightness.light,
                                              // colorScheme:
                                              //     _getColorScheme(widget.model),
                                              accentColor:
                                                  Theme.of(context).accentColor,
                                              primaryColor: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            child: child,
                                          );
                                        });

                                    if (date != null && date != _from) {
                                      setState(() {
                                        final Duration difference =
                                            _to.difference(_from);
                                        _from = DateTime(
                                            date.year,
                                            date.month,
                                            date.day,
                                            _startTime.hour,
                                            _startTime.minute,
                                            0);
                                        _to = _from.add(difference);
                                        _endTime = TimeOfDay(
                                            hour: _to.hour, minute: _to.minute);
                                      });
                                    }
                                  }),
                      ),
                      Expanded(
                          flex: 3,
                          child: GestureDetector(
                              child: Text(
                                DateFormat('HH:mm').format(_from),
                                textAlign: TextAlign.right,
                              ),
                              onTap: _uid.indexOf(':') > -1
                                  ? null
                                  : () async {
                                      final TimeOfDay time =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                  hour: _startTime.hour,
                                                  minute: _startTime.minute),
                                              builder: (BuildContext context,
                                                  Widget child) {
                                                return Theme(
                                                  data: ThemeData(
                                                    brightness: globals
                                                            .currentTheme
                                                            .isDark()
                                                        ? Brightness.dark
                                                        : Brightness.light,
                                                    // colorScheme:
                                                    //     _getColorScheme(widget.model),
                                                    accentColor:
                                                        Theme.of(context)
                                                            .accentColor,
                                                    primaryColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                  ),
                                                  child: child,
                                                );
                                              });

                                      if (time != null && time != _startTime) {
                                        setState(() {
                                          _startTime = time;
                                          final Duration difference =
                                              _to.difference(_from);
                                          _from = DateTime(
                                              _from.year,
                                              _from.month,
                                              _from.day,
                                              _startTime.hour,
                                              _startTime.minute,
                                              0);
                                          _to = _from.add(difference);
                                          _endTime = TimeOfDay(
                                              hour: _to.hour,
                                              minute: _to.minute);
                                        });
                                      }
                                    })),
                    ])),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: IconTheme(
                  data: Theme.of(context).accentIconTheme,
                  child: Icon(
                    Icons.update,
                  ),
                ),
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                            child: Text(
                              DateFormat('EEEE dd MMM yyyy').format(_to),
                              textAlign: TextAlign.left,
                            ),
                            onTap: _uid.indexOf(':') > -1
                                ? null
                                : () async {
                                    final DateTime date = await showDatePicker(
                                        context: context,
                                        initialDate: _to,
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100),
                                        builder: (BuildContext context,
                                            Widget child) {
                                          return Theme(
                                            data: ThemeData(
                                              brightness:
                                                  globals.currentTheme.isDark()
                                                      ? Brightness.dark
                                                      : Brightness.light,
                                              // colorScheme:
                                              //     _getColorScheme(widget.model),
                                              accentColor:
                                                  Theme.of(context).accentColor,
                                              primaryColor: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            child: child,
                                          );
                                        });

                                    if (date != null && date != _to) {
                                      setState(() {
                                        final Duration difference =
                                            _to.difference(_from);
                                        _to = DateTime(
                                            date.year,
                                            date.month,
                                            date.day,
                                            _endTime.hour,
                                            _endTime.minute,
                                            0);
                                        if (_to.isBefore(_from)) {
                                          _from = _to.subtract(difference);
                                          _startTime = TimeOfDay(
                                              hour: _from.hour,
                                              minute: _from.minute);
                                        }
                                      });
                                    }
                                  }),
                      ),
                      Expanded(
                          flex: 3,
                          child: GestureDetector(
                              child: Text(
                                DateFormat('HH:mm').format(_to),
                                textAlign: TextAlign.right,
                              ),
                              onTap: _uid.indexOf(':') > -1
                                  ? null
                                  : () async {
                                      final TimeOfDay time =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(
                                                  hour: _endTime.hour,
                                                  minute: _endTime.minute),
                                              builder: (BuildContext context,
                                                  Widget child) {
                                                return Theme(
                                                  data: ThemeData(
                                                    brightness: globals
                                                            .currentTheme
                                                            .isDark()
                                                        ? Brightness.dark
                                                        : Brightness.light,
                                                    // colorScheme:
                                                    //     _getColorScheme(widget.model),
                                                    accentColor:
                                                        Theme.of(context)
                                                            .accentColor,
                                                    primaryColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                  ),
                                                  child: child,
                                                );
                                              });

                                      if (time != null && time != _endTime) {
                                        setState(() {
                                          _endTime = time;
                                          final Duration difference =
                                              _to.difference(_from);
                                          _to = DateTime(
                                              _to.year,
                                              _to.month,
                                              _to.day,
                                              _endTime.hour,
                                              _endTime.minute,
                                              0);
                                          if (_to.isBefore(_from)) {
                                            _from = _to.subtract(difference);
                                            _startTime = TimeOfDay(
                                                hour: _from.hour,
                                                minute: _from.minute);
                                          }
                                        });
                                      }
                                    })),
                    ])),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(Icons.lens, color: color),
              title: _uid.indexOf(':') > -1
                  ? Text(flag)
                  : DropdownButton<String>(
                      value: flag,
                      icon: Icon(OMIcons.expandMore),
                      iconSize: 24,
                      elevation: 16,
                      style: Theme.of(context).textTheme.subtitle1,
                      underline: Container(
                        height: 0,
                        color: Colors.transparent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          flag = newValue;
                          _flag = flag == 'Distanciel'
                              ? 'distanciel'
                              : (flag == 'Présentiel' ? 'presentiel' : '');
                        });
                      },
                      items: <String>[
                        'Distanciel',
                        'Présentiel',
                        'Non spécifié',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            _selectedCours != null && _uid.indexOf(':') < 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlineButton(
                        onPressed: () {
                          if (_selectedCours != null && _uid.indexOf(':') < 0) {
                            globals.cours.removeAt(
                                globals.cours.indexOf(_selectedCours));
                            globals.customCours.removeAt(
                                globals.customCours.indexOf(_selectedCours));
                          }
                          globals.store
                              .record('customCours')
                              .put(globals.db, coursListToJson());
                          _selectedCours = null;
                          globals.calendarView =
                              globals.calendarView == CalendarView.day
                                  ? CalendarView.workWeek
                                  : CalendarView.day;
                          globals.calendarView =
                              globals.calendarView == CalendarView.workWeek
                                  ? CalendarView.day
                                  : CalendarView.workWeek;

                          Navigator.pop(context);
                        },
                        borderSide: BorderSide(
                            color: globals.currentTheme.isDark()
                                ? Colors.redAccent
                                : Colors.red.shade700,
                            width: 2),
                        child: Text('Supprimer l\'évènement',
                            style: TextStyle(
                                color: globals.currentTheme.isDark()
                                    ? Colors.redAccent
                                    : Colors.red.shade700))),
                  )
                : Container(),
            Container(),
          ],
        ));
  }

  @override
  Widget build([BuildContext context]) {
    globals.currentContext = context;
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        globals.currentTheme.isDark());
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).scaffoldBackgroundColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        globals.currentTheme.isDark());
    return Theme(
        data: Theme.of(context),
        child: Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          appBar: AppBar(
            //backgroundColor: _colorCollection[_selectedColorIndex],
            title: Text(
                _title == '' || addButton
                    ? 'Nouvel évènement'
                    : 'Détail de l\'évènement',
                style: Theme.of(context).textTheme.bodyText2),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconTheme(
                data: Theme.of(context).accentIconTheme,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )),
            actions: _uid.indexOf(':') > -1 && !addButton
                ? null
                : <Widget>[
                    IconTheme(
                        data: Theme.of(context).accentIconTheme,
                        child: IconButton(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            icon: const Icon(
                              Icons.done,
                            ),
                            onPressed: () {
                              print(_selectedCours);
                              if (_selectedCours != null &&
                                  _uid.indexOf(':') < 0) {
                                globals.cours.removeAt(
                                    globals.cours.indexOf(_selectedCours));
                              }
                              Cours c = new Cours(
                                  'NR',
                                  _title,
                                  _prof,
                                  _location,
                                  '',
                                  _from,
                                  _to,
                                  Colors.blue,
                                  false,
                                  _flag,
                                  '',
                                  _groupe);
                              globals.cours.add(c);
                              globals.customCours.add(c);
                              globals.store
                                  .record('customCours')
                                  .put(globals.db, coursListToJson());
                              // _events.notifyListeners(
                              //     CalendarDataSourceAction.add, appointment);
                              _selectedCours = null;
                              globals.calendarController.view =
                                  globals.calendarController.view ==
                                          CalendarView.day
                                      ? CalendarView.workWeek
                                      : CalendarView.day;
                              globals.calendarController.view =
                                  globals.calendarController.view ==
                                          CalendarView.workWeek
                                      ? CalendarView.day
                                      : CalendarView.workWeek;

                              Navigator.pop(context);
                            })),
                  ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Stack(
              children: <Widget>[
                _getAppointmentEditor(
                    context,
                    Theme.of(context).cardColor,
                    globals.currentTheme.isDark()
                        ? Colors.white
                        : Colors.black87)
              ],
            ),
          ),
        ));
  }
}
