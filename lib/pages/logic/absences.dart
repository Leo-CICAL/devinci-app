//DEPENDENCIES
import 'dart:convert';
import 'dart:io';

import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sembast/sembast.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:sembast/utils/value_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:f_logs/f_logs.dart';

//DATA
bool show = false;
RefreshController refreshController = RefreshController(initialRefresh: false);

//FUNCTIONS

Future<void> getData({bool force = false}) async {
  if (!force) {
    var tmpAbsences = await globals.store.record('absences').get(globals.db);
    if (!globals.isConnected) {
      globals.user.absences = cloneMap(tmpAbsences);
    } else {
      if (tmpAbsences != null) globals.user.absences = cloneMap(tmpAbsences);
      globals.isLoading.setState(2, true);
    }
  } else {
    try {
      await globals.user.getAbsences();
    } catch (exception, stacktrace) {
      FLog.logThis(
          className: 'absences logic',
          methodName: 'getData',
          text: 'exception',
          type: LogLevel.ERROR,
          exception: Exception(exception),
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
        Cookie(
            'SimpleSAMLAuthToken', globals.user.tokens['SimpleSAMLAuthToken']),
      ]);
      var res = await req.close();
      globals.feedbackNotes = await res.transform(utf8.decoder).join();

      await reportError(exception, stacktrace);
    }
  }
  setState(() {
    show = true;
  });
  return;
}

void setState(void Function() fun, {bool condition = true}) {
  if (globals.absencesPageKey.currentState != null) {
    if (globals.absencesPageKey.currentState.mounted && condition) {
      // ignore: invalid_use_of_protected_member
      globals.absencesPageKey.currentState.setState(fun);
    }
  }
}

void runBeforeBuild() async {
  if (globals.user.absences != null) {
    if (!globals.user.absences['done']) {
      try {
        await getData();
      } catch (e) {
        FLog.info(
            className: 'AbsencesPage Logic',
            methodName: 'runBeforeBuild',
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
              className: 'AbsencesPage logic',
              methodName: 'runBeforeBuild',
              text: 'exception',
              type: LogLevel.ERROR,
              exception: Exception(e),
              stacktrace: stacktrace);
        }
        try {
          await getData();
        } catch (exception, stacktrace) {
          FLog.logThis(
              className: 'AbsencesPage logic',
              methodName: 'runBeforeBuild',
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
    }
  }

  setState(() {
    show = true;
  }, condition: !show);
}

void onRefresh() async {
  await getData(force: true);
  setState(() {
    show = true;
    refreshController.refreshCompleted();
  });
}

BuildContext getContext() {
  if (globals.absencesPageKey.currentState != null) {
    return globals.absencesPageKey.currentState.context;
  } else {
    return globals.getScaffold();
  }
}
