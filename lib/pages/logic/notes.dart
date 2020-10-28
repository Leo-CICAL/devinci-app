//DEPENDENCIES
import 'dart:convert';
import 'dart:io';
import 'package:sembast/sembast.dart';
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:sembast/utils/value_utils.dart';

//DATA

int currentSemester = 0;
bool show = false;
final RefreshController refreshController =
    RefreshController(initialRefresh: false);
final ScrollController scrollController = ScrollController(
  initialScrollOffset:
      globals.isConnected ? 42 : 0, //pour cacher le choix de l'année
  keepScrollOffset: true,
);
String currentYear = '';
bool changed = false;
int index = 0;

//FUNCTIONS
void changeCurrentSemester(int sem) {
  // ignore: invalid_use_of_protected_member

  globals.notesPageKey.currentState.setState(() {
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
          catcher(exception, stacktrace);
        }
      } catch (exception, stacktrace) {
        catcher(exception, stacktrace);
      }
    }
  }

  if (globals.notesPageKey.currentState.mounted) {
    if (globals.user.notes.isNotEmpty) {
      try {
        if (!globals.user.notes[index]['s'][1].isEmpty && !changed) {
          currentSemester = 1;
        }
      } catch (e) {
        print(e);
      }
    }

    globals.notesPageKey.currentState.setState(() {
      show = true;
    });
  }
  if (!globals.user.notesFetched && globals.isConnected) {
    globals.isLoading.setState(1, true);
  }

  return;
}

void onRefresh() async {
  print('refresh');
  if (!globals.noteLocked) {
    globals.noteLocked = true;
    try {
      await globals.user.getNotesList();
      currentYear = globals.user.notesList[index][0];
      try {
        await globals.user.getNotes(globals.user.notesList[index][1], index);
      } catch (exception, stacktrace) {
        catcher(exception, stacktrace);
      }
    } catch (exception, stacktrace) {
      catcher(exception, stacktrace);
    }
    globals.noteLocked = false;
  }
  if (globals.notesPageKey.currentState.mounted) {
    globals.notesPageKey.currentState.setState(() {
      if (!globals.user.notes[index]['s'][1].isEmpty && !changed) {
        currentSemester = 1;
      }
      refreshController.refreshCompleted();
    });
  }
}

void catcher(var exception, StackTrace stacktrace) async {
  if (globals.isConnected) {
    var client = HttpClient();
    var req = await client.getUrl(
      Uri.parse('https://www.leonard-de-vinci.net/?my=notes'),
    );
    req.followRedirects = false;
    req.cookies.addAll([
      Cookie('alv', globals.user.tokens['alv']),
      Cookie('SimpleSAML', globals.user.tokens['SimpleSAML']),
      Cookie('uids', globals.user.tokens['uids']),
      Cookie('SimpleSAMLAuthToken', globals.user.tokens['SimpleSAMLAuthToken']),
    ]);
    var res = await req.close();
    globals.feedbackNotes = await res.transform(utf8.decoder).join();

    await reportError(
        'notes.dart | _NotesPageState | runBeforeBuild() | user.getNotes() => $exception',
        stacktrace);
  }
}

void runBeforeBuild() async {
  if (!globals.user.notesFetched) {
    await getData();
  } else {
    globals.notesPageKey.currentState.setState(() {
      if (!globals.user.notes[index]['s'][1].isEmpty && !changed) {
        currentSemester = 1;
      }
      show = true;
    });
  }
}
