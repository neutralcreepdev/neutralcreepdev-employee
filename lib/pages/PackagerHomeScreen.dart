import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

import '../helpers/color_helper.dart';
import '../models/employee.dart';

import '../services/authService.dart';
import '../services/edbService.dart';

import './profilePage.dart';
import './startPage.dart';
import './EmployeeDeliveryHistory.dart';
import './PackagerOrderScreen.dart';

class PackagerHomePage extends StatefulWidget {
  final Employee employee;
  final AuthService auth;
  final EDBService edb;

  PackagerHomePage({this.employee, this.auth, this.edb});

  _PackagerHomePageState createState() =>
      _PackagerHomePageState(employee: employee, auth: auth, edb: edb);
}

class _PackagerHomePageState extends State<PackagerHomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Employee employee;
  final AuthService auth;
  final EDBService edb;
  bool ready = false;
  bool packaged=false;

  _PackagerHomePageState({this.employee, this.auth, this.edb});

  final databaseReference = Firestore.instance;

  Future getData() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection('Packaging').getDocuments();
    return qn;
  }

  Future<int> checkPackaging() async {
    var snap = await Firestore.instance.collection('Staff').document(employee.id).collection('Packaging').getDocuments();
    return snap.documents.length;
  }

  noOrdersDialog(BuildContext context) {
    // set up the buttons
    Widget continueButton = FlatButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("NO ORDERS"),
      content: Text("Currently there is no orders to be packaged."),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // AppBar =================================================
        appBar: AppBar(
          backgroundColor: alablaster,
          centerTitle: true,
          title: Text(
            "Home",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
                letterSpacing: 3),
          ),
          elevation: 0.2,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: heidelbergRed,
              size: 40,
            ),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                FontAwesomeIcons.sync,
                size: 30,
                color: heidelbergRed,
              ),
              onPressed: () {
                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                  duration: new Duration(seconds: 1),
                  content: new Row(
                    children: <Widget>[
                      new CircularProgressIndicator(),
                      new Text(" Refreshing...")
                    ],
                  ),
                ));
                setState(() {});
              },
            ),
            SizedBox(width: 20),
          ],
        ),

        // Drawer =================================================
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              SizedBox(height: 30),
              InkWell(
                child: Text(
                  "Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfilePage(employee: employee, edb: edb)));
                },
              ),
              SizedBox(height: 30),
              InkWell(
                child: Text(
                  "History",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DeliveryHistoryPage(
                            employee: employee,
                            auth: auth,
                            edb: edb,
                          )));
                },
              ),
              SizedBox(height: 30),
              InkWell(
                child: Text(
                  "Logout",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => StartPage()));
                },
              ),
            ],
          ),
        ),

        // Body =================================================
        body: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              String transactionId;
              Map address;
              String name;
              double totalAmount;
              DateTime date;
              String customerId;
              //List items;
              List<dynamic> items = new List<dynamic>();
              String collectType;
              Map timeArrival;
              try {
                  checkPackaging().then((value) {
                    if (value > 0) {
                      packaged = true;
                    }
                  });
                if (packaged==false) {
                  if (snapshot.hasData) {
                    if (snapshot.data.documents[0]['transactionId'] != null) {
                      transactionId =
                      snapshot.data.documents[0]['transactionId'];
                      name = snapshot.data.documents[0]['name'];
                      address = Map.from(snapshot.data.documents[0]['address']);
                      totalAmount = snapshot.data.documents[0]['totalAmount'];
                      items = snapshot.data.documents[0]['items'];
                      date = snapshot.data.documents[0]['dateOfTransaction']
                          .toDate();
                      totalAmount = double.parse(
                          snapshot.data.documents[0]['totalAmount'].toString());
                      customerId = snapshot.data.documents[0]['customerId'];
                      collectType = snapshot.data.documents[0]['collectType'];
                      timeArrival = snapshot.data.documents[0]['timeArrival'];
                      ready = true;
                    }
                  } else  {
                    return Text("Loading");
                  }
                }
              } catch (Exception) {
                print("No Orders");
              }
              return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: whiteSmoke,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ButtonTheme(
                          height: 60,
                          minWidth: 250,
                          child: Column(
                            children: <Widget>[
                              Text("PRESS READY TO START PACKAGING"),
                              RaisedButton(
                                color: harlequinGreen,
                                onPressed: () async {
                                  if(packaged == true) {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PackagerOrderPage(
                                                  employee: employee,
                                                  auth: auth,
                                                  edb: edb,
                                                  transactionId: transactionId,
                                                )));
                                  } else {
                                    if (ready == true) {
                                      await Firestore.instance
                                          .collection('Staff')
                                          .document(employee.id)
                                          .collection("Packaging")
                                          .document(transactionId)
                                          .setData({
                                        'transactionId': transactionId,
                                        'name': name,
                                        'address': address,
                                        'totalAmount': totalAmount,
                                        'items': items,
                                        'dateOfTransaction': date,
                                        'customerId': customerId,
                                        'collectType': collectType,
                                        'timeArrival': timeArrival,
                                      });
                                      await Firestore.instance
                                          .collection('Packaging')
                                          .document(transactionId)
                                          .delete();

                                      // update data in users->uid->transactionId->status
                                      await Firestore.instance
                                          .collection('users')
                                          .document(customerId)
                                          .collection(collectType)
                                          .document(transactionId)
                                          .updateData({'status': "Packaging"});
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PackagerOrderPage(
                                                    employee: employee,
                                                    auth: auth,
                                                    edb: edb,
                                                    transactionId: transactionId,
                                                  )));
                                    } else {
                                      noOrdersDialog(context);
                                    }
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35)),
                                child: Text("READY",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ],
                          )),
                    ],
                  ));
            }));
  }
}
