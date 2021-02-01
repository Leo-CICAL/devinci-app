//DEPENDENCIES
import 'dart:convert';
import 'dart:io';
import 'package:sembast/sembast.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:sembast/utils/value_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

//DATA
int currentSemester = 0;
bool show = false;
bool first = true;
final RefreshController refreshController =
    RefreshController(initialRefresh: false);
final ScrollController scrollController = ScrollController();
String currentYear = '';
bool changed = false;
int index = 0;

//FUNCTIONS
void changeCurrentSemester(int sem) {
  setState(() {
    currentSemester = sem;
    if (!changed) changed = true;
  });
}

Future<void> getData({bool force = false}) async {
  if (!force) {
    var tmpNotes =
        await globals.store.record('notes').get(globals.db) as List<dynamic>;
    globals.user.notes = cloneList(tmpNotes);
  }
  if (force || globals.user.notes.isEmpty) {
    if (globals.isConnected) {
      try {
        await globals.user.getNotesList();
        currentYear = globals.user.notesList[index][0];

        try {
          await globals.user.getNotes(globals.user.notesList[index][1], index);
        } catch (exception, stacktrace) {
          catcher(exception, stacktrace, '?my=notes');
        }
        try {
          await globals.user.getBonus(globals.user.notesList[index][1]);
        } catch (exception, stacktrace) {
          catcher(exception, stacktrace, '?my=notes');
        }
      } catch (exception, stacktrace) {
        catcher(exception, stacktrace, '?my=notes');
      }
    }
  }
  try {
    if (globals.user.notes.isNotEmpty) {
      if (!globals.user.notes[index]['s'][1].isEmpty && !changed) {
        currentSemester = 1;
      }
    }

    setState(() {
      show = true;
    });
  } catch (e) {
    l(e);
  }
  if (!globals.user.notesFetched && globals.isConnected) {
    Sentry.addBreadcrumb(Breadcrumb(
        message:
            'logic/notes.dart => getData() => if (!globals.user.notesFetched && globals.isConnected)'));
    globals.isLoading.setState(1, true);
  }

  return;
}

void onRefresh() async {
  if (!globals.noteLocked) {
    globals.noteLocked = true;
    try {
      await globals.user.getNotesList();
      currentYear = globals.user.notesList[index][0];
      try {
        await globals.user.getNotes(globals.user.notesList[index][1], index);
      } catch (exception, stacktrace) {
        catcher(exception, stacktrace, '?my=notes');
      }
      try {
        await globals.user.getBonus(globals.user.notesList[index][1]);
      } catch (exception, stacktrace) {
        catcher(exception, stacktrace, '?my=notes');
      }
    } catch (exception, stacktrace) {
      l(exception);
      l(stacktrace);
      l('needs reconnection');
      final snackBar = SnackBar(
        content: Text('reconnecting').tr(),
        duration: const Duration(seconds: 10),
      );
// Find the Scaffold in the widget tree and use it to show a SnackBar.
      Scaffold.of(getContext()).showSnackBar(snackBar);
      try {
        await globals.user.getTokens();
      } catch (e, stacktrace) {
        l(e);
        l(stacktrace);
      }
      try {
        await globals.user.getNotesList();
        currentYear = globals.user.notesList[index][0];
        try {
          await globals.user.getNotes(globals.user.notesList[index][1], index);
        } catch (exception, stacktrace) {
          catcher(exception, stacktrace, '?my=notes');
        }
        try {
          await globals.user.getBonus(globals.user.notesList[index][1]);
        } catch (exception, stacktrace) {
          catcher(exception, stacktrace, '?my=notes');
        }
      } catch (exception, stacktrace) {
        catcher(exception, stacktrace, '?my=notes');
      }
      Scaffold.of(getContext()).removeCurrentSnackBar();

      l(globals.user.tokens);
    }
    l(globals.user.tokens);
    globals.noteLocked = false;
  }

  setState(() {
    if (!globals.user.notes[index]['s'][1].isEmpty && !changed) {
      currentSemester = 1;
    }
    refreshController.refreshCompleted();
  });
}

void runBeforeBuild() async {
  if (!globals.user.notesFetched) {
    Sentry.addBreadcrumb(Breadcrumb(
        message:
            'logic/notes.dart => runBeforeBuild() => if (!globals.user.notesFetched)'));
    await getData();
  } else {
    setState(() {
      if (!globals.user.notes[index]['s'][1].isEmpty && !changed) {
        currentSemester = 1;
      }
      show = true;
    });
  }
}

BuildContext getContext() {
  if (globals.notesPageKey.currentState != null) {
    return globals.notesPageKey.currentState.context;
  } else {
    return globals.getScaffold();
  }
}

void setState(void Function() fun, {bool condition = true}) {
  if (globals.notesPageKey.currentState != null) {
    if (globals.notesPageKey.currentState.mounted && condition) {
      // ignore: invalid_use_of_protected_member
      globals.notesPageKey.currentState.setState(fun);
    }
  }
}
