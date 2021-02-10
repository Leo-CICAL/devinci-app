import 'dart:convert';
import 'dart:io';

import 'package:devinci/extra/globals.dart' as globals;
import 'package:f_logs/f_logs.dart';

class TimeChefUser {
  TimeChefUser(String username, String password) {
    this.username = username;
    this.password = password;
  }

  String username;
  String password;

  bool error = false;
  int code = 200;

  String accessToken = '';

  String displayName = '';

  double solde;

  List<Map<String, dynamic>> transactions = [];

  bool fetched = false;
  bool tFetched = false;

  Future<void> init() async {
    //retrieve tokens from secure storage (if they exist)
    accessToken = await globals.storage.read(key: 'SimpleSAML') ?? '';

    if (globals.isConnected) {
      FLog.info(
          className: 'TimeChefUser', methodName: 'init', text: 'is connected');
      try {
        FLog.info(
            className: 'TimeChefUser', methodName: 'init', text: 'try tokens');
        await testToken();
      } catch (exception, stacktrace) {
        FLog.logThis(
            className: 'TimeChefUser',
            methodName: 'init',
            text: 'exception',
            type: LogLevel.ERROR,
            exception: Exception(exception),
            stacktrace: stacktrace);
        try {
          FLog.info(
              className: 'TimeChefUser',
              methodName: 'init',
              text: 'go for login');
          await login();
        } catch (exception, stacktrace) {
          FLog.logThis(
              className: 'TimeChefUser',
              methodName: 'init',
              text: 'exception',
              type: LogLevel.ERROR,
              exception: Exception(exception),
              stacktrace: stacktrace);
          //getTokens throw an exception if an error occurs during the retrieving or if credentials are wrong
          if (code == 500) {
            //the exception was thrown by a dart process, which meens that credentials may be good, but the function had trouble to access the server.

          } else if (code == 401) {
            await globals.storage
                .deleteAll(); //remove all sensitive data from the phone if the user can't connect
            //the exception was thrown because credentials are wrong
            throw Exception(
                'wrong credentials : $exception'); //throw an exception to indicate to the parent process that credentials are wrong and may need to be changed
          } else {
            throw Exception(exception); //we don't know what happened here
          }
        }
      }

      await globals.storage.write(key: 'timechefusername', value: username);
      await globals.storage.write(key: 'timechefpassword', value: password);
      password = null;
      try {
        await getData();
      } catch (exception, stacktrace) {
        FLog.logThis(
            className: 'TimeChefUser',
            methodName: 'init',
            text: 'exception',
            type: LogLevel.ERROR,
            exception: Exception(exception),
            stacktrace: stacktrace);
      }
    }
    return;
  }

  Future<void> login() async {
    var client = HttpClient();
    if (username != '' && password != '') {
      FLog.info(
          className: 'TimeChefUser', methodName: 'login', text: 'cred ok');
      var jsonMap = <String, String>{
        'authType': '',
        'password': password,
        'username': username,
      };
      FLog.info(className: 'TimeChefUser', methodName: 'login', text: '1');
      var request = await client.postUrl(
        Uri.parse('https://timechef.elior.com/api/oauth/?scope=timechef'),
      );
      FLog.info(className: 'TimeChefUser', methodName: 'login', text: '6');
      request.followRedirects = false;
      FLog.info(className: 'TimeChefUser', methodName: 'login', text: '2');
      request.headers.set('content-type', 'application/json');
      FLog.info(className: 'TimeChefUser', methodName: 'login', text: '3');
      request.headers.set('Accept', 'application/json, text/plain, */*');
      FLog.info(className: 'TimeChefUser', methodName: 'login', text: '4');
      request.add(utf8.encode(json.encode(jsonMap)));
      FLog.info(className: 'TimeChefUser', methodName: 'login', text: '5');

      FLog.info(
          className: 'TimeChefUser',
          methodName: 'login',
          text: request.toString());
      var response = await request.close();
      var body = await response.transform(utf8.decoder).join();
      FLog.info(
          className: 'TimeChefUser',
          methodName: 'login',
          text: 'login : ${response.statusCode}');
      if (response.statusCode == 200) {
        FLog.info(className: 'TimeChefUser', methodName: 'login', text: body);
        var resJson = json.decode(body);
        FLog.info(
            className: 'TimeChefUser',
            methodName: 'login',
            text: resJson.toString());
        accessToken = resJson['accessToken'];
      } else {
        error = true;
        code = response.statusCode;
        throw Exception('Error while retrieving token');
      }
    } else {
      error = true;
      code = 400;
      throw Exception('missing parameters');
    }
    return;
  }

  Future<void> testToken() async {
    FLog.info(
        className: 'TimeChefUser', methodName: 'testToken', text: 'hi test');
    var client = HttpClient();
    if (accessToken != '') {
      FLog.info(
          className: 'TimeChefUser',
          methodName: 'testToken',
          text: 'accessToken = ${accessToken}');
      var request = await client.getUrl(
        Uri.parse('https://timechef.elior.com/api/oauth/me'),
      );
      request.followRedirects = false;
      request.headers.set('Authorization', 'Bearer ' + accessToken);
      request.headers.set('Accept', 'application/json, text/plain, */*');
      var response = await request.close();
      var body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw Exception('wrong tokens');
      } else {
        FLog.info(
            className: 'TimeChefUser', methodName: 'testToken', text: body);
      }
    } else {
      FLog.info(
          className: 'TimeChefUser',
          methodName: 'testToken',
          text: 'no access token');
      throw Exception('missing tokens or user has error');
    }
    return;
  }

  Future<void> getData() async {
    var client = HttpClient();
    if (accessToken != '') {
      var request = await client.getUrl(
        Uri.parse(
            'https://timechef.elior.com/api/convive/Pulvrestauration/solde'),
      );
      request.followRedirects = false;
      request.headers.set('Authorization', 'Bearer ' + accessToken);
      request.headers.set('Accept', 'application/json, text/plain, */*');
      var response = await request.close();
      var body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw Exception('wrong tokens');
      } else {
        var resJson = json.decode(body);
        FLog.info(
            className: 'TimeChefUser',
            methodName: 'getData',
            text: resJson.toString());
        solde = resJson['solde'];
      }
    } else {
      throw Exception('missing tokens or user has error');
    }
    return;
  }

  Future<void> getTransactions() async {
    var client = HttpClient();
    if (accessToken != '') {
      var request = await client.getUrl(
        Uri.parse(
            'https://timechef.elior.com/api/Pulvrestauration/tickets?pagesize=10&pageindex=0&includeDetail=true'),
      );
      request.followRedirects = false;
      request.headers.set('Authorization', 'Bearer ' + accessToken);
      request.headers.set('Accept', 'application/json, text/plain, */*');
      var response = await request.close();
      var body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw Exception('wrong tokens');
      } else {
        var resJson = json.decode(body);
        tFetched = true;
        if (resJson.isNotEmpty) {
          for (var i = 0; i < resJson.length; i++) {
            double montant = resJson[i]['montant'];
            var date = DateTime.parse(resJson[i]['date']);
            var details = resJson[i]['ticketDetail'];
            var txt = '';
            for (var j = 0; j < details.length; j++) {
              txt += '${details[j]['libelle']} : ${details[j]['price']}€';
              if (j != details.length - 1) {
                txt += '\n';
              }
            }
            transactions.add({
              'montant': montant,
              'date': date,
              'details': details,
              'detailsTxt': txt
            });
          }
          FLog.info(
              className: 'TimeChefUser',
              methodName: 'getTransactions',
              text: transactions.toString());
        } else {}
      }
    } else {
      throw Exception('missing tokens or user has error');
    }
    return;
  }
}
