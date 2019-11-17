import 'package:flutter/material.dart';
import 'package:neutral_creep_dev/pages/paymentPage.dart';
import 'package:neutral_creep_dev/services/dbService.dart';

import '../models/transaction.dart';
import '../models/customer.dart';

import '../helpers/color_helper.dart';

class SummaryPage extends StatefulWidget {
  final PurchaseTransaction transaction;
  final Customer customer;
  final DBService db;
  SummaryPage({this.transaction, this.customer, this.db});

  _SummaryPageState createState() =>
      _SummaryPageState(transaction: transaction, customer: customer, db: db);
}

class _SummaryPageState extends State<SummaryPage> {
  final PurchaseTransaction transaction;
  final Customer customer;
  final DBService db;

  _SummaryPageState({this.transaction, this.customer, this.db});
  var _dropDownMenuValue = "1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: alablaster,
        iconTheme: IconThemeData(color: heidelbergRed, size: 30),
        centerTitle: true,
        title: Text(
          "Summary",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
              letterSpacing: 3),
        ),
        elevation: 0.2,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: whiteSmoke,
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              "Order #${transaction.id}",
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                SizedBox(width: 10),
                Container(
                  width: MediaQuery.of(context).size.width / 8 + 10,
                  child: Text("Qty",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Container(
                  child: Text("Cost",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                )
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
                itemCount: transaction.getCart().getCartSize(),
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(width: 10),
                          Container(
                              width: MediaQuery.of(context).size.width / 8,
                              child: Text("${index + 1}",
                                  style: TextStyle(fontSize: 18))),
                          Container(
                            width:
                                MediaQuery.of(context).size.width / 8 * 4 - 30,
                            child: Text(
                                "${transaction.getCart().getGrocery(index).name}",
                                style: TextStyle(fontSize: 18)),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: MediaQuery.of(context).size.width / 8 + 10,
                            child: Text(
                                "${transaction.getCart().getGrocery(index).quantity}",
                                style: TextStyle(fontSize: 18)),
                          ),
                          Container(
                            child: Text(
                                "${(transaction.getCart().getGrocery(index).cost * transaction.getCart().getGrocery(index).quantity).toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 18)),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      index + 1 != transaction.getCart().getCartSize()
                          ? Container(
                              width: MediaQuery.of(context).size.width - 30,
                              height: 1,
                              color: Colors.grey,
                            )
                          : Container(),
                      SizedBox(height: 10)
                    ],
                  );
                },
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    "Collection Method",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width - 100,
                    color: gainsboro,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton(
                        isExpanded: true,
                        value: _dropDownMenuValue,
                        items: [
                          DropdownMenuItem(
                            child: Text("Self-Collect"),
                            value: "1",
                          ),
                          DropdownMenuItem(
                            child: Text("addres"),
                            value: "2",
                          )
                        ],
                        onChanged: (value) {
                          setState(() {
                            _dropDownMenuValue = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ButtonTheme(
                    height: 60,
                    minWidth: 250,
                    child: RaisedButton(
                        color: heidelbergRed,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35)),
                        child: Text(
                          "MAKE PAYMENT",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        onPressed: () {
                          db.getEWalletData(customer.id).then((eWallet) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                      transaction: transaction,
                                      customer: customer,
                                      collectionMethod: _dropDownMenuValue,
                                      eWallet: eWallet,
                                    )));
                          });
                        }),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
