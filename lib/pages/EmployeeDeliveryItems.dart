import 'package:flutter/material.dart';

import '../models/delivery.dart';

import '../helpers/color_helper.dart';

class ItemsSummaryPage extends StatefulWidget {
  final Order order;
  ItemsSummaryPage({this.order});

  _ItemsSummaryPageState createState() =>
      _ItemsSummaryPageState(order: order);
}

class _ItemsSummaryPageState extends State<ItemsSummaryPage> {
  final Order order;

  _ItemsSummaryPageState({this.order});

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
                              width: MediaQuery.of(context).size.width / 8,
                              child: Text("${index + 1}",
                                  style: TextStyle(fontSize: 18))),
                          Container(
                            width:
                                MediaQuery.of(context).size.width / 8 * 4 - 30,
                            child: Text(
                                "${order.items[index]['name']}",
                                style: TextStyle(fontSize: 18)),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: MediaQuery.of(context).size.width / 8 + 10,
                            child: Text(
                                "${order.items[index]['quantity']}",
                                style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
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
                          "OK",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
        );
  }
}
