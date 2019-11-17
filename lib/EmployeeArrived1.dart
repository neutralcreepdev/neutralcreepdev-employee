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
  bool _arrived=true;

  Icon _arrivedIcon(){
    Icon icon;
    if(_arrived) {
      icon = Icon(FontAwesomeIcons.checkCircle);
    } else {
      icon = Icon(FontAwesomeIcons.timesCircle);
    }
    return icon;
  }
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('YOUR CODE: '),
            IconButton(
              icon: Icon(FontAwesomeIcons.qrcode),
            ),
            Text('PACKAGE DELIVERED'),
            IconButton (
              icon: _arrivedIcon(),
            ),
            RaisedButton(
              onPressed: _incrementCounter,
              textColor: Colors.white,
              color: Colors.red,
              child: new Text("DONE"),
            ),
          ],
        ),
      ),
    );
  }
}
