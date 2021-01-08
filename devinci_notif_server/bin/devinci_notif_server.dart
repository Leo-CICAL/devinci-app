import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:devinci_notif_server/devinci/devinci.dart';
import 'package:cron/cron.dart';

var crons = <Cron>[];
Config config;

Future main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption('config', abbr: 'c', defaultsTo: 'config.json');
  var results = parser.parse(arguments);
  final cron = Cron();
  var configRaw = File(results['config']).readAsStringSync();
  config = fromJson(configRaw);
  setup();
  cron.schedule(Schedule.parse('2 6 * * 1-6'), () async {
    setup();
  });
}

void setup() async {
  var user = User(config.username, config.password);
  crons.clear();
  await user.init();
  await user.getPresence();
  var hashes = <String>[];
  for (var i = 0; i < user.presence.length; i++) {
    var cours = user.presence[i];
    var bytes = utf8.encode(cours['title'] +
        cours['prof'] +
        cours['horaires']); // data being hashed
    var digest = sha256.convert(bytes);
    hashes.add(digest.toString());
    print(cours);
    if (cours['horaires'] != '') {
      var horaires = cours['horaires'].split('-');
      if (horaires.length > 1) {
        final now = DateTime.now();

        var h = horaires[0].split(':');
        var hh = int.parse(h[0]);
        var hm = int.parse(h[1]);
        var h2 = horaires[1].split(':');
        var h2h = int.parse(h2[0]);
        var h2m = int.parse(h2[1]);
        crons.add(Cron());
        if (now.hour > h2h) {
          //le cours est forcement fini
          //print('cours $i passed');
        } else if ((now.hour == h2h && now.minute < h2m) || now.hour < h2h) {
          //le cours n'est pas fini
          if (now.hour > hh) {
            runCron(
                i, '${now.minute + 1} ${now.hour} * * *', '$h2m $h2h * * *');
          } else if (now.hour == hh && now.minute >= hm) {
            // le cours a commencé
            runCron(
                i, '${now.minute + 1} ${now.hour} * * *', '$h2m $h2h * * *');
          } else if ((now.hour == hh && now.minute < hm) || now.hour < h2h) {
            //bon heure mais pas encore minute ou trop tot
            //le cours n'a pas encore commencé
            runCron(i, '$hm $hh * * *', '$h2m $h2h * * *');
          }
        }
      }
    }
  }
  var client = HttpClient();
  var uri = Uri.parse('https://api.devinci.araulin.tech/register');
  var req = await client.postUrl(uri);
  req.headers.set('content-type', 'application/json');
  var data = <String, dynamic>{'id': config.id, 'hashes': hashes};
  req.add(utf8.encode(json.encode(data)));
  var response = await req.close();
  var reply = await response.transform(utf8.decoder).join();
  //print(reply);
}

void runCron(int index, String cronStr, String cronStr2) {
  //print(
  //    'defined a new cron : index : $index | str : $cronStr | str2 : $cronStr2');
  var cron = crons[index];
  var stopCron = Cron();
  cron.schedule(Schedule.parse(cronStr), () async {
    var go = true;
    var user = User(config.username, config.password);
    await user.init();
    var timer = Timer.periodic(Duration(seconds: 30), (Timer t) async {
      //print('cron #$index - fast start');
      await user.getPresence();
      if (user.presence[index]['type'] == 'ongoing' ||
          user.presence[index]['type'] == 'done' ||
          user.presence[index]['type'] == 'closed') {
        await cron.close();
        var bytes = utf8.encode(user.presence[index]['title'] +
            user.presence[index]['prof'] +
            user.presence[index]['horaires']); // data being hashed
        var digest = sha256.convert(bytes);
        call(digest.toString());
        go = false;
        t.cancel();
      }
    });
    Timer(Duration(minutes: 2), () {
      if (go) {
        timer.cancel();
        //print('cancel first');
        Timer.periodic(Duration(minutes: 1), (Timer t) async {
          //print('cron #$index');
          await user.getPresence();
          if (user.presence[index]['type'] == 'ongoing' ||
              user.presence[index]['type'] == 'done' ||
              user.presence[index]['type'] == 'closed') {
            await cron.close();
            var bytes = utf8.encode(user.presence[index]['title'] +
                user.presence[index]['prof'] +
                user.presence[index]['horaires']); // data being hashed
            var digest = sha256.convert(bytes);
            call(digest.toString());
            go = false;
            t.cancel();
          }
        });
      }
    });
  });
  stopCron.schedule(Schedule.parse(cronStr2), () async {
    await cron.close();
    await stopCron.close();
  });
}

void call(String hash) async {
  var client = HttpClient();
  var uri = Uri.parse('https://api.devinci.araulin.tech/call');
  var req = await client.postUrl(uri);
  req.headers.set('content-type', 'application/json');
  var data = <String, dynamic>{'id': config.id, 'hash': hash};
  req.add(utf8.encode(json.encode(data)));
  var response = await req.close();
  var reply = await response.transform(utf8.decoder).join();
  //print(reply);
  client.close();
}

class Config {
  final String username;
  final String password;
  final String id;
  Config(this.username, this.password, this.id);
}

Config fromJson(String jsonString) {
  Map<String, dynamic> json = jsonDecode(jsonString);
  String username = json['username'];
  String password = json['password'];
  String id = json['id'];
  var c = Config(username, password, id);
  return c;
}
