import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neutral_creep_dev/models/delivery.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:progress_dialog/progress_dialog.dart';

import '../helpers/color_helper.dart';

import '../models/employee.dart';

import '../services/authService.dart';
import '../services/edbService.dart';

import './profilePage.dart';
import './startPage.dart';
import './EmployeeDeliveryList.dart';
import './EmployeeDeliveryHistory.dart';
import './PackagerHomeScreen.dart';

class PackagerOrderPage extends StatefulWidget {
  final Employee employee;
  final AuthService auth;
  final EDBService edb;

  PackagerOrderPage({this.employee, this.auth, this.edb});

  _PackagerOrderPageState createState() => _PackagerOrderPageState(
      employee: employee, auth: auth, edb: edb);
}

class _PackagerOrderPageState extends State<PackagerOrderPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Employee employee;
  final AuthService auth;
  final EDBService edb;
  QuerySnapshot addDoc;
  String result = "";
  Color bgColor = Colors.white;
  bool selected = false;
  bool ready = false;
  bool done = false;
  int initCount = 0;
  List<bool> itemsCheck;
  bool validation = false;
  bool lockerNum=false;
  TextEditingController lockerNo = new TextEditingController();

  _PackagerOrderPageState(
      {this.employee, this.auth, this.edb});

  final databaseReference = Firestore.instance;

  Future getData() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('Staff')
        .document(employee.id)
        .collection("Packaging")
        .getDocuments();
    return qn;
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

  bool allItemsPackaged(
      List<bool> itemsCheck, String collectType, bool lc) {
    bool temp = true;
    if(collectType=="Self-Collect") {
      for (int i = 0; i < itemsCheck.length; i++) {
        if (itemsCheck[i] == false) temp = false;
      }
      if (temp == true) {
        if (lc == false) temp = false;
      }
    } else {
      for (int i = 0; i < itemsCheck.length; i++) {
        if (itemsCheck[i] == false) temp = false;
      }
    }
    return temp;
  }

  bool lockerCheck(String lockerNum) {
    //Fluttertoast.showToast(msg: "LOCKERNUM: ${lockerNum}");
    bool temp = true;
    if (lockerNum.length==0 || lockerNum.isEmpty||lockerNum==""||lockerNum==null) temp = false;


    if (int.parse(lockerNum) > 100 || int.parse(lockerNum) < 1) {
      temp = false;
    }

    return temp;
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
            if (!snapshot.hasData) return Text('Loading...');
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
            Map timeArrival = snapshot.data.documents[0]['timeArrival'];
            Order order = new Order(
                orderID: orderIDTemp,
                name: nameTemp,
                address: addressTemp,
                date: dateTemp,
                customerId: customerIDTemp,
                items: items,
                timeArrival: timeArrival,
                totalAmount: totalAmountTemp);

            _deliveryList.addOrders(order);

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
                                      done = allItemsPackaged(itemsCheck, collectType, lockerNum);
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
                    child: Text("Locker No."),
                    visible: collectType == "Self-Collect" ? true : false,
                  ),
                  Visibility(
                    child: TextFormField(
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      controller: lockerNo,
                      onChanged: (text) {
                        if(text.isEmpty)
                          lockerNum=false;
                        done=allItemsPackaged(itemsCheck, collectType, lockerNum);
                        setState(() {
                        });
                      },
                      onFieldSubmitted: (term) {
                        lockerNum = lockerCheck(term);
                        done = allItemsPackaged(itemsCheck, collectType, lockerNum);
                        setState(() {});
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        hintText: "Input Locker Number",
                      ),
                    ),
                    visible: collectType == "Self-Collect" ? true : false,
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
                          if (done) {
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
                                'timeArrival': order.timeArrival,
                              });
                              //update data to employee
                              await Firestore.instance
                                  .collection('users')
                                  .document(order.customerId)
                                  .collection(collectType)
                                  .document(order.orderID)
                                  .updateData({'status': "Packaged"});
                            } else if (collectType == "Self-Collect") {
                              //Add Self-Collect collection
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

                              //Update status and lockerNum in users' orders
                              await Firestore.instance
                                  .collection('users')
                                  .document(order.customerId)
                                  .collection(collectType)
                                  .document(order.orderID)
                                  .updateData({
                                'status': "Self-Collect",
                                'lockerNum': lockerNo.text,
                              });
                            }
                            await Firestore.instance
                                .collection('Staff')
                                .document(employee.id)
                                .collection('Staff History')
                                .document(order.orderID)
                                .setData({
                              'transactionId': order.orderID,
                              'name': order.name,
                              'address': order.address,
                              'totalAmount': order.totalAmount,
                              'items': order.items,
                              'dateOfTransaction': order.date,
                              'customerId': order.customerId,
                              'employeeId': employee.id,
                            });
                            await Firestore.instance
                                .collection('Staff')
                                .document(employee.id)
                                .collection('Packaging')
                                .document(order.orderID)
                                .delete();

                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (context) => PackagerHomePage(
                                          employee: employee,
                                          auth: auth,
                                          edb: edb,
                                        )));
                          } else {
                            Fluttertoast.showToast(
                                msg: "Unable to complete packaging!");
                          }
                        }),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          }),
    );
  }
}
