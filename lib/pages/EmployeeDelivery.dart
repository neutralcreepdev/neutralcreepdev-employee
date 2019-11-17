import 'package:flutter/material.dart';
import '../helpers/color_helper.dart';

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
      home: MyHomePage(title: 'DELIVERY'),
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  Text('ORDER#123456', style: TextStyle(
                      decoration: TextDecoration.underline, fontSize: 24.0),
                  ),
                  Text('NAME: ' + 'KENYON TAN'),
                  Text('CONTACT: ' + '98765432'),
                  Text('LOCATION: ' + 'NEW STREET 123'),
                  Text('UNIT: ' + '#01-234'),
                  Text('POSTAL CODE: ' + '112233'),
                ],
              ),
            ),
            Container(
              //alignment: FractionalOffset.bottomCenter,
                child: Column(
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.all(120.0),
                    ),
                    RaisedButton(
                      onPressed: _incrementCounter,
                      textColor: Colors.white,
                      color: heidelbergRed,
                      child: Text("VIEW MAP"),
                    ),
                    RaisedButton(
                      onPressed: _incrementCounter,
                      textColor: Colors.white,
                      color: heidelbergRed,
                      child: Text("ARRIVED"),
                    ),
                  ],
                )
            ),
//            Expanded(

//            ),
          ],
        ),
      ),
    );
  }
}
