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
import './PackagerHomeScreen.dart';

class PackagerOrderPage extends StatefulWidget {
  final Employee employee;
  final AuthService auth;
  final EDBService edb;
  String transactionId;

  PackagerOrderPage({this.employee, this.auth, this.edb, this.transactionId});

  _PackagerOrderPageState createState() => _PackagerOrderPageState(
      employee: employee, auth: auth, edb: edb, transactionId: transactionId);
}

class _PackagerOrderPageState extends State<PackagerOrderPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Employee employee;
  final AuthService auth;
  final EDBService edb;
  String transactionId;
  QuerySnapshot addDoc;
  String result = "";
  Color bgColor = Colors.white;
  bool selected = false;
  bool ready = false;
  bool done = false;
  int initCount = 0;
  List<bool> itemsCheck;
  TextEditingController lockerNo = new TextEditingController();

  //
  _PackagerOrderPageState(
      {this.employee, this.auth, this.edb, this.transactionId});

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
    QuerySnapshot qn = await firestore
        .collection('Staff')
        .document(employee.id)
        .collection("Packaging")
        .getDocuments();
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
        Fluttertoast.showToast(msg: "check woohoo: ${order.customerId}");
        await Firestore.instance
            .collection('Test Delivery')
            .document(order.orderID)
            .setData({
          'transactionId': order.orderID,
          'name': order.name,
          'address': order.address,
          'totalAmount': order.totalAmount,
          'items': order.items,
          'dateOfTransaction': order.date,
          'customerId': order.customerId,
        });

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

  bool allItemsPackaged(List<bool> itemsCheck) {
    bool temp = true;
    for (int i = 0; i < itemsCheck.length; i++) {
      if (itemsCheck[i] == false) temp = false;
    }
    if(temp) {
      if(lockerNo.text==null)
        temp=false;
      if(int.parse(lockerNo.text) > 100 || int.parse(lockerNo.text) < 0)
        temp=false;
    }

    return temp;
  }

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();

      setState(() {
        result = qrResult;
        Grocery temp = new Grocery();
        if (temp.setGroceryWithStringInput(result)) {
          temp.quantity = 1;
          employee.currentCart.addGrocery(temp);
        } else {
          print("\n\n\n\n unknown \n\n\n\n\n");
        }
        //employee.currentOrders.addOrders(order1);
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
          print("$result");
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
          print("$result");
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
        print("$result");
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
        print("$result");
      });
    }
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
                print("before going to deliveryhistory page = ${employee.id}");
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

            if (initCount == 0) {
              if (snapshot.data.documents[0]['items'] != null) {
                itemsCheck =
                    new List(snapshot.data.documents[0]['items'].length);
                for (int i = 0; i < itemsCheck.length; i++) {
                  itemsCheck[i] = false;
                }
                initCount++;
              }
            }
            print("employee.id = ${employee.id}");
            if (!snapshot.hasData) return Text('Loading...');
            //for (int i = 0; i < snapshot.data.documents.length; i++) {

            String orderIDTemp = snapshot.data.documents[0]['transactionId'];
            Map addressTemp = Map.from(snapshot.data.documents[0]['address']);
            String nameTemp = snapshot.data.documents[0]['name'];
            DateTime dateTemp =
                snapshot.data.documents[0]['dateOfTransaction'].toDate();
            List<dynamic> items = new List<dynamic>();
            items = snapshot.data.documents[0]['items'];
            double totalAmountTemp = double.parse(
                snapshot.data.documents[0]['totalAmount'].toString());
            String customerIDTemp = snapshot.data.documents[0]['customerId'];
            String collectType = snapshot.data.documents[0]['collectType'];
            Order order = new Order(
                orderID: orderIDTemp,
                name: nameTemp,
                address: addressTemp,
                date: dateTemp,
                customerId: customerIDTemp,
                items: items,
                totalAmount: totalAmountTemp);

            _deliveryList.addOrders(order);
            print(
                "check delivery list customerID = ${_deliveryList.getOrders(0).date}");
            // }
            print("check size = ${_deliveryList.getOrdersSize()}");
            print("items length = ${order.items.length}");

            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: whiteSmoke,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Text(
                    "Order #${order.orderID}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 10),
                      Container(
                          width: MediaQuery.of(context).size.width / 8,
                          child: Text("No.",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20))),
                      Container(
                        width: MediaQuery.of(context).size.width / 8 * 4 - 40,
                        child: Text("Item",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: MediaQuery.of(context).size.width / 8 + 10,
                        child: Text("Qty",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: MediaQuery.of(context).size.width - 10,
                    height: 1,
                    color: Colors.black,
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: order.items.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                    child: Text("${index + 1}",
                                        style: TextStyle(fontSize: 18))),
                                Container(
                                  width: MediaQuery.of(context).size.width /
                                          8 *
                                          4 -
                                      30,
                                  child: Text("${order.items[index]['name']}",
                                      style: TextStyle(fontSize: 18)),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  width: MediaQuery.of(context).size.width / 8 +
                                      10,
                                  child: Text(
                                      "${order.items[index]['quantity']}",
                                      style: TextStyle(fontSize: 18)),
                                ),
                                SizedBox(width: 10),
                                //Checkbox to be added.
                                Checkbox(
                                  value: itemsCheck[index],
                                  onChanged: (bool value) {
                                    setState(() {
                                      itemsCheck[index] = value;
                                      for (int i = 0;
                                          i < itemsCheck.length;
                                          i++) {
                                        print(
                                            "checkbox tick? ${i + 1} : ${itemsCheck[i]}");
                                      }
                                      done = allItemsPackaged(itemsCheck);
                                      print("CHECK DONE: ${done}");
                                      //itemsCheck[index] = value;
                                    });
                                  },
                                ),

                                SizedBox(width: 10),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 30),

                  Visibility(
                    child:Text("Locker No."),
                    visible: collectType=="Self-Collect" ? true : false,
                  ),
                  Visibility(
                    child: TextFormField(
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      controller: lockerNo,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        hintText: "Input Locker Number",
                      ),
                    ),
                    visible: collectType=="Self-Collect" ? true : false,
                  ),

                  SizedBox(height: 30),
                  ButtonTheme(
                    height: 60,
                    minWidth: 250,
                    child: RaisedButton(
                        color: done == true ? heidelbergRed : Colors.white12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35)),
                        child: Text(
                          "DONE",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        onPressed: () async {
//                          if(done) {
//                             //pop back, staff->uid->history
//                            //set locker no.
//                            //done must include that there is a valid locker number.
//                          } else {
//                            Fluttertoast.showToast(msg: "Please check all the items!")
//                          }
                          if (collectType == "Delivery") {
                            await Firestore.instance
                                .collection('Delivery')
                                .document(order.orderID)
                                .setData({
                              'transactionId': order.orderID,
                              'name': order.name,
                              'address': order.address,
                              'totalAmount': order.totalAmount,
                              'items': order.items,
                              'dateOfTransaction': order.date,
                              'customerId': order.customerId,
                            });
                            //update data to employee
                            await Firestore.instance
                                .collection('users')
                                .document(order.customerId)
                                .collection(collectType)
                                .document(transactionId)
                                .updateData({'status': "Packaged"});

                          } else if (collectType == "Self-Collect") {
                            await Firestore.instance
                                .collection('Self-Collect')
                                .document(order.orderID)
                                .setData({
                              'transactionId': order.orderID,
                              'name': order.name,
                              'address': order.address,
                              'totalAmount': order.totalAmount,
                              'items': order.items,
                              'dateOfTransaction': order.date,
                              'customerId': order.customerId,
                            });
                            await Firestore.instance
                                .collection('users')
                                .document(order.customerId)
                                .collection(collectType)
                                .document(transactionId)
                                .updateData({'status': "Self-Collect"});
                          }
                          await Firestore.instance.collection('Staff').document(employee.id).collection('History').document(transactionId).setData(
                              {
                                'transactionId': order.orderID,
                                'name': order.name,
                                'address': order.address,
                                'totalAmount': order.totalAmount,
                                'items': order.items,
                                'dateOfTransaction': order.date,
                                'customerId': order.customerId,
                              });
                          await Firestore.instance.collection('Staff').document(employee.id).collection('Packaging').document(transactionId).delete();

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) =>
                                  PackagerHomePage(
                                    employee: employee,
                                    auth: auth,
                                    edb: edb,)));
                        }),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          }),
    );
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
