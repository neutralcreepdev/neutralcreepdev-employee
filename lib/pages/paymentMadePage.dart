import 'package:flutter/material.dart';

import '../models/eWallet.dart';

import '../helpers/color_helper.dart';

class PaymentMadePage extends StatelessWidget {
  final EWallet eWallet;

  PaymentMadePage({this.eWallet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: alablaster,
        centerTitle: true,
        title: Text(
          "Payment",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
              letterSpacing: 3),
        ),
        elevation: 0.2,
        leading: Container(),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: whiteSmoke,
        child: Center(
          child: Column(
            children: <Widget>[
              Text("Purchase Confirmed"),
              Text("Credits Remaining: ${eWallet.eCreadits}"),
              ButtonTheme(
                height: 60,
                minWidth: 250,
                child: RaisedButton(
                    color: heidelbergRed,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)),
                    child: Text(
                      "HOME",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
