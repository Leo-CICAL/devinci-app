import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:f_logs/f_logs.dart';
import 'package:intl/intl.dart';
import 'package:matomo/matomo.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class DevinciApi {
  void register() async {
    if (globals.user != null) {
      //init matomo
      try {
        await MatomoTracker().initialize(
            siteId: 1,
            url: 'https://matomo.antoineraulin.com/piwik.php',
            visitorId: globals.user.tokens['uids']);
        MatomoTracker().setOptOut(!globals.analyticsConsent);
      } catch (e) {}
      if (globals.notifConsent) {
        var lastNotifRegistration =
            globals.prefs.getString('lastNotifRegistration') ?? '';
        String currentDate;
        final now = DateTime.now();
        final formatter = DateFormat('dd/MM/yyyy');
        currentDate = formatter.format(now);
        if (currentDate != lastNotifRegistration) {
          //on peut envoyer notre registration

          await globals.user.getPresence();
          var hashes = <String>[];
          globals.user.presence.forEach((presence) {
            var bytes = utf8.encode(presence['title'] +
                presence['prof'] +
                presence['horaires']); // data being hashed
            var digest = sha256.convert(bytes);
            hashes.add(digest.toString());
          });
          FLog.info(
              className: 'DevinciApi',
              methodName: 'register',
              text: hashes.toString());
          //l(hashes);
          try {
            var client = HttpClient();
            var uri = Uri.parse('https://devinci.antoineraulin.com/register');
            var req = await client.postUrl(uri);
            req.headers.set('content-type', 'application/json');
            var sub = await OneSignal.shared.getPermissionSubscriptionState();
            var sub2 = sub.subscriptionStatus;
            var id = sub2.userId;
            if (id != '') {
              var data = <String, dynamic>{'id': id, 'hashes': hashes};
              req.add(utf8.encode(json.encode(data)));
              var response = await req.close();
              var reply = await response.transform(utf8.decoder).join();
              FLog.info(
                  className: 'DevinciApi', methodName: 'register', text: reply);
              //l(reply);
              await globals.prefs
                  .setString('lastNotifRegistration', currentDate);
              client.close();
            } else {
              FLog.warning(
                  className: 'DevinciApi',
                  methodName: 'register',
                  text: 'no player id');
              //l('no player id');
            }
          } catch (err, stacktrace) {
            FLog.logThis(
                className: 'DevinciApi',
                methodName: 'register',
                text: 'exception',
                type: LogLevel.ERROR,
                exception: Exception(err),
                stacktrace: stacktrace);
          }
        } else {
          FLog.warning(
              className: 'DevinciApi',
              methodName: 'register',
              text: "can't send notif");
          //l("can't send notif");
        }
      } else {
        FLog.warning(
            className: 'DevinciApi',
            methodName: 'register',
            text: 'no notif consent');
        //l('no notif consent');
      }
    } else {
      FLog.warning(
          className: 'DevinciApi',
          methodName: 'register',
          text: 'user not existing');
      //l('user not existing');
    }
  }

  void call(String hash) async {
    if (globals.user != null) {
      if (globals.notifConsent) {
        var client = HttpClient();
        var uri = Uri.parse('https://devinci.antoineraulin.com/call');
        var req = await client.postUrl(uri);
        req.headers.set('content-type', 'application/json');
        var sub = await OneSignal.shared.getPermissionSubscriptionState();
        var sub2 = sub.subscriptionStatus;
        var id = sub2.userId;
        if (id != '') {
          var data = <String, dynamic>{'id': id, 'hash': hash};
          req.add(utf8.encode(json.encode(data)));
          var response = await req.close();
          var reply = await response.transform(utf8.decoder).join();
          FLog.info(className: 'DevinciApi', methodName: 'call', text: reply);
          //l(reply);
          client.close();
        } else {
          FLog.warning(
              className: 'DevinciApi',
              methodName: 'call',
              text: 'no player id');
          //l('no player id');
        }
      } else {
        FLog.warning(
            className: 'DevinciApi',
            methodName: 'call',
            text: 'no notif consent');
        //l('no notif consent');
      }
    } else {
      FLog.warning(
          className: 'DevinciApi',
          methodName: 'call',
          text: 'user not existing');
      //l('user not existing');
    }
  }
}
