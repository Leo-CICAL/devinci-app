import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matomo/matomo.dart';

class ChangelogPage extends TraceableStatefulWidget {
  ChangelogPage({Key key}) : super(key: key);

  @override
  ChangelogPageState createState() => ChangelogPageState();
}

class ChangelogPageState extends State<ChangelogPage> {
  @override
  void initState() {
    super.initState();

    //SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
