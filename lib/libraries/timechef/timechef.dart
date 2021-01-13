import 'dart:convert';
import 'dart:io';

import 'package:devinci/extra/globals.dart' as globals;

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
      l('is connected');
      try {
        l('try tokens');
        await testToken();
      } catch (exception) {
        try {
          l('go for login');
          await login();
        } catch (exception) {
          l('login exception');
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
        // ignore: empty_catches
      } catch (exception) {}
    }
    return;
  }

  Future<void> login() async {
    var client = HttpClient();
    if (username != '' && password != '') {
      l('cred ok');
      var jsonMap = <String, String>{
        'authType': '',
        'password': password,
        'username': username,
      };
      l('1');
      var request = await client.postUrl(
        Uri.parse('https://timechef.elior.com/api/oauth/?scope=timechef'),
      );
      l('6');
      request.followRedirects = false;
      l('2');
      request.headers.set('content-type', 'application/json');
      l('3');
      request.headers.set('Accept', 'application/json, text/plain, */*');
      l('4');
      request.add(utf8.encode(json.encode(jsonMap)));
      l('5');

      l(request);
      var response = await request.close();
      var body = await response.transform(utf8.decoder).join();
      l('login : ${response.statusCode}');
      if (response.statusCode == 200) {
        l(body);
        var resJson = json.decode(body);
        l(resJson);
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
    l('hi test');
    var client = HttpClient();
    if (accessToken != '') {
      l('accessToken = ${accessToken}');
      var request = await client.getUrl(
        Uri.parse('https://timechef.elior.com/api/oauth/me'),
      );
      request.followRedirects = false;
      request.headers.set('Authorization', 'Bearer ' + accessToken);
      request.headers.set('Accept', 'application/json, text/plain, */*');
      var response = await request.close();
      var body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        l('test : error : ${response.statusCode}');
        throw Exception('wrong tokens');
      } else {
        l(body);
      }
    } else {
      l('no access token');
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
        l(resJson);
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
          l(transactions);
        } else {}
      }
    } else {
      throw Exception('missing tokens or user has error');
    }
    return;
  }
}
