import 'package:flutter/material.dart';
import 'base_table.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaseTableDemo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text('BaseTableDemo'),
            ),
            body: BaseTable(
              color: Color.fromARGB(255, 240, 240, 240),
              groupColor: Colors.white,
              groupMainMargin: 10.0,
              groupRadius: 10.0,
              groupCrossMargin: 10.0,
              autoSpread: true,
              sectionCount: 5,
              rowCount: (section) {
                return 3;
              },
              sectionHeader: (section) {
                return Container(
                  height: 50.0,
                  alignment: Alignment.center,
                  child: Text('这是第$section个section的header'),
                );
              },
              sectionFooter: (section) {
                return Container(
                  height: 50.0,
                  alignment: Alignment.center,
                  child: Text('这是第$section个section的footer'),
                );
              },
              header: () {
                return Container(
                  height: 100.0,
                  alignment: Alignment.center,
                  child: Text('这是header'),
                );
              },
              footer: () {
                return Container(
                  height: 100.0,
                  alignment: Alignment.center,
                  child: Text('这是footer'),
                );
              },
              sectionTypes: (section) {
                return section == 2 ? BaseTableSectionType.group : BaseTableSectionType.normal;
              },
              row: (indexPath) {
                return Container(
                  height: 50.0,
                  alignment: Alignment.center,
                  child: Text('这是第${indexPath.section}个section的第${indexPath.row}个row'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
