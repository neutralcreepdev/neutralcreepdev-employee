import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:neutral_creep_dev/services/edbService.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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

  Map arrivedTime;
  Map expectedTime;

  String hashData(order) {
    String newDate =
        order.date.toString().substring(0, order.date.toString().length);
    String data = order.orderID + newDate;
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

  bool deliveryLate(Map arrivedDate, Map expectedDate, String arrived, String expected) {
    bool temp=true;
      DateTime arr = new DateTime(int.parse(arrivedDate['year']), int.parse(arrivedDate['month']), int.parse(arrivedDate['day']), int.parse(arrived.substring(0,2)), int.parse(arrived.substring(3, 5)));
      DateTime exp = new DateTime(int.parse(expectedDate['year']), int.parse(expectedDate['month']), int.parse(expectedDate['day']), int.parse(expected.substring(0,2)), int.parse(expected.substring(3, 5)));

      if(arr.isBefore(exp))
        temp=false;


    return temp;
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
                  if (snapshot.data.documents[i]['status'] == "Delivered") {
                    delivered = true;
                  }
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
                          DateTime now = new DateTime.now();
                          Map date;
                          arrivedTime ={
                            "date": date ={
                              "day": now.day.toString(),
                              "month": now.month.toString(),
                              "year": now.year.toString(),
                            },
                            "time": now.toString().substring(11,16),
                          };

//                          if(deliveryLate(arrivedTime['date'], order.timeArrival['date'], now.toString().substring(11,16), order.timeArrival['time'])){
//                            //Fluttertoast.showToast(msg: "${arrivedTime['date']}");
//                            Fluttertoast.showToast(msg: "${order.timeArrival['time']}");
//                          } else {
//                            Fluttertoast.showToast(msg: "FALSE");
//                          }
                          if (delivered) {
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
                              'status': deliveryLate(arrivedTime['date'], order.timeArrival['date'], now.toString().substring(11,16), order.timeArrival['time'])?"Delivered (Late)":"Delivered",
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
                              'status': deliveryLate(arrivedTime['date'], order.timeArrival['date'], now.toString().substring(11,16), order.timeArrival['time'])?"Delivered (Late)":"Delivered",
                              'actualTime': arrivedTime,
                            });
                            await new Future.delayed(const Duration(seconds: 2));
                            await Firestore.instance.collection('users').document(order.customerId).collection("History").document(order.orderID).updateData({
                              'status': deliveryLate(arrivedTime['date'], order.timeArrival['date'], now.toString().substring(11,16), order.timeArrival['time'])?"Delivered (Late)":"Delivered",
                              'actualTime': arrivedTime,
                            }

                            );
                            Navigator.pop(context, {'flag': true});
                            Firestore.instance
                                .collection('Staff')
                            .document(employee.id)
                            .collection('Pending Deliveries')
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
