import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:neutral_creep_dev/pages/paymentPage.dart';
import 'package:neutral_creep_dev/services/dbService.dart';
import 'package:neutral_creep_dev/services/edbService.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/transaction.dart';
import '../models/customer.dart';
import '../models/delivery.dart';
import '../models/employee.dart';

import '../helpers/color_helper.dart';

class EmployeeDeliveryPage extends StatefulWidget {
  final Order order;
  final EDBService edb;
  final Employee employee;

  EmployeeDeliveryPage({this.order, this.edb, this.employee});

  _EmployeeDeliveryPageState createState() =>
      _EmployeeDeliveryPageState(order: order, edb: edb, employee: employee);
}

class _EmployeeDeliveryPageState extends State<EmployeeDeliveryPage> {
  final Order order;
  final EDBService edb;
  final Employee employee;
  bool delivered = false;
  Timer time;
  Icon icon;

  _EmployeeDeliveryPageState({this.order, this.edb, this.employee});

  String hashData(order) {
    //Date minus 4
    String newDate =
        order.date.toString().substring(0, order.date.toString().length - 4);
    String data = order.orderID + newDate;
    print("order orderID: ${order.orderID}");
    print("order orderID: ${newDate}");
    print("order orderID: ${data}");
    var dataBytes = utf8.encode(data);
    var digest = sha256.convert(dataBytes);
    return digest.toString();
  }

  Future getData() async {
    var firestore = Firestore.instance;
    //Change to Pending delivery when confirmed for collection
    print("customer id heh = ${order.customerId}");
    QuerySnapshot qn = await firestore
        .collection('users')
        .document(order.customerId)
        .collection('History')
        .getDocuments();
    return qn;
  }

  void initState() {
    time = Timer.periodic(Duration(milliseconds: 10), (Timer t) {
      setState(() {
        if (delivered == true)
          icon = Icon(FontAwesomeIcons.checkCircle, color: harlequinGreen);
        else
          icon = Icon(FontAwesomeIcons.timesCircle, color: heidelbergRed);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: alablaster,
          iconTheme: IconThemeData(color: heidelbergRed, size: 30),
          centerTitle: true,
          title: Text(
            "Delivery Information",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 3),
          ),
          elevation: 0.2,
        ),
        body: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text('Loading...');
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                if (snapshot.data.documents[i]['transactionId'] ==
                    order.orderID) {
                  if (snapshot.data.documents[i]['status'] == "Delivered")
                    delivered = true;
                }
              }

              //print("status = ${snapshot.data[0]['status']}");
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: whiteSmoke,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'YOUR CODE: ',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    QrImage(
                        data: hashData(order),
                        //data: "123456789",
                        version: QrVersions.auto,
                        size: 200.0),
                    SizedBox(height: 30),
                    Text(
                      'PACKAGE DELIVERED:',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    IconButton(
//                icon: _arrivedIcon(status),
                        icon: icon,
                        iconSize: 100.0),
                    ButtonTheme(
                      height: 60,
                      minWidth: 250,
                      child: RaisedButton(
                        color:
                            delivered != false ? heidelbergRed : Colors.white12,
                        onPressed: () async {
                          //When pressed done:
                          //1. Archive the delivery order from customer's to history
                          //2. Archive the delivery order from employee's to history
                          //3. Pop out to list
                          if (delivered) {
                            await Firestore.instance
                                .collection('Staff')
                                .document(employee.id)
                                .collection('History')
                                .document(order.orderID)
                                .setData({
                              'transactionId': order.orderID,
                              'name': order.name,
                              'address': order.address,
                              'totalAmount': order.totalAmount,
                              'items': order.items,
                              'dateOfTransaction': order.date,
                              'customerId': order.customerId,
                              'status': 'Delivered'
                            });
                            print("check hashdata: ${hashData(order)}");
                            Navigator.pop(context);
                            Firestore.instance
                                .collection('Staff')
                            .document(employee.id)
                            .collection('Delivery')
                                .document(order.orderID)
                                .delete();

                            Fluttertoast.showToast(msg: "Delivery done!");
                          } else {
                            Fluttertoast.showToast(msg: "Delivery not done!");
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35)),
                        child: Text(
                          "DONE",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}
