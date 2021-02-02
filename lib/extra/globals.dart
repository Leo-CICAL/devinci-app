import 'package:biometric_storage/biometric_storage.dart';
import 'package:devinci/extra/classes.dart';
import 'package:devinci/libraries/devinci/extra/classes.dart';
import 'package:devinci/pages/ui/login.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences prefs;

BiometricStorageFile storageUsername;
BiometricStorageFile storagePassword;
BiometricStorageFile storageSimpleSAML;
BiometricStorageFile storageAlv;
BiometricStorageFile storageUids;
BiometricStorageFile storageSimpleSAMLAuthToken;
BiometricStorageFile storageBadge;
BiometricStorageFile storageClient;
BiometricStorageFile storageIdAdmin;
BiometricStorageFile storageIne;
BiometricStorageFile storageEdtUrl;
BiometricStorageFile storageName;

void storageDeleteAll() {
  storageUsername.delete();
  storagePassword.delete();
  storageSimpleSAMLAuthToken.delete();
  storageSimpleSAML.delete();
  storageAlv.delete();
  storageUids.delete();
  storageBadge.delete();
  storageClient.delete();
  storageIne.delete();
  storageIdAdmin.delete();
  storageEdtUrl.delete();
  storageName.delete();
}

Map<int, Color> color = {
  50: Color.fromRGBO(136, 14, 79, .1),
  100: Color.fromRGBO(136, 14, 79, .2),
  200: Color.fromRGBO(136, 14, 79, .3),
  300: Color.fromRGBO(136, 14, 79, .4),
  400: Color.fromRGBO(136, 14, 79, .5),
  500: Color.fromRGBO(136, 14, 79, .6),
  600: Color.fromRGBO(136, 14, 79, .7),
  700: Color.fromRGBO(136, 14, 79, .8),
  800: Color.fromRGBO(136, 14, 79, .9),
  900: Color.fromRGBO(136, 14, 79, 1),
};

bool asXxMoy = false;

DevinciTheme currentTheme = DevinciTheme();

String crashConsent;
bool notifConsent;
bool showSidePanel = false;
bool analyticsConsent = true;
String feedbackNotes = '';
String feedbackError = '';
StackTrace feedbackStackTrace = StackTrace.fromString('');
String eventId = '';
bool isConnected = true;
var store = StoreRef<String, dynamic>.main();
Database db;

Student user;

final loginPageKey = GlobalKey<LoginPageState>();
final mainScaffoldKey = GlobalKey<ScaffoldState>();
