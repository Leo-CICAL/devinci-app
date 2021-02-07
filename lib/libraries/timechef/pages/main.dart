import 'package:devinci/extra/CommonWidgets.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
//import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool show = false;
  void runBeforeBuild() async {
    try {
      await globals.timeChefUser.getData();
      if (mounted) {
        setState(() {
          show = true;
        });
      }
      // ignore: empty_catches
    } catch (exception, stacktrace) {
      FLog.logThis(
          className: '_MainPageState TC',
          methodName: 'runBeforeBuild',
          text: 'exception',
          type: LogLevel.ERROR,
          exception: Exception(exception),
          stacktrace: stacktrace);
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  Widget build(BuildContext context) {
    if (show) {
      return TitleSection(
          'self_balance_arg'.trArgs([globals.timeChefUser.solde.toString()]),
          padding: EdgeInsets.only(left: 16));
    } else {
      return TitleSection('self_balance'.tr,
          iconButton: CupertinoActivityIndicator(),
          padding: EdgeInsets.only(left: 16));
    }
  }
}
