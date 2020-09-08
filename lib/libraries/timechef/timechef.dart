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
    this.accessToken = await globals.storage.read(key: "SimpleSAML") ?? '';

    if (globals.isConnected) {
      print("is connected");
      try {
        print("try tokens");
        await this.testToken();
      } catch (exception) {
        try {
          print("go for login");
          await this.login();
        } catch (exception) {
          print("login exception");
          //getTokens throw an exception if an error occurs during the retrieving or if credentials are wrong
          if (this.code == 500) {
            //the exception was thrown by a dart process, which meens that credentials may be good, but the function had trouble to access the server.

          } else if (this.code == 401) {
            await globals.storage
                .deleteAll(); //remove all sensitive data from the phone if the user can't connect
            //the exception was thrown because credentials are wrong
            throw Exception(
                "wrong credentials : $exception"); //throw an exception to indicate to the parent process that credentials are wrong and may need to be changed
          } else {
            throw Exception(exception); //we don't know what happened here
          }
        }
      }

      await globals.storage
          .write(key: "timechefusername", value: this.username);
      await globals.storage
          .write(key: "timechefpassword", value: this.password);
      this.password = null;
      try {
        await this.getData();
      } catch (exception) {}
    }
    return;
  }

  Future<void> login() async {
    HttpClient client = new HttpClient();
    if (this.username != '' && this.password != '') {
      print("cred ok");
      Map<String, String> jsonMap = {
        'authType': '',
        'password': this.password,
        'username': this.username,
      };
      print("1");
      HttpClientRequest request = await client.postUrl(
        Uri.parse('https://timechef.elior.com/api/oauth/?scope=timechef'),
      );
      print("6");
      request.followRedirects = false;
      print("2");
      request.headers.set('content-type', 'application/json');
      print("3");
      request.headers.set('Accept', 'application/json, text/plain, */*');
      print("4");
      request.add(utf8.encode(json.encode(jsonMap)));
      print("5");

      print(request);
      HttpClientResponse response = await request.close();
      String body = await response.transform(utf8.decoder).join();
      print("login : ${response.statusCode}");
      if (response.statusCode == 200) {
        print(body);
        var resJson = json.decode(body);
        print(resJson);
        this.accessToken = resJson["accessToken"];
      } else {
        this.error = true;
        this.code = response.statusCode;
        throw Exception("Error while retrieving token");
      }
    } else {
      this.error = true;
      this.code = 400;
      throw Exception("missing parameters");
    }
    return;
  }

  Future<void> testToken() async {
    print("hi test");
    HttpClient client = new HttpClient();
    if (this.accessToken != '') {
      print('accessToken = ${this.accessToken}');
      HttpClientRequest request = await client.getUrl(
        Uri.parse('https://timechef.elior.com/api/oauth/me'),
      );
      request.followRedirects = false;
      request.headers.set('Authorization', 'Bearer ' + this.accessToken);
      request.headers.set('Accept', 'application/json, text/plain, */*');
      HttpClientResponse response = await request.close();
      String body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        print("test : error : ${response.statusCode}");
        throw Exception("wrong tokens");
      } else {
        print(body);
      }
    } else {
      print('no access token');
      throw Exception("missing tokens or user has error");
    }
    return;
  }

  Future<void> getData() async {
    HttpClient client = new HttpClient();
    if (this.accessToken != '') {
      HttpClientRequest request = await client.getUrl(
        Uri.parse(
            'https://timechef.elior.com/api/convive/Pulvrestauration/solde'),
      );
      request.followRedirects = false;
      request.headers.set('Authorization', 'Bearer ' + this.accessToken);
      request.headers.set('Accept', 'application/json, text/plain, */*');
      HttpClientResponse response = await request.close();
      String body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw Exception("wrong tokens");
      } else {
        var resJson = json.decode(body);
        print(resJson);
        this.solde = resJson['solde'];
      }
    } else {
      throw Exception("missing tokens or user has error");
    }
    return;
  }

  Future<void> getTransactions() async {
    HttpClient client = new HttpClient();
    if (this.accessToken != '') {
      HttpClientRequest request = await client.getUrl(
        Uri.parse(
            'https://timechef.elior.com/api/Pulvrestauration/tickets?pagesize=10&pageindex=0&includeDetail=true'),
      );
      request.followRedirects = false;
      request.headers.set('Authorization', 'Bearer ' + this.accessToken);
      request.headers.set('Accept', 'application/json, text/plain, */*');
      HttpClientResponse response = await request.close();
      String body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw Exception("wrong tokens");
      } else {
        var resJson = json.decode(body);
        tFetched = true;
        if (resJson.isNotEmpty) {
          for (int i = 0; i < resJson.length; i++) {
            double montant = resJson[i]['montant'];
            DateTime date = DateTime.parse(resJson[i]['date']);
            var details = resJson[i]['ticketDetail'];
            String txt = '';
            for (int j = 0; j < details.length; j++) {
              txt += '${details[j]['libelle']} : ${details[j]['price']}€';
              if (j != details.length - 1) {
                txt += '\n';
              }
            }
            transactions.add({
              "montant": montant,
              "date": date,
              "details": details,
              'detailsTxt': txt
            });
          }
          print(transactions);
        } else {}
      }
    } else {
      throw Exception("missing tokens or user has error");
    }
    return;
  }
}
