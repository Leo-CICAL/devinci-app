import 'package:devinci/extra/classes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:matomo/matomo.dart';
import 'package:one_context/one_context.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class SallesPage extends TraceableStatefulWidget {
  final bool tablet;
  SallesPage({Key key, this.tablet}) : super(key: key);

  @override
  _SallesPageState createState() => _SallesPageState();
}

final SalleDataSource salleDataSource = SalleDataSource();

class _SallesPageState extends State<SallesPage> {
  bool show = false;

  void runBeforeBuild() async {
    await globals.user.getSallesLibres();
    if (mounted) {
      setState(() {
        show = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //populateData();
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  Widget getCellWidget(BuildContext context, GridColumn column, int rowIndex) {
    if (globals.user.sallesStr.contains(column.mappingName)) {
      try {
        final state = globals.user.salles[rowIndex]
            .occupation[globals.user.sallesStr.indexOf(column.mappingName)];
        return Container(
          color: state
              ? (CustomTheme.instanceOf(context).isDark()
                  ? Colors.deepOrangeAccent.shade400
                  : Colors.deepOrange)
              : Theme.of(context).scaffoldBackgroundColor,
        );
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  List<GridColumn> genColumns() {
    var res = <GridColumn>[];
    res.add(GridTextColumn(
        mappingName: 'salles',
        headerText: 'rooms'.tr(),
        cellStyle: DataGridCellStyle(textStyle: TextStyle(fontSize: 12)),
        padding: EdgeInsets.only(left: 6)));
    for (var elem in globals.user.sallesStr) {
      res.add(GridWidgetColumn(
          mappingName: elem,
          padding: EdgeInsets.only(left: 0, right: 0),
          width: 73.0));
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(
        CustomTheme.instanceOf(context).isDark());
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).scaffoldBackgroundColor);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(
        CustomTheme.instanceOf(context).isDark());
    if (widget.tablet != null) {
      return show
          ? SfDataGrid(
              source: salleDataSource,
              cellBuilder: getCellWidget,
              columns: genColumns(),
              frozenColumnsCount: 1,
              gridLinesVisibility: GridLinesVisibility.both,
            )
          : Center(
              child: CupertinoActivityIndicator(
              animating: true,
            ));
    } else {
      return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          brightness: MediaQuery.of(context).platformBrightness,
          centerTitle: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          title: Text(
            'free_room',
            style: Theme.of(context).textTheme.headline1,
          ).tr(),
          actions: <Widget>[
            IconButton(
              icon: IconTheme(
                data: Theme.of(context).accentIconTheme,
                child: Icon(Icons.close),
              ),
              onPressed: () async {
                OneContext().pop();
                //Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: show
            ? SfDataGrid(
                source: salleDataSource,
                cellBuilder: getCellWidget,
                columns: genColumns(),
                frozenColumnsCount: 1,
                gridLinesVisibility: GridLinesVisibility.both,
              )
            : Center(
                child: CupertinoActivityIndicator(
                animating: true,
              )),
      );
    }
  }
}

class SalleDataSource extends DataGridSource<Salle> {
  @override
  List<Salle> get dataSource => globals.user.salles;

  @override
  Object getValue(Salle salle, String columnName) {
    if (columnName == 'salles') {
      return salle.name;
    } else {
      return ' ';
    }
    // switch (columnName) {
    //   case 'salles':
    //     return salle.name;
    //     break;
    //   default:
    //     return ' ';
    //     break;
    // }
  }
}
