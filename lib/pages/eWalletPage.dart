import 'package:flutter/material.dart';

import '../helpers/color_helper.dart';

import '../models/eWallet.dart';

import './topUpPage.dart';

class EWalletPage extends StatefulWidget {
  final EWallet eWallet;

  EWalletPage({this.eWallet});

  _EWalletPageState createState() => _EWalletPageState(eWallet: eWallet);
}

class _EWalletPageState extends State<EWalletPage> {
  final EWallet eWallet;

  _EWalletPageState({this.eWallet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: alablaster,
        centerTitle: true,
        elevation: 0.2,
        iconTheme: IconThemeData(color: heidelbergRed, size: 30),
        title: Text(
          "E-Wallet",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
              letterSpacing: 3),
        ),
      ),
      body: Container(
        color: whiteSmoke,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            // current amount text ==========================================
            SizedBox(height: 30),
            Text(
              "CURRRENT AMOUNT:\n\$${eWallet.eCreadits.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            // buttons container ==========================================
            SizedBox(height: 30),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width / 3,
                    height: 100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: RaisedButton(
                      color: heidelbergRed,
                      child: Text(
                        "TOP-UP",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => new TopUpPage()));
                      },
                    ),
                  ),
                  SizedBox(width: 50),
                  ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width / 3,
                    height: 100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: RaisedButton(
                      color: heidelbergRed,
                      child: Text(
                        "TRANSFER",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // transaction history container ==========================================
            SizedBox(height: 50),
            Container(
              child: Column(
                children: <Widget>[
                  Text("Transection History",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width - 70,
                    color: Colors.blue,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[Text("id")],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
