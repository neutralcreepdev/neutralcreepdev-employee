import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import './Packer_MainPage.dart';
import './Packer_LockerPage.dart';
import '../models/employee.dart';
import '../models/delivery.dart';
import '../services/edbService.dart';


class PackerPackingPageWidget extends StatefulWidget {
  final Employee employee;
  final EDBService edb;

  PackerPackingPageWidget({this.employee, this.edb});

  @override
  _PackerPackingPageWidgetState createState() =>
      _PackerPackingPageWidgetState(employee: employee, edb: edb);
}

class _PackerPackingPageWidgetState extends State<PackerPackingPageWidget> {
  final Employee employee;
  final EDBService edb;

  _PackerPackingPageWidgetState({this.employee, this.edb});

  bool done = false;
  int initCount = 0;
  List<bool> itemsCheck;
  final databaseReference = Firestore.instance;

  void onPackingDone(BuildContext context, Order order) async {
    if (done) {
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
      if (order.collectType == "Self-Collect") {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                PackerLockerPageWidget(
                  employee: employee,
                  order: order,
                  edb: edb,
                )));
      } else {
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
            .collection(order.collectType)
            .document(order.orderID)
            .updateData({'status': "Packaged"});

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
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                PackerMainPageWidget(
                  employee: employee,
                  edb: edb,
                )));
        Fluttertoast.showToast(
            msg: "Successfully packaged order!", fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(msg: "Please check all items!");
    }
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

  bool allItemsPackaged(List<bool> itemsCheck, String collectType) {
    bool temp = true;

    for (int i = 0; i < itemsCheck.length; i++) {
      if (itemsCheck[i] == false) temp = false;
    }

    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              bool x=false;
              Delivery _deliveryList = new Delivery();
              if (!snapshot.hasData) {
                x=true;
                if(x==true) {
                  return Dialog(
                      backgroundColor: Colors.transparent,
                      child: SpinKitRotatingCircle(
                        color: Colors.white,
                        size: 50.0,
                      ));
                }
                return null;
              }
              else {
                if(x==true) {
                  x=false;
                  Navigator.pop(context);
                }
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

                String orderIDTemp;
                Map addressTemp;
                String nameTemp;
                DateTime dateTemp;
                List<dynamic> items;
                double totalAmountTemp;
                String customerIDTemp;
                String collectType;
                Map timeArrival;
                Order order;

                try {
                  orderIDTemp = snapshot.data
                      .documents[0]['transactionId'];
                  addressTemp = Map.from(
                      snapshot.data.documents[0]['address']);
                  nameTemp = snapshot.data.documents[0]['name'];
                  dateTemp =
                  snapshot.data.documents[0]['dateOfTransaction'].toDate();
                  items = snapshot.data.documents[0]['items'];
                 totalAmountTemp = double.parse(
                      snapshot.data.documents[0]['totalAmount'].toString());
                  customerIDTemp = snapshot.data
                      .documents[0]['customerId'];
                  collectType = snapshot.data
                      .documents[0]['collectType'];
                  timeArrival = snapshot.data.documents[0]['timeArrival'];
                  order = new Order(
                      orderID: orderIDTemp,
                      name: nameTemp,
                      address: addressTemp,
                      date: dateTemp,
                      customerId: customerIDTemp,
                      items: items,
                      collectType: collectType,
                      timeArrival: timeArrival,
                      totalAmount: totalAmountTemp);

                  _deliveryList.addOrders(order);
                } catch (Exception) {
                  return Container();
                }
                return Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                  constraints: BoxConstraints.expand(),
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .backgroundColor,
                  ),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Theme
                                        .of(context)
                                        .canvasColor,
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 0.2,
                                            color:
                                            Theme
                                                .of(context)
                                                .primaryColor))),
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                height:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.075,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: MediaQuery
                                          .of(context)
                                          .size
                                          .width *
                                          0.06,
                                      top: MediaQuery
                                          .of(context)
                                          .size
                                          .height *
                                          0.025),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Text(
                                        "Packing",
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .accentColor,
                                          fontSize:
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width *
                                              0.12,
                                          letterSpacing: 3,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        "Order ID: ${order.orderID}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text("Delivery method: ${order.collectType}" ,style: TextStyle(fontSize: 20),),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.05,
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.1,
                                      0,
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.05),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.05),
                                child: Container(
                                  height:
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.5,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Container(
                                              width: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width /
                                                  8,
                                              child: Text("No.",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      fontSize: 20,))),
                                          Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width /
                                                8 *
                                                4 -
                                                40,
                                            child: Text("Item",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20)),
                                          ),
                                          SizedBox(width: 10),
                                          Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width /
                                                8 +
                                                10,
                                            child: Text("Qty",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20)),
                                          ),
                                          Container(
                                            child: Text("Check",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20)),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Divider(
                                        height:
                                        MediaQuery
                                            .of(context)
                                            .size
                                            .width *
                                            0.02,
                                        color: Theme
                                            .of(context)
                                            .accentColor,
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
                                                        MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width /
                                                            8,
                                                        child: Text(
                                                            "${index + 1}",
                                                            style: TextStyle(
                                                                fontSize: 18))),
                                                    Container(
                                                      width:
                                                      MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width /
                                                          8 *
                                                          4 -
                                                          30,
                                                      child: Text(
                                                          "${order
                                                              .items[index]['name']}",
                                                          style: TextStyle(
                                                              fontSize: 18)),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      width:
                                                      MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width /
                                                          8 +
                                                          10,
                                                      child: Text(
                                                          "${order
                                                              .items[index]['quantity']
                                                              .toString()}",
                                                          style: TextStyle(
                                                              fontSize: 18)),
                                                    ),
                                                    Container(
                                                      child: Checkbox(
                                                        value: itemsCheck[index],
                                                        onChanged: (
                                                            bool value) {
                                                          setState(() {
                                                            itemsCheck[index] =
                                                                value;
                                                            done =
                                                                allItemsPackaged(
                                                                    itemsCheck,
                                                                    collectType);
                                                            //itemsCheck[index] = value;
                                                          });
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                index + 1 != order.items.length
                                                    ? Container(
                                                    width:
                                                    MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width -
                                                        30,
                                                    height: 1)
                                                    : Container(),
                                                SizedBox(height: 10)
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                            color: Theme
                                .of(context)
                                .canvasColor,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.10,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.9,
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.07,
                                child: FlatButton(
                                  color: done == true
                                      ? Theme
                                      .of(context)
                                      .primaryColor
                                      : Theme
                                      .of(context)
                                      .cardColor,
                                  onPressed: () async {
                                    onPackingDone(
                                        context, _deliveryList.getOrders(0));
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                  ),
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(0),
                                  child: order.collectType=="Self-Collect"?Text(
                                    "Proceed to input locker number",
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                    textAlign: TextAlign.center,
                                  ):Text(
                                    "Complete packing",
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ],
                  ),
                );
              }}),
      ),
    );
  }
}
