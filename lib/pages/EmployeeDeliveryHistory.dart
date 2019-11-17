import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neutral_creep_dev/models/delivery.dart';
import 'package:neutral_creep_dev/pages/summaryPage.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

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
import './EmployeeDeliveryItems.dart';

class DeliveryHistoryPage extends StatefulWidget {
  final Employee employee;
  final AuthService auth;
  final EDBService edb;

  DeliveryHistoryPage({this.employee, this.auth, this.edb});

  _DeliveryHistoryPageState createState() =>
      _DeliveryHistoryPageState(employee: employee, auth: auth, edb: edb);
}

class _DeliveryHistoryPageState extends State<DeliveryHistoryPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Employee employee;
  final AuthService auth;
  final EDBService edb;
  String result = "";
  Color bgColor = Colors.white;
  bool selected = false;
  Delivery _deliveryList = new Delivery();

  _DeliveryHistoryPageState({this.employee, this.auth, this.edb});

  int _selectedIndex = 0; //change to -1
  bool _selected = false;

  Future getData() async {
    var firestore = Firestore.instance;
    //Change to Pending delivery when confirmed for collection
    QuerySnapshot qn = await firestore
        .collection('Staff History')
        .document('${employee.id}')
        .collection('Delivery')
        .getDocuments();
    print("check staff history employee id: ${employee.id}");
    return qn;
  }

  _setCardColor(int index) {
    setState(() {
      _selectedIndex = index;
      _selected = true;
    });
  }

  _itemsDialog(BuildContext context, Order order) {
    Widget continueButton = FlatButton(
      child: Text("Confirm"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Order Info"),
      content: ListView.builder(
          itemCount: order.items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(order.items[index].name),
            );
          }),
      actions: [
        continueButton,
      ],
    );
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
        appBar: AppBar(
          backgroundColor: alablaster,
          centerTitle: true,
          elevation: 0.2,
          iconTheme: IconThemeData(color: heidelbergRed, size: 30),
          title: Text(
            "History",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30,
                letterSpacing: 3),
          ),
        ),
        body: FutureBuilder(
            //child: StreamBuilder(
            future: getData(),
            builder: (context, snapshot) {
              print("check here: ${employee.id}");
              if (!snapshot.hasData) return Text('Loading...');

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
                print("customer ID here leh= ${customerIDTemp}");
                //Fluttertoast.showToast(msg: "date" + dateTemp.toString());
                _deliveryList.addOrders(new Order(
                    orderID: orderIDTemp,
                    name: nameTemp,
                    address: addressTemp,
                    date: dateTemp,
                    customerId: customerIDTemp,
                    items: items,
                    totalAmount: totalAmountTemp));
                print(
                    "check delivery list customerID = ${_deliveryList.getOrders(i).date}");
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
                        child: ListView.builder(
//                            itemCount: snapshot.data.documents.length,
                          itemCount: deliverySize,
                          itemBuilder: (context, index) => Card(
                              child: Container(
                            color: _selectedIndex != null &&
                                    _selectedIndex == index
                                ? Colors.red
                                : Colors.white,
                            child: ListTile(
                                title: Text(
                                    _deliveryList.getOrders(index).toString()),
                                onTap: () => _setCardColor(index),
                                onLongPress: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ItemsSummaryPage(
                                          order:
                                              _deliveryList.getOrders(index))));
                                }),
                          )),
                        ),
                      ),
                      SizedBox(height: 30)
                    ],
                  ));
            }));
  }
}
