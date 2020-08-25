import 'package:devinci/extra/CommonWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter/scheduler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String tString = "Transactions";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void runBeforeBuild() async {
    try {
      await globals.timeChefUser.getTransactions();
      if (mounted) setState(() {});
    } catch (e) {}
  }

  void _onRefresh() async {
    globals.timeChefUser.fetched = false;
    globals.timeChefUser.tFetched = false;
    try {
      await globals.timeChefUser.getData();
      await globals.timeChefUser.getTransactions();
    } catch (e) {}
    globals.timeChefUser.fetched = true;
    globals.timeChefUser.tFetched = true;
    if (mounted) {
      setState(() {
        _refreshController.refreshCompleted();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  Widget build(BuildContext context) {
    int bigN = int.parse(globals.timeChefUser.solde.toString().split('.')[0]);
    int smallN = int.parse(globals.timeChefUser.solde.toString().split('.')[1]);
    return CupertinoScrollbar(
        child: SmartRefresher(
            enablePullDown: true,
            header: ClassicHeader(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 48,
                  ),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: bigN.toString(),
                              style: TextStyle(
                                  fontSize: 90,
                                  fontWeight: FontWeight.w400,
                                  color: globals.timeChefUser.solde < 5
                                      ? (globals.currentTheme.isDark()
                                          ? Colors.redAccent
                                          : Colors.red.shade700)
                                      : (globals.currentTheme.isDark()
                                          ? Colors.white
                                          : Colors.black))),
                          TextSpan(
                              text: '.' +
                                  (smallN < 10
                                      ? smallN.toString() + '0'
                                      : smallN.toString()),
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                  color: globals.timeChefUser.solde < 5
                                      ? (globals.currentTheme.isDark()
                                          ? Colors.redAccent
                                          : Colors.red.shade700)
                                      : (globals.currentTheme.isDark()
                                          ? Colors.white
                                          : Colors.black))),
                          TextSpan(
                              text: ' €',
                              style: TextStyle(
                                  fontSize: 90,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Roboto',
                                  color: globals.timeChefUser.solde < 5
                                      ? (globals.currentTheme.isDark()
                                          ? Colors.redAccent
                                          : Colors.red.shade700)
                                      : (globals.currentTheme.isDark()
                                          ? Color(0xFF9D9D9D)
                                          : Colors.black.withAlpha(90))))
                        ],
                      ),
                    ),
                  ),
                ),
                globals.timeChefUser.solde < 5
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('Solde insuffisant',
                            style: TextStyle(fontWeight: FontWeight.w300)))
                    : SizedBox.shrink(),
                TitleSection(tString),
                globals.timeChefUser.tFetched
                    ? Padding(
                        padding: const EdgeInsets.only(top: 68),
                        child: Center(
                          child: Text('Aucune transaction'),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 68),
                        child: Center(
                          child: CupertinoActivityIndicator(
                            animating: true,
                          ),
                        ))
              ],
            )));
  }
}
