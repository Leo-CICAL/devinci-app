import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key key}) : super(key: key);

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  void runBeforeBuild() async {}

  var adminPagesIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
