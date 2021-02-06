import 'package:devinci/extra/classes.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/devinci/extra/functions.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:share_extend/share_extend.dart';
import 'package:f_logs/f_logs.dart';

bool show = false;
bool pad = false;
double cardSize = 85;
List<bool> docCardDetail = <bool>[];
List<Map<String, dynamic>> docCardData = <Map<String, dynamic>>[];
var tapPosition;
ScrollController scroll = ScrollController();

void loaderListener() async {
  if (globals.isLoading.state(4)) {
    try {
      await globals.user.getDocuments();
    } catch (exception) {
      FLog.info(
          className: 'UserPage Logic',
          methodName: 'loaderListener',
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
            className: 'UserPage logic',
            methodName: 'loaderListener',
            text: 'exception',
            type: LogLevel.ERROR,
            exception: Exception(e),
            stacktrace: stacktrace);
        await reportError(e, stacktrace);
      }
      try {
        await globals.user.getDocuments();
      } catch (exception, stacktrace) {
        catcher(exception, stacktrace, '?my=docs', force: true);
      }
      Scaffold.of(getContext()).removeCurrentSnackBar();
    }
    setState(() {
      show = true;
    });
    globals.isLoading.setState(4, false);
  }
}

void runBeforeBuild() async {
  for (var i = 0; i < 10; i++) {
    docCardDetail.add(false);
    docCardData.add({'frShowButton': true, 'enShowButton': true});
  }

  if (globals.user.documents['certificat']['annee'] == '') {
    var documents = await globals.store.record('documents').get(globals.db)
        as Map<String, dynamic>;
    if (documents == null) {
      try {
        await globals.user.getDocuments();
      } catch (exception, stacktrace) {
        FLog.info(
            className: 'UserPage Logic',
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
              className: 'UserPage logic',
              methodName: 'runBeforeBuild',
              text: 'exception',
              type: LogLevel.ERROR,
              exception: Exception(e),
              stacktrace: stacktrace);
        }
        try {
          await globals.user.getDocuments();
        } catch (exception, stacktrace) {
          catcher(exception, stacktrace, '?my=docs', force:true);
        }
        Scaffold.of(getContext()).removeCurrentSnackBar();
      }
    } else {
      globals.user.documents = cloneMap(documents);
    }
    setState(() {
      show = true;
    });
    await Future.delayed(Duration(milliseconds: 200));
    globals.isLoading.setState(4, true);
  } else {
    setState(() {
      show = true;
    });
  }
}

void showCustomMenu(String data, String title) {
  final RenderBox overlay = Overlay.of(getContext()).context.findRenderObject();

  showMenu(
          context: getContext(),
          items: <PopupMenuEntry<int>>[ContextEntry()],
          position: RelativeRect.fromRect(
              tapPosition & Size(40, 40), // smaller rect, the touch area
              Offset.zero & overlay.size // Bigger rect, the entire screen
              ))
      // This is how you handle user selection
      .then<void>((int delta) {
    // delta would be null if user taps on outside the popup menu
    // (causing it to close without making selection)
    if (delta == null) return;

    setState(() {
      if (delta == 1) {
        Clipboard.setData(ClipboardData(text: data));
        final snackBar = SnackBar(content: Text('copied').tr(args: [title]));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
        Scaffold.of(getContext()).showSnackBar(snackBar);
      } else {
        ShareExtend.share(data, 'text', sharePanelTitle: title);
      }
    });
  });
}

void storePosition(TapDownDetails details) {
  tapPosition = details.globalPosition;
}

BuildContext getContext() {
  if (globals.userPageKey.currentState != null) {
    return globals.userPageKey.currentState.context;
  } else {
    return globals.getScaffold();
  }
}

void setState(void Function() fun, {bool condition = true}) {
  if (globals.userPageKey.currentState != null) {
    if (globals.userPageKey.currentState.mounted && condition) {
      // ignore: invalid_use_of_protected_member
      globals.userPageKey.currentState.setState(fun);
    }
  }
}
