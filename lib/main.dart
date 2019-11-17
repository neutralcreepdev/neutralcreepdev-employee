import 'package:flutter/material.dart';
import './color_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(title: 'HOME'),

    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final europeanCountries = ['Albania', 'Belarus', 'Czech Republic', 'Denmark'];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final names = ['Kenyon', 'Ruiyang', 'Zhongpeng', 'Matthew'];
  final location = ['CCK', 'BukitBatok', 'Woodlands', 'JurongEast'];
  final unit = ['#01-23', '#02-34', '#03-45', '#04-56'];
  final postalCode = ['112233', '223344', '334455', '445566'];
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.qrcode),
          ),
        ],
      ),

      drawer: Drawer (
        child: ListView(
          padding: EdgeInsets.zero,
            children: <Widget>[
//              DrawerHeader(
//                decoration: BoxDecoration(
//                  color: Colors.white70,
//                ),
//                margin: EdgeInsets.all(0.0),
//                padding: EdgeInsets.all(0.0)
//              ),
            SizedBox (
            height: 20.0,
        ),
              ListTile(
                title: Text('PROFILE'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('HISTORY'),
                onTap: () {
                  // close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('LOGOUT'),
                onTap: () {
                  // close the drawer
                  Navigator.pop(context);
                },
              ),

              ],
        ),
        ),

        body: new ListView.builder(
          itemCount: europeanCountries.length,
            itemBuilder: (BuildContext ctxt, int index) {
            return ListTile(
                title: new Column(
                  children: <Widget>[
                    new Text('NAME: ' + europeanCountries[index]),
                    new Text('LOCATION: ' + location[index]),
                    new Text('UNIT: ' + unit[index]),
                    new Text ('POSTAL CODE: ' + postalCode[index]),
                  ],
                )
            );
            },
        ),

//          // backing data
//        final europeanCountries = ['Albania', 'Andorra', 'Armenia', 'Austria',
//        'Azerbaijan', 'Belarus', 'Belgium', 'Bosnia and Herzegovina', 'Bulgaria',
//        'Croatia', 'Cyprus', 'Czech Republic', 'Denmark', 'Estonia', 'Finland',
//        'France', 'Georgia', 'Germany', 'Greece', 'Hungary', 'Iceland', 'Ireland',
//        'Italy', 'Kazakhstan', 'Kosovo', 'Latvia', 'Liechtenstein', 'Lithuania',
//        'Luxembourg', 'Macedonia', 'Malta', 'Moldova', 'Monaco', 'Montenegro',
//        'Netherlands', 'Norway', 'Poland', 'Portugal', 'Romania', 'Russia',
//        'San Marino', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 'Sweden',
//        'Switzerland', 'Turkey', 'Ukraine', 'United Kingdom', 'Vatican City'];
//
//        return ListView.builder(
//        itemCount: europeanCountries.length,
//        itemBuilder: (context, index) {
//            return ListTile(
//            title: Text(europeanCountries[index]),
//            );
//            },
//            );

//      body: Center(
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text(
//              'You have pushed the button this many times:',
//            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.display1,
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
