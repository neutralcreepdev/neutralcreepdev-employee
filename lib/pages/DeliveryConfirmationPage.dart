import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'dart:async';
import '../models/employee.dart';
import '../models/delivery.dart';

class DeliveryConfirmationPageWidget extends StatefulWidget {
  final Employee employee;
  final Order order;

  DeliveryConfirmationPageWidget({this.employee, this.order});

  @override
  _DeliveryConfirmationPageWidgetState createState() =>
      _DeliveryConfirmationPageWidgetState(employee: employee, order: order);
}

class _DeliveryConfirmationPageWidgetState
    extends State<DeliveryConfirmationPageWidget> {
  final Employee employee;
  final Order order;

  _DeliveryConfirmationPageWidgetState({this.employee, this.order});

  void onDeliveryComplete(BuildContext context) async {
    DateTime now = new DateTime.now();
    Map date;
    arrivedTime = {
      "date": date = {
        "day": now.day.toString(),
        "month": now.month.toString(),
        "year": now.year.toString(),
      },
      "time": now.toString().substring(11, 16),
    };

    if (delivered) {
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 3), () {
            });
            return Dialog(
                backgroundColor:
                Colors.transparent,
                child: SpinKitRotatingCircle(
                  color: Colors.white,
                  size: 50.0,
                ));
          });
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
        'expectedTime': order.timeArrival,
        'status': deliveryLate(arrivedTime['date'], order.timeArrival['date'],
                now.toString().substring(11, 16), order.timeArrival['time'])
            ? "Delivered (Late)"
            : "Delivered",
        'actualTime': arrivedTime,
      });
      await Firestore.instance
          .collection('Past Deliveries')
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
        'expectedTime': order.timeArrival,
        'status': deliveryLate(arrivedTime['date'], order.timeArrival['date'],
                now.toString().substring(11, 16), order.timeArrival['time'])
            ? "Delivered (Late)"
            : "Delivered",
        'actualTime': arrivedTime,
      });
      await new Future.delayed(const Duration(seconds: 2));
      await Firestore.instance
          .collection('users')
          .document(order.customerId)
          .collection("History")
          .document(order.orderID)
          .updateData({
        'status': deliveryLate(arrivedTime['date'], order.timeArrival['date'],
                now.toString().substring(11, 16), order.timeArrival['time'])
            ? "Delivered (Late)"
            : "Delivered",
        'actualTime': arrivedTime,
      });
      Navigator.popUntil(context, ModalRoute.withName('home'));
      Firestore.instance
          .collection('Staff')
          .document(employee.id)
          .collection('Pending Deliveries')
          .document(order.orderID)
          .delete();

      Fluttertoast.showToast(msg: "Delivery complete!");
    } else {
      Fluttertoast.showToast(msg: "Delivery not yet complete!");
    }
  }

  bool delivered = false;
  Timer time;
  Icon icon;
  Map arrivedTime;
  Map expectedTime;

  String hashData(Order order) {
    String newDate =
        order.date.toString().substring(0, order.date.toString().length);
    String data = order.orderID + newDate;
    var dataBytes = utf8.encode(data);
    var digest = sha256.convert(dataBytes);
    return digest.toString();
  }

  bool deliveryLate(
      Map arrivedDate, Map expectedDate, String arrived, String expected) {
    bool temp = true;
    DateTime arr = new DateTime(
        int.parse(arrivedDate['year']),
        int.parse(arrivedDate['month']),
        int.parse(arrivedDate['day']),
        int.parse(arrived.substring(0, 2)),
        int.parse(arrived.substring(3, 5)));
    DateTime exp = new DateTime(
        int.parse(expectedDate['year']),
        int.parse(expectedDate['month']),
        int.parse(expectedDate['day']),
        int.parse(expected.substring(0, 2)),
        int.parse(expected.substring(3, 5)));

    if (arr.isBefore(exp)) temp = false;

    return temp;
  }

  Future getData() async {
    var firestore = Firestore.instance;
    //Change to Pending delivery when confirmed for collection
    QuerySnapshot qn = await firestore
        .collection('users')
        .document(order.customerId)
        .collection('History')
        .getDocuments();
    return qn;
  }

  void initState() {

    time = Timer.periodic(Duration(milliseconds: 10), (Timer t) {
      if(mounted) {
        setState(() {
          if (delivered == true)
            icon = Icon(FontAwesomeIcons.checkCircle, color: Colors.green);
          else
            icon = Icon(FontAwesomeIcons.timesCircle, color: Colors.red);
        });
      } else {
        icon = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(

        child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              bool x = false;
              if (!snapshot.hasData) {
                x = true;
                if (x == true) {
                  return Dialog(
                      backgroundColor: Colors.transparent,
                      child: SpinKitRotatingCircle(
                        color: Colors.white,
                        size: 50.0,
                      ));
                }
                return null;
              }else {
                if(x==true) {
                  x=false;
                  Navigator.pop(context);
                }
                for (int i = 0; i < snapshot.data.documents.length; i++) {
                  if (snapshot.data.documents[i]['transactionId'] ==
                      order.orderID) {
                    if (snapshot.data.documents[i]['status'] == "Delivered") {
                      delivered = true;
                    }
                  }
                }
              }

              return Container(
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
//                            child: Icon(
//                              Icons.arrow_back,
//                              color: Colors.black,
//
//                            ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black),
                              onPressed:(){Navigator.popUntil(context, ModalRoute.withName('home'));}
                            ),
                          ),
                            decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                border: Border(
                                    bottom: BorderSide(
                                        width: 0.2,
                                        color:
                                            Theme.of(context).primaryColor))),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.075,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.9,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: EdgeInsets.only(top: 15, left: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Delivery\nConfirmation",
                                style: TextStyle(fontSize: 55),
                              ),
                              Text("Order ID: ${order.orderID}",
                                  style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 12,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: <Widget>[
                                QrImage(
                                    data: hashData(order),
                                    version: QrVersions.auto,
                                    size: 250.0),
                                Text("Scan To Confirm Delivery"),
                                SizedBox(
                                  height: 25,
                                ),
                                IconButton(
                                  icon: icon,
                                  iconSize:
                                      MediaQuery.of(context).size.width * 0.2,
                                )
                              ],
                            ),
                          ),
                        )),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Theme.of(context).canvasColor,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.07,
                            child: FlatButton(
                              color: delivered != false
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor,
                              onPressed: () => this.onDeliveryComplete(context),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              textColor: Colors.white,
                              padding: EdgeInsets.all(0),
                              child: Text(
                                "Delivery Confirmed",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: "Air Americana",
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }
}
