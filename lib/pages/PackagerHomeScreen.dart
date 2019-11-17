import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neutral_creep_dev/models/delivery.dart';
import 'package:neutral_creep_dev/pages/summaryPage.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../helpers/color_helper.dart';

import '../models/cart.dart';
import '../models/customer.dart';
import '../models/employee.dart';
import '../models/eWallet.dart';
import '../models/transaction.dart';

import '../services/authService.dart';
import '../services/dbService.dart';
import '../services/edbService.dart';

import './profilePage.dart';
import './eWalletPage.dart';
import './startPage.dart';
import './EmployeeDeliverySummary.dart';
import './EmployeeDeliveryList.dart';
import './EmployeeDeliveryHistory.dart';
import './EmployeeDeliveryItems.dart';
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
  QuerySnapshot addDoc;
  String result = "";
  Color bgColor = Colors.white;
  bool selected = false;
  bool ready = false;

  //
  _PackagerHomePageState({this.employee, this.auth, this.edb});

  final databaseReference = Firestore.instance;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  Future getData() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection('Packaging').getDocuments();
    return qn;
  }

  int _selectedIndex = -1; //change to -1
  bool _selected = false;

  _setCardColor(int index) {
    setState(() {
      _selectedIndex = index;
      _selected = true;
    });
  }

  Timer _timer;
  int _start = 2;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

//  void initState() {
//    time = Timer.periodic(Duration(milliseconds: 10), (Timer t) {
//      setState(() {
//        if(delivered==true)
//          icon = Icon(FontAwesomeIcons.checkCircle, color: harlequinGreen);
//        else
//          icon = Icon(FontAwesomeIcons.timesCircle, color: heidelbergRed);
//      });
//    });
//  }
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

  ProgressDialog showPR() {
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(
        message: 'Loading...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
  }

  final GlobalKey _menuKey = new GlobalKey();

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
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
              SizedBox(height: 30),
              InkWell(
                child: Text(
                  "Current Deliveries",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DeliveryListPage(
                            employee: employee,
                            auth: auth,
                            edb: edb,
                          )));
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
                  print(
                      "before going to deliveryhistory page = ${employee.id}");
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
              try {
                if (snapshot.hasData) {
                  print(
                      "check transactionId: ${snapshot.data.documents[0][transactionId]}");
                  if (snapshot.data.documents[0]['transactionId'] != null) {
                    transactionId = snapshot.data.documents[0]['transactionId'];
                    if (snapshot.data.documents[0]['transactionId'] == null) {
                      noOrdersDialog(context);
                    } else {
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
                      ready = true;
                    }
                  } else {
                    transactionId = "0000";
                  }
                }
              } catch (Exception) {
                print("no info");
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
                              RaisedButton(
                                color: harlequinGreen,
                                onPressed: () async {
                                  if (ready == true) {
                                    print(
                                        "Check out this ready true statement");
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
                                    startTimer();
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PackagerOrderPage(
                                                  employee: employee,
                                                  auth: auth,
                                                  edb: edb,
                                                  transactionId: transactionId,
                                                )));
                                  } else  {
                                    noOrdersDialog(context);
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
//              if (snapshot.hasData) {
//                String transactionId;
//                Map address;
//                String name;
//                double totalAmount;
//                DateTime date;
//                String customerId;
//                //List items;
//                List<dynamic> items = new List<dynamic>();
//                String collectType;
//                //if (snapshot.data.documents[0]['transactionId'] != null) {
//                 // transactionId = snapshot.data.documents[0]['transactionId'];
//                try {
//                  if (snapshot.data.documents[0]['transactionId'] == null) {
//                    print("here");
//                    noOrdersDialog(context);
//                  } else {
//                    name = snapshot.data.documents[0]['name'];
//                    address = Map.from(snapshot.data.documents[0]['address']);
//                    totalAmount = snapshot.data.documents[0]['totalAmount'];
//                    items = snapshot.data.documents[0]['items'];
//                    date = snapshot.data.documents[0]['dateOfTransaction']
//                        .toDate();
//                    totalAmount = double.parse(
//                        snapshot.data.documents[0]['totalAmount'].toString());
//                    customerId = snapshot.data.documents[0]['customerId'];
//                    collectType = snapshot.data.documents[0]['collectType'];
//                    ready = true;
//                  }
//                } catch (Exception) {
//                  print("no info");
//              }
//                //}
//                return Text("${snapshot.toString()}");
//              } else {
//                return Container(
//                  color: Colors.blue,
//                );
//              }
            }));
  }

  Grocery item1 = new Grocery(
      id: "1",
      name: "Red Ball-Point Pencil",
      description: "this is a pencil",
      supplier: "Kenyon's Pencils Pte",
      cost: 1.50,
      imageURL:
          "https://firebasestorage.googleapis.com/v0/b/neutral-creep-dev.appspot.com/o/apple.jpg?alt=media&token=43d25e60-a478-4e8d-9bcd-793aa918d84c");

  Grocery item2 = new Grocery(
      id: "2",
      name: "elifford The Big Red Cock",
      description: "this is a big red cock",
      supplier: "ZP YAOZ CLUB HOUSE",
      cost: 37.45);
  Grocery item3 = new Grocery(
      id: "3",
      name: "Fuji Apple (Small)",
      description: "this is an apple",
      supplier: "Matts Farm (Japan)",
      cost: 8.20);
  Grocery item4 = new Grocery(
      id: "4",
      name: "Square Watermalon",
      description: "this is a watermelon",
      supplier: "RayRay's Weird & Wonderful Garden",
      cost: 7.80);
  Grocery item5 = new Grocery(
      id: "5",
      name: "1-Ply Tissue Packet",
      description: "this is a tissue packet",
      supplier: "Mama Cheap Cheap ABC",
      cost: 0.50);

  Grocery item6 = new Grocery(
      id: "6",
      name: "Red Ball-Point Pencil",
      description: "this is a pencil",
      supplier: "Kenyon's Pencils Pte",
      cost: 1.50,
      imageURL:
          "https://firebasestorage.googleapis.com/v0/b/neutral-creep-dev.appspot.com/o/apple.jpg?alt=media&token=43d25e60-a478-4e8d-9bcd-793aa918d84c");

  Grocery item7 = new Grocery(
      id: "7",
      name: "elifford The Big Red Cock",
      description: "this is a big red cock",
      supplier: "ZP YAOZ CLUB HOUSE",
      cost: 37.45);
  Grocery item8 = new Grocery(
      id: "8",
      name: "Fuji Apple (Small)",
      description: "this is an apple",
      supplier: "Matts Farm (Japan)",
      cost: 8.20);
  Grocery item9 = new Grocery(
      id: "9",
      name: "Square Watermalon",
      description: "this is a watermelon",
      supplier: "RayRay's Weird & Wonderful Garden",
      cost: 7.80);
  Grocery item10 = new Grocery(
      id: "10",
      name: "1-Ply Tissue Packet",
      description: "this is a tissue packet",
      supplier: "Mama Cheap Cheap ABC",
      cost: 0.50);

//  var cartDb = [
//    item1,
//    item2,
//    item3,
//    item4,
//    item5,
//    item6,
//    item7,
//    item8,
//    item9,
//    item10
//  ];

//                        onPressed: () {
//    PurchaseTransaction transaction =
//    new PurchaseTransaction(
//    cart: employee.currentCart);
//
//    edb
//        .getTransactionId(employee.id)
//        .then((transactionId) {
//    transaction.setId(
//    transactionId.toString().padLeft(8, "0"));
////                            Navigator.of(context)
//////                                .push(MaterialPageRoute(
//////                                builder: (context) => SummaryPage(
//////                                  transaction: transaction,
//////                                  employee: employee,
//////                                  db: db,
//////                                )))
//////                                .then((value) {
//////                              print("$value");
//////                            });
//    });
//                        },
}
