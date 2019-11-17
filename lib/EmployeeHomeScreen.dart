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
  //Sample Data
  String dropdownValue = 'LOCATION';
  int _counter = 0;
  final europeanCountries = ['Albania', 'Belarus', 'Czech Republic', 'Denmark'];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final names = ['Kenyon', 'Ruiyang', 'Zhongpeng', 'Matthew'];
  final location = ['CCK', 'BukitBatok', 'Woodlands', 'JurongEast'];
  final unit = ['#01-23', '#02-34', '#03-45', '#04-56'];
  final postalCode = ['112233', '223344', '334455', '445566'];

  //sample function. to be replaced with directing this home page to next
  //screen for 'START' DELIVERY
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
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
      body: Container(
        child: Stack(
          children: <Widget>[
            //  title text ====================================
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('FILTER: '),
                        DropdownButton(
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          items: <String>[
                            'LOCATION',
                            'UNIT',
                            'POSTAL CODE',
                            'ORDER'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  new Expanded(
                      child: ListView.builder(
                          itemCount: europeanCountries.length,
                          itemBuilder: (context, int index) {
                            return ListTile(
                                title: new Column(
                              children: <Widget>[
                                new Container(
                                  margin: const EdgeInsets.all(15.0),
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  child: new Column(
                                    children: <Widget>[
                                      Text("ORDER#123456"),
                                      Text('NAME: ' + europeanCountries[index]),
                                      Text('LOCATION: ' + location[index]),
                                      Text('UNIT: ' + unit[index]),
                                      Text('POSTAL CODE: ' + postalCode[index]),
                                      new RaisedButton(
                                        onPressed: _incrementCounter,
                                        textColor: Colors.white,
                                        color: Colors.red,
                                        child: new Text("START DELIVERY"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ));
                          }))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
