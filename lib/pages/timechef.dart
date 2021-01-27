import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/libraries/timechef/pages/login.dart';
import 'package:devinci/libraries/timechef/pages/main.dart';
import 'package:devinci/libraries/timechef/timechef.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:matomo/matomo.dart';

class TimeChefPage extends TraceableStatefulWidget {
  TimeChefPage({Key key}) : super(key: key);

  @override
  _TimeChefPageState createState() => _TimeChefPageState();
}

class _TimeChefPageState extends State<TimeChefPage> {
  bool show = false;

  void runBeforeBuild() async {
    if (globals.timeChefUser == null || !globals.timeChefUser.fetched) {
      var username = await globals.storage.read(key: 'timechefusername');
      var password = await globals.storage.read(key: 'timechefpassword');
      if (username != null && password != null) {
        globals.timeChefUser = TimeChefUser(username, password);
        try {
          await globals.timeChefUser.init();
          globals.timeChefUser.fetched = true;
          globals.pageChanger.setPage(1);
          if (mounted) {
            setState(() {
              show = true;
            });
          }
        } catch (exception) {
          globals.pageChanger.setPage(0);
          if (mounted) {
            setState(() {
              show = true;
            });
          }
        }
      } else {
        globals.pageChanger.setPage(0);
        if (mounted) {
          setState(() {
            show = true;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          globals.pageChanger.setPage(1);
          show = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    globals.pageChanger.addListener(() {
      if (mounted) setState(() {});
    });
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  Widget build(BuildContext context) {
    return show
        ? [
            LoginPage(),
            MainPage(),
          ][globals.pageChanger.page()]
        : TitleSection('self_balance',
            iconButton: CupertinoActivityIndicator(),
            padding: EdgeInsets.only(left: 16));
  }
}
