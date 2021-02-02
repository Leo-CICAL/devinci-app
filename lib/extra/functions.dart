import 'dart:io';
import 'dart:typed_data';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:devinci/libraries/f_logs/f_logs.dart';
import 'package:devinci/libraries/feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry/sentry.dart';

void betterFeedbackOnFeedback(
  BuildContext context,
  String feedbackText, // the feedback from the user
  Uint8List feedbackScreenshot, // raw png encoded image data
) async {
  Directory directory = await getApplicationDocumentsDirectory();

  final path = directory.path;
  var attachment = File(path + '/devinci_f.png');
  var attachmentNotes = File(path + '/devinci_n.txt');
  await attachment.writeAsBytes(feedbackScreenshot);
  await attachmentNotes.writeAsString(globals.feedbackNotes);
  //l(attachment.path);
  // final email = Email(
  //   body:
  //       '$feedbackText\n\n Erreur:${globals.feedbackError}\n StackTrace:${globals.feedbackStackTrace.toString()}\n eventId : ${globals.eventId}',
  //   subject: 'Devinci - Erreur',
  //   recipients: ['antoine@araulin.eu'],
  //   attachmentPaths: [attachment.path, attachmentNotes.path],
  //   isHTML: false,
  // );

  // await FlutterEmailSender.send(email);
}

Future<Null> reportError(dynamic error, dynamic stackTrace) async {
  FLog.logThis(
      className: 'functions',
      methodName: 'reportError',
      text: 'caught an exception',
      type: LogLevel.ERROR,
      exception: Exception(error),
      stacktrace: stackTrace);
  var err = error.toString();
  var consent = globals.prefs.getString('crashConsent');
  if (consent == 'true') {
    reportToCrash(err, stackTrace);
  } else {
    final snackBar = SnackBar(
      content: Text(
          "Une erreur est survenue, mais nous n'avons pas envoyer de rapport d'incident"),
      action: SnackBarAction(
        label: 'Envoyer',
        onPressed: () => reportToCrash(err, stackTrace),
      ),
      duration: const Duration(seconds: 6),
    );

// Find the Scaffold in the widget tree and use it to show a SnackBar.
    globals.mainScaffoldKey.currentState.showSnackBar(snackBar);
  }
}

bool get isInDebugMode {
  // Assume you're in production mode.
  var inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  return inDebugMode;
}

void reportToCrash(var err, StackTrace stackTrace) async {
  final snackBar = SnackBar(
    content: Text('Une erreur est survenue'),
    action: SnackBarAction(
        label: 'Ajouter des informations',
        onPressed: () async {
          globals.feedbackError = err.toString();
          globals.feedbackStackTrace = stackTrace;
          //BetterFeedback.of(globals.getScaffold()).show();
        }),
  );
  globals.mainScaffoldKey.currentState.showSnackBar(snackBar);
  // Errors thrown in development mode are unlikely to be interesting. You can
  // check if you are running in dev mode using an assertion and omit sending
  // the report.
  if (isInDebugMode) {
    FLog.info(
        className: 'functions',
        methodName: 'reportToCrash',
        text: 'in dev mode. Not sending report to Sentry.');
    return;
  }
  if (globals.crashConsent == 'true') {
    FLog.info(
        className: 'functions',
        methodName: 'reportToCrash',
        text: 'Reporting to Sentry...');
    await Sentry.captureException(
      err,
      stackTrace: stackTrace,
    );
  }
}

Future<CanAuthenticateResponse> checkAuthenticate() async {
  final response = await BiometricStorage().canAuthenticate();
  FLog.info(
      className: 'functions',
      methodName: 'checkAuthenticate',
      text: 'checked if authentication was possible: $response');
  return response;
}

void fieldFocusChange(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
