import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:neutral_creep_dev/pages/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import '../models/employee.dart';
import '../services/edbService.dart';
import './Packer_PackingPage.dart';
import '../models/delivery.dart';

class PackerMainPageWidget extends StatefulWidget {
  final Employee employee;
  final EDBService edb;

  PackerMainPageWidget({this.employee, this.edb});

  @override
  _PackerMainPageWidgetState createState() =>
      _PackerMainPageWidgetState(employee: employee, edb: edb);
}

class _PackerMainPageWidgetState extends State<PackerMainPageWidget> {
  final Employee employee;
  final EDBService edb;

  _PackerMainPageWidgetState({this.employee, this.edb});

  bool ready = false;
  bool packaged = false;

  Future<int> checkPackaging() async {
    var snap = await Firestore.instance
        .collection('Staff')
        .document(employee.id)
        .collection('Packaging')
        .getDocuments();
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

  void logOutButtonPressed(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPageWidget()));
  }

  void readyButtonPressed(BuildContext context, bool ready, Order order) async {
    setState(() {});
    if (packaged == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PackerPackingPageWidget(
                employee: employee,
                edb: edb,
              )));
    } else {
      if (ready == true) {
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 3), () {});
              return Dialog(
                  backgroundColor: Colors.transparent,
                  child: SpinKitRotatingCircle(
                    color: Colors.white,
                    size: 50.0,
                  ));
            });
        await Firestore.instance
            .collection('Staff')
            .document(employee.id)
            .collection("Packaging")
            .document(order.orderID)
            .setData({
          'transactionId': order.orderID,
          'name': order.name,
          'address': order.address,
          'totalAmount': order.totalAmount,
          'items': order.items,
          'dateOfTransaction': order.date,
          'customerId': order.customerId,
          'collectType': order.collectType,
          'timeArrival': order.timeArrival,
        });
        await Firestore.instance
            .collection('Packaging')
            .document(order.orderID)
            .delete();

        // update data in users->uid->transactionId->status
        await Firestore.instance
            .collection('users')
            .document(order.customerId)
            .collection(order.collectType)
            .document(order.orderID)
            .updateData({'status': "Packaging"});
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => PackerPackingPageWidget(
                  employee: employee,
                  edb: edb,
                )));
      } else {
        noOrdersDialog(context);
      }
    }
  }

  void showMoreInfo(BuildContext context, Order order) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return MyDialog(order: order);
        });
  }

  Future getHistory() async {
    var firestore = Firestore.instance;
    //Change to Pending delivery when confirmed for collection
    QuerySnapshot qn = await firestore
        .collection('Staff')
        .document(employee.id)
        .collection('Staff History')
        .getDocuments();
    return qn;
  }

  Future getPackaging() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection('Packaging').getDocuments();
    return qn;
  }

  Map quoteOfTheDay() {
    Map quoteMap = new Map();
    int modDate = 0;
    try {
      String dateStr = DateTime.now().toString().substring(8, 10);
      int date = int.parse(dateStr);
      modDate = date % 7;
      switch (modDate) {
        case 0:
         quoteMap =  {
           'quote':
           "The strength of the team is each individual member. The strength of each member is the team.",
           "author": "Phil Jackson",
         };
          break;
        case 1:
          quoteMap =  {
            'quote':
            "Unity is strength. . . when there is teamwork and collaboration, wonderful things can be achieved.",
            "author": "Mattie Stepanek",
          };
          break;
        case 2:
          quoteMap =  {
            'quote':
            "The best teamwork comes from men who are working independently toward one goal in unison.",
            "author": "James Cash Penney",
          };
          break;

        case 3:
          quoteMap =  {
            'quote':
            "Alone we can do so little, together we can do so much.",
            "author": "Helen Keller",
          };
          break;
        case 4: quoteMap = {
          'quote':
          "Individual commitment to a group effort--that is what makes a team work, a company work, a society work, a civilization work.",
          "author": "Vince Lombardi",
        };
        break;
        case 5: quoteMap = {
'quote' : "Collaboration allows teachers to capture each other's fund of collective intelligence",
          'author': "Mike Schmoker"
        };
        break;
        case 6: quoteMap= {
'quote': "Coming together is a beginning. Keeping together is progress. Working together is success.",
          'author': "Henry Ford"
        };
        break;
        default: break;
      }
    } catch (Exception) {
      quoteMap = {"quote": "", "author": ""};
    }
    return quoteMap;
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.2,
                                    color: Theme.of(context).primaryColor))),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.075,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${employee.lastName} ${employee.firstName}",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  "${employee.role}",
                                  style: TextStyle(fontSize: 15),
                                )
                              ],
                            ),
                          ),
                        ),
                        Spacer(flex: 6),
                        Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                this.logOutButtonPressed(context);
                                setState(() {});
                              },
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Log Out",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: <Widget>[
                                Text("Quote of the day",
                                    style: TextStyle(fontSize: 15)),
                                SizedBox(height: 15),
                                Container(
                                    width: 270,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          quoteOfTheDay()['quote'],
                                          style: TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 5),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            "- ${quoteOfTheDay()['author']}",
                                            style: TextStyle(fontSize: 14),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                color: Theme.of(context).canvasColor,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.10,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: FutureBuilder(
                                      future: getPackaging(),
                                      builder: (context, snapshot) {
                                        String transactionId;
                                        Map address;
                                        String name;
                                        double totalAmount;
                                        DateTime date;
                                        String customerId;
                                        List<dynamic> items =
                                            new List<dynamic>();
                                        String collectType;
                                        Map timeArrival;
                                        Order getNewOrder;
                                        try {
                                          checkPackaging().then((value) {
                                            if (value > 0) {
                                              packaged = true;
                                            }
                                          });
                                          if (packaged == false) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data.documents[0]
                                                      ['transactionId'] !=
                                                  null) {
                                                transactionId =
                                                    snapshot.data.documents[0]
                                                        ['transactionId'];
                                                name = snapshot
                                                    .data.documents[0]['name'];
                                                address = Map.from(snapshot.data
                                                    .documents[0]['address']);
                                                totalAmount =
                                                    snapshot.data.documents[0]
                                                        ['totalAmount'];
                                                items = snapshot
                                                    .data.documents[0]['items'];
                                                date = snapshot
                                                    .data
                                                    .documents[0]
                                                        ['dateOfTransaction']
                                                    .toDate();
                                                totalAmount = double.parse(
                                                    snapshot
                                                        .data
                                                        .documents[0]
                                                            ['totalAmount']
                                                        .toString());
                                                customerId = snapshot.data
                                                    .documents[0]['customerId'];
                                                collectType =
                                                    snapshot.data.documents[0]
                                                        ['collectType'];
                                                timeArrival =
                                                    snapshot.data.documents[0]
                                                        ['timeArrival'];
                                                getNewOrder = new Order(
                                                    orderID: transactionId,
                                                    name: name,
                                                    address: address,
                                                    date: date,
                                                    customerId: customerId,
                                                    items: items,
                                                    collectType: collectType,
                                                    timeArrival: timeArrival,
                                                    totalAmount: totalAmount);
                                                ready = true;
                                              }
                                            } else {
                                              return Text("Loading...");
                                            }
                                          }
                                        } catch (Exception) {
                                          print(
                                              "Got existing order or currently no order.");
                                        }
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          child: FlatButton(
                                            color:
                                                Theme.of(context).primaryColor,
                                            onPressed: () {
                                              this.readyButtonPressed(
                                                  context, ready, getNewOrder);
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            textColor: Colors.white,
                                            padding: EdgeInsets.all(0),
                                            child: Text(
                                              "Ready to start packing",
                                              style: TextStyle(
                                                fontSize: 30,
                                                fontFamily: "Air Americana",
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      }),
                                )),
                          ),
                          Expanded(
                            flex: 7,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: EdgeInsets.all(30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "History",
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          letterSpacing: 3,
                                          fontFamily: "Air Americana",
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: FutureBuilder(
                                          future: getHistory(),
                                          builder: (context, snapshot) {
                                            Delivery _deliveryList =
                                                new Delivery();
                                            if (!snapshot.hasData)
                                              return Text('Loading...');
                                            else {
                                              if (snapshot
                                                      .data.documents.length ==
                                                  0) {
                                                return Center(
                                                  child: Text(
                                                      "Delivery history is empty"),
                                                );
                                              } else {
                                                for (int i = 0;
                                                    i <
                                                        snapshot.data.documents
                                                            .length;
                                                    i++) {
                                                  String orderIDTemp =
                                                      snapshot.data.documents[i]
                                                          ['transactionId'];
                                                  Map addressTemp = Map.from(
                                                      snapshot.data.documents[i]
                                                          ['address']);
                                                  String nameTemp = snapshot
                                                      .data
                                                      .documents[i]['name'];
                                                  DateTime dateTemp = snapshot
                                                      .data
                                                      .documents[i]
                                                          ['dateOfTransaction']
                                                      .toDate();
                                                  List<dynamic> items =
                                                      new List<dynamic>();
                                                  items = snapshot.data
                                                      .documents[i]['items'];
                                                  double totalAmountTemp =
                                                      double.parse(snapshot
                                                          .data
                                                          .documents[i]
                                                              ['totalAmount']
                                                          .toString());
                                                  String customerIDTemp =
                                                      snapshot.data.documents[i]
                                                          ['customerId'];
                                                  String collectTypeTemp =
                                                      snapshot.data.documents[i]
                                                          ['collectType'];
                                                  Map timeArrivalTemp =
                                                      snapshot.data.documents[i]
                                                          ['timeArrival'];
                                                  _deliveryList.addOrders(
                                                      new Order(
                                                          orderID: orderIDTemp,
                                                          name: nameTemp,
                                                          address: addressTemp,
                                                          date: dateTemp,
                                                          customerId:
                                                              customerIDTemp,
                                                          items: items,
                                                          collectType:
                                                              collectTypeTemp,
                                                          timeArrival:
                                                              timeArrivalTemp,
                                                          totalAmount:
                                                              totalAmountTemp));
                                                }
                                              }
                                              return Container(
                                                child: ListView.builder(
                                                  itemCount: _deliveryList
                                                      .getOrdersSize(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Column(
                                                      children: <Widget>[
                                                        GestureDetector(
                                                          onTap: () {
                                                            this.showMoreInfo(
                                                                context,
                                                                _deliveryList
                                                                    .getOrders(
                                                                        index));
                                                          },
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.97,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.1,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Align(
                                                              child: Container(
                                                                  width: MediaQuery.of(context)
                                                                          .size
                                                                          .width *
                                                                      0.965,
                                                                  height: MediaQuery.of(context)
                                                                          .size
                                                                          .height *
                                                                      0.098,
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(context)
                                                                          .backgroundColor,
                                                                      borderRadius: BorderRadius.circular(
                                                                          5),
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color: Theme.of(context)
                                                                              .cardColor)),
                                                                  child: Center(
                                                                      child: Text(_deliveryList.getOrders(index).toString()))),
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                            ),
                                                          ),
                                                        ),
                                                        index + 1 !=
                                                                _deliveryList
                                                                    .getOrdersSize()
                                                            ? Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                height: 15)
                                                            : Container(),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          }),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                Expanded(
                  flex: 1,
                  child: Container(color: Theme.of(context).canvasColor),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyDialog extends StatefulWidget {
  final Order order;

  MyDialog({this.order});

  @override
  _MyDialogState createState() => new _MyDialogState(order: order);
}

class _MyDialogState extends State<MyDialog> {
  final Order order;

  _MyDialogState({this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      child: Icon(Icons.clear),
                    ),
                  )),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.075,
                  0,
                  0,
                  MediaQuery.of(context).size.width * 0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.08,
                width: MediaQuery.of(context).size.width,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "OrderID: ${order.orderID}",
                          style: TextStyle(fontSize: 40),
                        ),
                      ],
                    )),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: SizedBox(width: 10)),
                      Expanded(
                        flex: 2,
                        child: Container(
                            width: MediaQuery.of(context).size.width / 8,
                            child: Text("No.", style: TextStyle(fontSize: 20))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 8 * 4 - 40,
                          child: Text("Item", style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Expanded(flex: 4, child: SizedBox(width: 10)),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 8 + 10,
                          child: Text("Qty", style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(
                    height: MediaQuery.of(context).size.width * 0.02,
                    color: Theme.of(context).accentColor,
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: order.items.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Flexible(
                                fit: FlexFit.loose,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(child: SizedBox(width: 10)),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              8,
                                          child: Text("${index + 1}",
                                              style: TextStyle(fontSize: 18))),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    8 *
                                                    4 -
                                                30,
                                        child: Text(
                                            "${order.items[index]['name']}",
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 4, child: SizedBox(width: 10)),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    8 +
                                                10,
                                        child: Text(
                                            "${order.items[index]['quantity']}",
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                  fit: FlexFit.loose,
                                  child: SizedBox(height: 10)),
                              index + 1 != order.items.length
                                  ? Container(
                                      width: MediaQuery.of(context).size.width -
                                          30,
                                      height: 1)
                                  : Container(),
                              SizedBox(height: 10)
                            ],
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
