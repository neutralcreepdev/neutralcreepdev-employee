import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neutral_creep_dev/models/delivery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../helpers/color_helper.dart';
import '../models/employee.dart';

import '../services/authService.dart';
import '../services/edbService.dart';

import './profilePage.dart';
import './startPage.dart';
import './EmployeeDeliveryList.dart';
import './EmployeeDeliveryHistory.dart';
import './EmployeeDeliveryItems.dart';

class MyHomePage extends StatefulWidget {
  final Employee employee;
  final AuthService auth;
  final EDBService edb;

  MyHomePage({this.employee, this.auth, this.edb});

  _HomePageState createState() =>
      _HomePageState(employee: employee, auth: auth, edb: edb);
}

class _HomePageState extends State<MyHomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Employee employee;
  final AuthService auth;
  final EDBService edb;
  QuerySnapshot addDoc;
  String result = "";
  Color bgColor = Colors.white;
  bool selected = false;

  _HomePageState({this.employee, this.auth, this.edb});

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
    QuerySnapshot qn = await firestore.collection('Delivery').getDocuments();
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

  addDeliveryDialog(BuildContext context, Order order) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Confirm"),
      onPressed: () async {
        await Firestore.instance
            .collection('Staff')
            .document(employee.id)
            .collection('Pending Deliveries')
            .document(order.orderID)
            .setData({
          'transactionId': order.orderID,
          'name': order.name,
          'address': order.address,
          'totalAmount': order.totalAmount,
          'items': order.items,
          'dateOfTransaction': order.date,
          'customerId': order.customerId,
          'timeArrival': order.timeArrival,
          'employeeId': employee.id,
        });

        await Firestore.instance
            .collection('users')
            .document(order.customerId)
            .collection("Delivery")
            .document(order.orderID)
            .updateData({'status': "Delivering"});

        //To add to addDeliveryDialog
        Firestore.instance
            .collection('Delivery')
            .document(order.orderID)
            .delete();

        Navigator.pop(context);

        Fluttertoast.showToast(
            msg: "Successfully added to Delivery List!", fontSize: 16.0);
        setState(() {});
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Add Delivery"),
      content: Text("Do you want to add this order to your delivery list?"),
      actions: [
        cancelButton,
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
                print( "MSG: employee: ${employee.id}");
                Navigator.of(context).pop();

                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfilePage(employee: employee, edb: edb)));
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
            Delivery _deliveryList = new Delivery();
            if (!snapshot.hasData)
              return Text('Loading...');
            else {
              if (snapshot.data.documents.length == 0) {
                return Center(
                  child: Text("Currently no delivery orders"),
                );
              } else {
                for (int i = 0; i < snapshot.data.documents.length; i++) {
                  String orderIDTemp =
                      snapshot.data.documents[i]['transactionId'];
                  Map addressTemp =
                      Map.from(snapshot.data.documents[i]['address']);
                  String nameTemp = snapshot.data.documents[i]['name'];
                  DateTime dateTemp =
                      snapshot.data.documents[i]['dateOfTransaction'].toDate();
                  List<dynamic> items = new List<dynamic>();
                  items = snapshot.data.documents[i]['items'];
                  double totalAmountTemp = double.parse(
                      snapshot.data.documents[i]['totalAmount'].toString());
                  String customerIDTemp =
                      snapshot.data.documents[i]['customerId'];
                  String collectTypeTemp =
                      snapshot.data.documents[i]['collectType'];
                  Map timeArrivalTemp =
                      snapshot.data.documents[i]['timeArrival'];
                  _deliveryList.addOrders(new Order(
                      orderID: orderIDTemp,
                      name: nameTemp,
                      address: addressTemp,
                      date: dateTemp,
                      customerId: customerIDTemp,
                      items: items,
                      collectType: collectTypeTemp,
                      timeArrival: timeArrivalTemp,
                      totalAmount: totalAmountTemp));
                }
              }

              final int deliverySize = snapshot.data.documents.length;
              return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: whiteSmoke,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: SmartRefresher(
                          enablePullDown: true,
                          child: ListView.builder(
                            itemCount: deliverySize,
                            itemBuilder: (context, index) => Card(
                                child: Container(
                                    color: _selectedIndex != null &&
                                            _selectedIndex == index
                                        ? Colors.red
                                        : Colors.white,
                                    child: ListTile(
                                        title: Text(_deliveryList
                                            .getOrders(index)
                                            .toString()),
                                        onTap: () => _setCardColor(index),
                                        onLongPress: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ItemsSummaryPage(
                                                          order: _deliveryList
                                                              .getOrders(
                                                                  index))));
                                        }))),
                          ),
                          controller: _refreshController,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 10),
                            ButtonTheme(
                              height: 60,
                              minWidth: 250,
                              child: Column(
                                children: <Widget>[
                                  RaisedButton(
                                    color: _selected != false
                                        ? heidelbergRed
                                        : Colors.white12,
                                    onPressed: () {
                                      if (_selected == true) {
                                        addDeliveryDialog(
                                            context,
                                            _deliveryList
                                                .getOrders(_selectedIndex));
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Please select an order");
                                      }
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(35)),
                                    child: Text(
                                      "ADD ORDER",
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30)
                    ],
                  ));
            }
          }),
    );
  }
}
