import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neutral_creep_dev/pages/summaryPage.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import '../helpers/color_helper.dart';

import '../models/cart.dart';
import '../models/customer.dart';
import '../models/eWallet.dart';
import '../models/transaction.dart';

import '../services/authService.dart';
import '../services/dbService.dart';

import './profilePage.dart';
import './eWalletPage.dart';
import './startPage.dart';

class HomePage extends StatefulWidget {
  final Customer customer;
  final AuthService auth;
  final DBService db;

  HomePage({this.customer, this.auth, this.db});
  _HomePageState createState() =>
      _HomePageState(customer: customer, auth: auth, db: db);
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Customer customer;
  final AuthService auth;
  final DBService db;

  String result = "";

  _HomePageState({this.customer, this.auth, this.db});

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();

      setState(() {
        result = qrResult;
        Grocery temp = new Grocery();
        if (temp.setGroceryWithStringInput(result)) {
          temp.quantity = 1;
          customer.currentCart.addGrocery(temp);
        } else {
          print("\n\n\n\n unknown \n\n\n\n\n");
        }
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
          print("$result");
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
          print("$result");
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
        print("$result");
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
        print("$result");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // AppBar =================================================
      appBar: AppBar(
        backgroundColor: alablaster,
        centerTitle: true,
        title: Text(
          "Home",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
              letterSpacing: 3),
        ),
        elevation: 0.2,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: heidelbergRed,
            size: 40,
          ),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.qrcode,
              size: 30,
              color: heidelbergRed,
            ),
            onPressed: () {
              // setState(() {
              //   cartDb[customer.currentCart.getCartSize()].quantity = 1;
              //   customer.currentCart
              //       .addGrocery(cartDb[customer.currentCart.getCartSize()]);
              // });

              _scanQR();
            },
          ),
          SizedBox(width: 20),
        ],
      ),

      // Drawer =================================================
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 30),
            InkWell(
              child: Text(
                "E-Wallet",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Future<EWallet> eWalletData = db.getEWalletData(customer.id);
                eWalletData.then((eWallet) {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EWalletPage(eWallet: eWallet)));
                });
              },
            ),
            SizedBox(height: 30),
            InkWell(
              child: Text(
                "Profile",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            SizedBox(height: 30),
            InkWell(
              child: Text(
                "Logout",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => StartPage()));
              },
            ),
          ],
        ),
      ),

      // Body =================================================
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: whiteSmoke,
          child: customer.currentCart.getCartSize() > 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: customer.currentCart.getCartSize(),
                          itemBuilder: (context, index) {
                            return Card(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      //item image container
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black)),
                                        child: Stack(
                                          children: <Widget>[
                                            Center(
                                                child: Text(
                                              "Image not found",
                                              style: TextStyle(fontSize: 10),
                                            )),
                                            customer.currentCart
                                                        .getGrocery(index)
                                                        .image !=
                                                    null
                                                ? customer.currentCart
                                                    .getGrocery(index)
                                                    .image
                                                : Container(),
                                          ],
                                        ),
                                      ),

                                      // itme description container
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                              "${customer.currentCart.getGrocery(index).name}"),
                                          Text(
                                              "${customer.currentCart.getGrocery(index).description}"),
                                          Text(
                                              "\$${customer.currentCart.getGrocery(index).cost.toStringAsFixed(2)}")
                                        ],
                                      ),
                                    ],
                                  ),

                                  // add qty container
                                  Column(
                                    children: <Widget>[
                                      FlatButton(
                                        child: Icon(Icons.arrow_drop_up),
                                        onPressed: () {
                                          setState(() {
                                            customer.currentCart
                                                .getGrocery(index)
                                                .quantity += 1;
                                          });
                                        },
                                      ),
                                      Text(
                                          "${customer.currentCart.getGrocery(index).quantity}"),
                                      FlatButton(
                                        child: (customer.currentCart
                                                    .getGrocery(index)
                                                    .quantity >
                                                1)
                                            ? Icon(Icons.arrow_drop_down)
                                            : Icon(Icons.clear),
                                        onPressed: () {
                                          if (customer.currentCart
                                                  .getGrocery(index)
                                                  .quantity >
                                              1) {
                                            setState(() {
                                              customer.currentCart
                                                  .getGrocery(index)
                                                  .quantity -= 1;
                                            });
                                          } else {
                                            setState(() {
                                              customer.currentCart
                                                  .removeGrocery(index);
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Text(
                              "Total Cost: \$${customer.currentCart.getTotalCost().toStringAsFixed(2)}"),
                          Text(
                              "GST 7%: \$${(customer.currentCart.getTotalCost() * 0.07).toStringAsFixed(2)}"),
                          Text(
                              "Grand Total: \$${(customer.currentCart.getTotalCost() * 1.07).toStringAsFixed(2)}"),
                          SizedBox(height: 10),
                          ButtonTheme(
                            height: 60,
                            minWidth: 250,
                            child: RaisedButton(
                              color: heidelbergRed,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35)),
                              child: Text(
                                "SUMMARY",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              onPressed: () {
                                PurchaseTransaction transaction =
                                    new PurchaseTransaction(
                                        cart: customer.currentCart);

                                db
                                    .getTransactionId(customer.id)
                                    .then((transactionId) {
                                  transaction.setId(
                                      transactionId.toString().padLeft(8, "0"));
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => SummaryPage(
                                                transaction: transaction,
                                                customer: customer,
                                                db: db,
                                              )))
                                      .then((value) {
                                    print("$value");
                                  });
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30)
                  ],
                )
              : Center(
                  child: Text("current nothing in cart"),
                )),
    );
  }
}

Grocery item1 = new Grocery(
    id: "1",
    name: "Red Ball-Point Pencil",
    description: "this is a pencil",
    supplier: "Kenyon's Pencils Pte",
    cost: 1.50,
    imageURL:
        "https://firebasestorage.googleapis.com/v0/b/neutral-creep-dev.appspot.com/o/apple.jpg?alt=media&token=43d25e60-a478-4e8d-9bcd-793aa918d84c");

Grocery item2 = new Grocery(
    id: "2",
    name: "elifford The Big Red Cock",
    description: "this is a big red cock",
    supplier: "ZP YAOZ CLUB HOUSE",
    cost: 37.45);
Grocery item3 = new Grocery(
    id: "3",
    name: "Fuji Apple (Small)",
    description: "this is an apple",
    supplier: "Matts Farm (Japan)",
    cost: 8.20);
Grocery item4 = new Grocery(
    id: "4",
    name: "Square Watermalon",
    description: "this is a watermelon",
    supplier: "RayRay's Weird & Wonderful Garden",
    cost: 7.80);
Grocery item5 = new Grocery(
    id: "5",
    name: "1-Ply Tissue Packet",
    description: "this is a tissue packet",
    supplier: "Mama Cheap Cheap ABC",
    cost: 0.50);

Grocery item6 = new Grocery(
    id: "6",
    name: "Red Ball-Point Pencil",
    description: "this is a pencil",
    supplier: "Kenyon's Pencils Pte",
    cost: 1.50,
    imageURL:
        "https://firebasestorage.googleapis.com/v0/b/neutral-creep-dev.appspot.com/o/apple.jpg?alt=media&token=43d25e60-a478-4e8d-9bcd-793aa918d84c");

Grocery item7 = new Grocery(
    id: "7",
    name: "elifford The Big Red Cock",
    description: "this is a big red cock",
    supplier: "ZP YAOZ CLUB HOUSE",
    cost: 37.45);
Grocery item8 = new Grocery(
    id: "8",
    name: "Fuji Apple (Small)",
    description: "this is an apple",
    supplier: "Matts Farm (Japan)",
    cost: 8.20);
Grocery item9 = new Grocery(
    id: "9",
    name: "Square Watermalon",
    description: "this is a watermelon",
    supplier: "RayRay's Weird & Wonderful Garden",
    cost: 7.80);
Grocery item10 = new Grocery(
    id: "10",
    name: "1-Ply Tissue Packet",
    description: "this is a tissue packet",
    supplier: "Mama Cheap Cheap ABC",
    cost: 0.50);

var cartDb = [
  item1,
  item2,
  item3,
  item4,
  item5,
  item6,
  item7,
  item8,
  item9,
  item10
];
