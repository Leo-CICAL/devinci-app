import 'package:devinci/extra/CommonWidgets.dart';
import 'package:devinci/pages/components/user.dart';
import 'package:devinci/pages/logic/user.dart';
import 'package:devinci/pages/timechef.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:matomo/matomo.dart';
import 'package:devinci/extra/globals.dart' as globals;
import 'package:easy_localization/easy_localization.dart';

class UserPage extends TraceableStatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    globals.isLoading.addListener(() => loaderListener());
    SchedulerBinding.instance.addPostFrameCallback((_) => runBeforeBuild());
  }

  @override
  Widget build(BuildContext context) {
    var padding = 0.0;
    if (MediaQuery.of(context).size.width > 1000) {
      padding = MediaQuery.of(context).size.width * 0.13;
    } else if (MediaQuery.of(context).size.width > 800) {
      padding = MediaQuery.of(context).size.width * 0.1;
    } else if (MediaQuery.of(context).size.width > 600) {
      padding = MediaQuery.of(context).size.width * 0.08;
    }
    if (show) {
      return CupertinoScrollbar(
        controller: scroll,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: ListView(
            controller: scroll,
            children: <Widget>[
              ExpansionTile(
                title: Text(
                  'private_info',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ).tr(),
                children: <Widget>[
                  InfoSection('id', globals.user.tokens['uids']),
                  InfoSection('#card', globals.user.data['badge']),
                  InfoSection('#client', globals.user.data['client']),
                  InfoSection('id_admin', globals.user.data['idAdmin']),
                  InfoSection('INE', globals.user.data['ine']),
                ],
                onExpansionChanged: (expanded) {
                  setState(() {
                    pad = expanded;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: (pad ? 20 : 0)),
                child: TimeChefPage(),
              ),
              TitleSection('documents',
                  padding: EdgeInsets.only(left: 16, top: 20)),
              Padding(
                padding: EdgeInsets.only(top: 12, left: 20, right: 20),
                child: DocumentTile(
                    'school_certificate',
                    globals.user.documents['certificat']['annee'],
                    globals.user.documents['certificat']['fr_url'],
                    globals.user.documents['certificat']['en_url'],
                    0),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                child: DocumentTile(
                    'imaginr_certificate',
                    globals.user.documents['imaginr']['annee'],
                    globals.user.documents['imaginr']['url'],
                    '',
                    1),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                child: DocumentTile(
                    'academic_calendar',
                    globals.user.documents['calendrier']['annee'],
                    globals.user.documents['calendrier']['url'],
                    '',
                    2),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: globals.user.documents['bulletins'].length,
                  itemBuilder: (BuildContext ctxt, int i) {
                    return Padding(
                      padding: EdgeInsets.only(top: 0, left: 20, right: 20),
                      child: DocumentTile(
                          globals.user.documents['bulletins'][i]['name'],
                          globals.user.documents['bulletins'][i]['sub'],
                          globals.user.documents['bulletins'][i]['fr_url'],
                          globals.user.documents['bulletins'][i]['en_url'],
                          3 + i),
                    );
                  }),
            ],
          ),
        ),
      );
    } else {
      return Center(child: CupertinoActivityIndicator());
    }
  }
}
