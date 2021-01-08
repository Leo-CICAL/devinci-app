import 'dart:io';
import 'dart:convert';
import 'functions.dart';
import 'package:html/parser.dart' show parse;

class User {
  //constructor
  User(String username, String password) {
    this.username = username;
    this.password = password;
  }

  //values
  String username;
  String password;

  bool error = false;
  int code = 200;

  Map<String, String> tokens = {
    'SimpleSAML': '',
    'alv': '',
    'uids': '',
    'SimpleSAMLAuthToken': '',
  };

  void reset() async {
    tokens['SimpleSAML'] = '';
    tokens['alv'] = '';
    tokens['SimpleSAMLAuthToken'] = '';
  }

  Map<String, String> data = {
    'badge': '',
    'client': '',
    'idAdmin': '',
    'ine': '',
    'edtUrl': '',
    'name': '',
    'ecole': '',
  };

  List<Map<String, dynamic>> presence = [
    // {
    //   'type': 'none', //5 types : ongoing / done / notOpen / none / closed
    //   'title': '',
    //   'horaires': '',
    //   'prof': '',
    //   'seance_pk': '',
    //   'zoom': '',
    //   'zoom_pwd': '',
    // }
  ];

  int presenceIndex = 0;

  Future<void> init() async {
    try {
      l('test tokens');
      await testTokens()
          .timeout(Duration(seconds: 8), onTimeout: () {})
          .catchError((exception) async {
        l('test tokens exception : $exception');
        //testTokens throw an exception if tokens don't exist or if they aren't valid
        //as the tokens don't exist yet or aren't valid, we shall retrieve them from devinci's server
        try {
          await getTokens();
        } catch (exception) {
          //getTokens throw an exception if an error occurs during the retrieving or if credentials are wrong
          if (code == 500) {
            //the exception was thrown by a dart process, which meens that credentials may be good, but the function had trouble to access the server.

          } else if (code == 401) {
            throw Exception(
                'wrong credentials : $exception'); //throw an exception to indicate to the parent process that credentials are wrong and may need to be changed
          } else {
            throw Exception(exception); //we don't know what happened here
          }
        }
      }); //test if tokens exist and if so, test if they are still valid
    } catch (exception) {
      l('test tokens exception : $exception');

      //testTokens throw an exception if tokens don't exist or if they aren't valid
      //as the tokens don't exist yet or aren't valid, we shall retrieve them from devinci's server
      try {
        await getTokens();
      } catch (exception) {
        //getTokens throw an exception if an error occurs during the retrieving or if credentials are wrong
        if (code == 500) {
          //the exception was thrown by a dart process, which meens that credentials may be good, but the function had trouble to access the server.

        } else if (code == 401) {
          //the exception was thrown because credentials are wrong
          throw Exception(
              'wrong credentials : $exception'); //throw an exception to indicate to the parent process that credentials are wrong and may need to be changed
        } else {
          throw Exception(exception); //we don't know what happened here
        }
      }
    }
    //if we manage to arrive here it means that we have valid tokens and that credentials are good
    password =
        null; //if tokens are still valid we'll never need the password again in this session, so it is useless to keep it in the object and risk it to be leaked or displayed
    //print('done init');
    return;
  }

  Future<void> getTokens() async {
    var client = HttpClient();

    if (username != '' && password != '') {
      var req = await client.getUrl(
        Uri.parse('https://www.leonard-de-vinci.net/'),
      );
      var res = await req.close();

      l('statusCode : ${res.statusCode}');
      l('headers : ${res.headers}');
      l('STEP 1 : HEADERS - SET-COOKIE : ${res.headers.value("set-cookie")}');
      var regExp = RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
      tokens['alv'] = regExp
          .firstMatch(
            res.headers.value('set-cookie'),
          )
          .group(2);
      l('ALV : "${tokens['alv']}"');
      if (res.statusCode == 200) {
        req = await client.postUrl(
            Uri.parse('https://www.leonard-de-vinci.net/ajax.inc.php'));
        req.headers.set(
            'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        req.headers.set('Referer', 'https://www.leonard-de-vinci.net/');
        req.headers.set('Cookie', 'alv=${tokens["alv"]}');
        req.write('act=ident_analyse&login=' + Uri.encodeComponent(username));
        l('[STEP 2] REQ HEADERS : ${req.headers}');
        res = await req.close();
        l('[STEP 2] statusCode : ${res.statusCode}');
        l('[STEP 2] RES headers : ${res.headers}');
        var body = await res.transform(utf8.decoder).join();
        //l('[STEP 2] BODY : $body');
        if (body.contains('location')) {
          l('username correct');

          req = await client.getUrl(
            Uri.parse(
                'https://www.leonard-de-vinci.net/login.sso.php?username=' +
                    Uri.encodeComponent(username)),
          );
          req.followRedirects = false;
          req.headers.set('Referer', 'https://www.leonard-de-vinci.net/');
          req.headers.set('Cookie', 'alv=${tokens["alv"]}');
          l('[STEP 3] REQ HEADERS : ${req.headers}');
          res = await req.close();
          l('[STEP 3] statusCode : ${res.statusCode}');
          l('[STEP 3] RES headers : ${res.headers}');
          tokens['SimpleSAML'] = regExp
              .firstMatch(
                res.headers.value('set-cookie'),
              )
              .group(2);
          l('SimpleSAML : "${tokens['SimpleSAML']}"');

          var redUrl = res.headers.value('location');

          req = await client.getUrl(
            Uri.parse(redUrl),
          );
          res = await req.close();
          l('[STEP 4] statusCode : ${res.statusCode}');
          l('[STEP 4] RES headers : ${res.headers}');
          body = await res.transform(utf8.decoder).join();
          //l('[STEP 4] BODY : $body');
          regExp = RegExp(r'action="\/adfs(.*?)"');
          var url =
              'https://adfs.devinci.fr/adfs' + regExp.firstMatch(body).group(1);
          l('[STEP 4] url : $url');

          req = await client.postUrl(
            Uri.parse(url),
          );
          req.headers.set('Content-Type', 'application/x-www-form-urlencoded');
          req.write('UserName=' +
              Uri.encodeComponent(username) +
              '&Password=' +
              Uri.encodeComponent(password) +
              '&AuthMethod=FormsAuthentication');
          l('[STEP 5] REQ HEADERS : ${req.headers}');
          res = await req.close();
          l('[STEP 5] statusCode : ${res.statusCode}');
          l('[STEP 5] RES headers : ${res.headers}');

          if (res.headers.value('set-cookie') != null &&
              res.statusCode == 302) {
            l('connected');
            regExp = RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
            // ignore: non_constant_identifier_names
            var MSISAuth = regExp
                .firstMatch(
                  res.headers.value('set-cookie'),
                )
                .group(2);
            redUrl = res.headers.value('location');

            req = await client.getUrl(
              Uri.parse(redUrl),
            );
            req.headers.set('Cookie', 'MSISAuth=' + MSISAuth);
            l('[STEP 6] REQ HEADERS : ${req.headers}');
            res = await req.close();
            l('[STEP 6] statusCode : ${res.statusCode}');
            l('[STEP 6] RES headers : ${res.headers}');
            body = await res.transform(utf8.decoder).join();
            regExp = RegExp(r'value="(.*?)"');
            var value = regExp.firstMatch(body).group(1);

            l('value : $value');
            req = await client.postUrl(
              Uri.parse(
                  'https://www.leonard-de-vinci.net/include/SAML/module.php/saml/sp/saml2-acs.php/devinci-sp'),
            );
            req.headers
                .set('Content-Type', 'application/x-www-form-urlencoded');
            req.headers.set('Cookie',
                "alv=${tokens["alv"]}; SimpleSAML=${tokens["SimpleSAML"]}");
            req.followRedirects = false;
            var b = 'SAMLResponse=' +
                Uri.encodeComponent(value) +
                '&RelayState=https://www.leonard-de-vinci.net/login.sso.php';
            req.write(b);
            l('[STEP 7] REQ HEADERS : ${req.headers}');
            res = await req.close();
            l('[STEP 7] statusCode : ${res.statusCode}');
            l('[STEP 7] RES headers : ${res.headers}');
            body = await res.transform(utf8.decoder).join();
            l("set-cookie : ${res.headers['set-cookie']}");
            if (res.statusCode == 303) {
              redUrl = res.headers.value('location');
              regExp = RegExp(r'(.*?)=(.*?)($|;|,(?! ))');
              tokens['SimpleSAMLAuthToken'] = regExp
                  .firstMatch(
                    res.headers['set-cookie'][1],
                  )
                  .group(2);
              l('SimpleSAMLAuthToken : "${tokens["SimpleSAMLAuthToken"]}"');

              req = await client.getUrl(
                Uri.parse(redUrl),
              );
              req.followRedirects = false;
              req.headers.set(
                  'Cookie',
                  'alv=' +
                      tokens['alv'] +
                      '; SimpleSAML=' +
                      tokens['SimpleSAML'] +
                      '; SimpleSAMLAuthToken=' +
                      tokens['SimpleSAMLAuthToken']);
              l('[STEP 8] REQ HEADERS : ${req.headers}');
              res = await req.close();
              l('[STEP 8] statusCode : ${res.statusCode}');
              l('[STEP 8] RES headers : ${res.headers}');
              //body = await res.transform(utf8.decoder).join();
              tokens['uids'] = regExp
                  .firstMatch(
                    res.headers['set-cookie'][2],
                  )
                  .group(2);
              l('uids : "${tokens["uids"]}"');
              error = false;
              code = 200;
            } else {
              error = true;
              code = res.statusCode;
              throw Exception('unhandled error');
            }
          } else {
            error = true;
            code = 401;
            throw Exception('wrong credentials');
          }
        } else {
          l('username incorrect');
          error = true;
          code = 401;
          throw Exception('wrong credentials');
        }
      } else {
        error = true;
        code = res.statusCode;
        throw Exception('Error while retrieving alv token');
      }
    } else {
      error = true;
      code = 400;
      throw Exception('missing parameters');
    }
    return;
  }

  Future<void> testTokens() async {
    var response = await devinciRequest(tokens);
    if (response != null) {
      l('statusCode : ${response.statusCode}');
      l('headers : ${response.headers}');
      var body = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        //print(body);
        if (body.contains("('#password').hide();")) {
          l('error');
          throw Exception('wrong tokens');
        } else {
          error = false;
          code = 200;
        }
      } else {
        throw Exception('wrong tokens -> statuscode : ${response.statusCode}');
      }
    } else {
      error = true;
      code = 400;
      throw Exception('missing tokens or user as error');
    }
    return;
  }

  Future<void> getPresence({bool force = false}) async {
    var res = await devinciRequest(tokens, endpoint: 'student/presences/');
    if (res != null) {
      if (res.statusCode == 200) {
        var body = await res.transform(utf8.decoder).join();
        if (body.contains('Pas de cours de prévu')) {
          //this.presence[0]['type'] = 'none';
        } else {
          var doc = parse(body);
          var trs = doc.querySelectorAll('table > tbody > tr');
          presenceIndex = trs.length - 1;
          presence.clear();
          for (var i = 0; i < trs.length; i++) {
            presence.add({
              'type':
                  'none', //5 types : ongoing / done / notOpen / none / closed
              'title': '',
              'horaires': '',
              'prof': '',
              'seance_pk': '',
              'zoom': '',
              'zoom_pwd': '',
            });
          }
          for (var i = 0; i < trs.length; i++) {
            var tr = trs[i];
            var classe = tr.attributes['class'];
            if (classe == '' || classe == 'warning') {
              presenceIndex = i;
              break;
            }
          }

          for (var i = 0; i < trs.length; i++) {
            var tds = trs[i].querySelectorAll('td');
            presence[i]['horaires'] =
                tds[0].text.replaceAllMapped(RegExp(r' '), (match) {
              return '';
            });
            presence[i]['title'] = tds[1].text;
            presence[i]['prof'] = tds[2].text;
            try {
              presence[i]['zoom'] =
                  tds[4].querySelector('a').attributes['href'];
              presence[i]['zoom_pwd'] = tds[4]
                  .querySelector('span')
                  .attributes['title']
                  .split(': ')[1];
            } catch (e) {
              print(e);
            }
            var nextLink = tds[3].querySelector('a').attributes['href'];
            res = await devinciRequest(tokens, endpoint: nextLink.substring(1));
            if (res.statusCode == 200) {
              print('go');
              var body = await res.transform(utf8.decoder).join();
              if (body.contains('pas encore ouvert')) {
                presence[i]['type'] = 'notOpen';
              } else {
                if (body.contains('Valider')) {
                  presence[i]['type'] = 'ongoing';
                  presence[i]['seance_pk'] =
                      RegExp(r"seance_pk : '(.*?)'").firstMatch(body).group(1);
                } else if (body.contains('Vous avez été noté présent')) {
                  presence[i]['type'] = 'done';
                } else if (body.contains('clôturé')) {
                  presence[i]['type'] = 'closed';
                }
              }
            } else {
              presence[i]['type'] = 'none';
            }
          }
        }
      } else {
        error = true;
        code = res.statusCode;
        throw Exception('unhandled exception');
      }
    } else {
      throw Exception(400); //missing parameters
    }

    print(presence);
    return;
  }

  Future<void> setPresence(int index, {bool force = false}) async {
    var res = await devinciRequest(tokens,
        endpoint: 'student/presences/upload.php',
        method: 'POST',
        headers: [
          ['Connection', 'keep-alive'],
          ['Accept', '*/*'],
          ['DNT', '1'],
          ['X-Requested-With', 'XMLHttpRequest'],
          [
            'User-Agent',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36 Edg/81.0.416.64'
          ],
          ['Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'],
          ['Origin', 'https://www.leonard-de-vinci.net'],
          ['Sec-Fetch-Site', 'same-origin'],
          ['Sec-Fetch-Mode', 'cors'],
          ['Sec-Fetch-Dest', 'empty'],
          [
            'Referer',
            'https://www.leonard-de-vinci.net/student/presences/' +
                Uri.encodeComponent(presence[index]['seance_pk'])
          ],
          [
            'Accept-Language',
            'fr,fr-FR;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6'
          ],
        ],
        data: 'act=set_present&seance_pk=' +
            Uri.encodeComponent(presence[index]['seance_pk']));
    if (res != null) {
      if (res.statusCode == 200) {
        presence[index]['type'] = 'done';
      } else {
        throw Exception(res.statusCode);
      }
    } else {
      throw Exception(400); //missing parameters
    }
    return;
  }
}
