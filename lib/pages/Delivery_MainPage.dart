import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import './DeliveryConfirmationPage.dart';
import './LoginPage.dart';
import '../models/employee.dart';
import '../models/delivery.dart';
import '../services/edbService.dart';



class DeliveryMainPageWidget extends StatefulWidget {
  final Employee employee;
  final EDBService edb;

  DeliveryMainPageWidget({this.employee, this.edb});
  @override
  _DeliveryMainPageState createState() => _DeliveryMainPageState(employee: employee, edb: edb);
}

class _DeliveryMainPageState extends State<DeliveryMainPageWidget> {
  final Employee employee;
  final EDBService edb;
  _DeliveryMainPageState({this.employee, this.edb});

  Future getDeliveries() async {
    QuerySnapshot qn;
    if(shown==packages) {
      var firestore = Firestore.instance;
      qn = await firestore.collection('Delivery').getDocuments();
    } else if (shown==curr) {
      var firestore = Firestore.instance;
      //Change to Pending delivery when confirmed for collection
      qn = await firestore
          .collection('Staff')
          .document(employee.id)
          .collection('Pending Deliveries')
          .getDocuments();
      return qn;
    } else if (shown==history) {
      var firestore = Firestore.instance;
      //Change to Pending delivery when confirmed for collection
      qn = await firestore
          .collection('Staff')
          .document(employee.id)
          .collection('Staff History')
          .getDocuments();
    }
    return qn;
  }

  void LogOutButtonPressed(BuildContext context){    FirebaseAuth.instance.signOut();
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPageWidget()));}

  void showMoreInfo(Employee employee, BuildContext context, String type, Order order) async{
   await showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return MyDialog(employee: employee, type: type, order: order);
        });
   setState((){});
  }

  void onPackagesPressed(BuildContext context) {
    packagesActivate = true;
    currActivate = false;
    historyActivate = false;
    shown = packages;
    type = "Packages";
  }

  void onCurrPressed(BuildContext context) {
    packagesActivate = false;
    currActivate = true;
    historyActivate = false;
    shown = curr;
    type = "Current Delivery";
  }

  void onHistoryPressed(BuildContext context) {
    packagesActivate = false;
    currActivate = false;
    historyActivate = true;
    shown = history;
    type = "History";
  }

  Text emptyOrders() {
    if(shown==packages) {
      return Text("Currently no delivery orders");
    } else if (shown==curr) {
      return Text("Currently no delivery orders in your list");
    } else {
      return Text("Delivery History is empty");
    }
  }

  String shown = "Packages";
  String type = "Packages";
  String packages = "Packages";
  String curr = "Current";
  String history = "History";

  bool packagesActivate = true;

  bool currActivate = false;

  bool historyActivate = false;

  int noOfitems;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Container(
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
                        decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.2,
                                    color: Theme.of(context).primaryColor))),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.075,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "${employee.lastName} ${employee.firstName}",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  "${employee.role}",
                                  style: TextStyle(fontSize: 15),
                                )
                              ],
                            ),
                          ),
                        ),
                        Spacer(flex: 6),
                        Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                this.LogOutButtonPressed(context);
                                setState(() {});
                              },
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Log Out",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            this.onPackagesPressed(context);
                            setState(() {});
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Packages",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Container(
                                    width: 60,
                                    height: 2,
                                    color: packagesActivate
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            this.onCurrPressed(context);
                            setState(() {});
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Current",
                                  style: TextStyle(fontSize: 19),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    height: 2,
                                    color: currActivate
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            this.onHistoryPressed(context);
                            setState(() {});
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "History",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.13,
                                    height: 2,
                                    color: historyActivate
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Spacer()
                    ],
                  ),
                ),
                Expanded(
                  flex: 7,
                    child: FutureBuilder(
                        future: getDeliveries(),
                        builder: (context, snapshot) {
                          Delivery _deliveryList = new Delivery();
                          if (!snapshot.hasData)
                            return Dialog(
                                backgroundColor:
                                Colors.transparent,
                                child: SpinKitRotatingCircle(
                                  color: Colors.white,
                                  size: 50.0,
                                )
                                   );
                          else {
                            if (snapshot.data.documents.length == 0) {
                              return Center(
                                child: emptyOrders(),
                              );
                            } else {
                              for (int i = 0; i < snapshot.data.documents
                                  .length; i++) {
                                String orderIDTemp =
                                snapshot.data.documents[i]['transactionId'];
                                Map addressTemp =
                                Map.from(snapshot.data.documents[i]['address']);
                                String nameTemp = snapshot.data
                                    .documents[i]['name'];
                                DateTime dateTemp =
                                snapshot.data.documents[i]['dateOfTransaction']
                                    .toDate();
                                List<dynamic> items = new List<dynamic>();
                                items = snapshot.data.documents[i]['items'];
                                double totalAmountTemp = double.parse(
                                    snapshot.data.documents[i]['totalAmount']
                                        .toString());
                                String customerIDTemp =
                                snapshot.data.documents[i]['customerId'];
                                String collectTypeTemp =
                                snapshot.data.documents[i]['collectType'];
                                Map timeArrivalTemp;
                                Map expectedArrivalTemp;
                                if(shown==history) {
                                  timeArrivalTemp = snapshot.data.documents[i]['expectedTime'];
                                  expectedArrivalTemp = snapshot.data.documents[i]['actualTime'];
                                } else {
                                  timeArrivalTemp = snapshot.data.documents[i]['timeArrival'];
                                  expectedArrivalTemp = new Map();
                                }
                                _deliveryList.addOrders(new Order(
                                    orderID: orderIDTemp,
                                    name: nameTemp,
                                    address: addressTemp,
                                    date: dateTemp,
                                    customerId: customerIDTemp,
                                    items: items,
                                    collectType: collectTypeTemp,
                                    timeArrival: timeArrivalTemp,
                                    actualTime: expectedArrivalTemp,
                                    totalAmount: totalAmountTemp));
                              }
                            }

                            return Container(
                              child: ListView.builder(
                                  itemCount: _deliveryList.getOrdersSize(),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            this.showMoreInfo(employee, context, type, _deliveryList.getOrders(index));
                                          },
                                          child: Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.97,
                                            height: MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.1,
                                            decoration: BoxDecoration(
                                              color: Theme
                                                  .of(context)
                                                  .primaryColor,
                                              borderRadius: BorderRadius.circular(
                                                  5),
                                            ),
                                            child: Align(
                                              child: Container(
                                                  width:
                                                  MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.965,
                                                  height: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .height *
                                                      0.098,
                                                  decoration: BoxDecoration(
                                                      color: Theme
                                                          .of(context)
                                                          .backgroundColor,
                                                      borderRadius: BorderRadius
                                                          .circular(5),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Theme
                                                              .of(context)
                                                              .cardColor)),
                                                  child: Center(
                                                      child: Text(
                                                          "${_deliveryList.getOrders(index)}"))),
                                              alignment: Alignment.topLeft,
                                            ),
                                          ),
                                        ),
                                        index + 1 != _deliveryList.getOrdersSize()
                                            ? Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width,
                                            height: 15)
                                            : Container(),
                                      ],
                                    );
                                  }
                              ),
                            );
                          }
                        })),
                Expanded(flex: 1,child: Container(color:Theme.of(context).canvasColor),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyDialog extends StatefulWidget {
  Employee employee;
  String type;
  Order order;

  MyDialog({this.employee, this.type, this.order});

  @override
  _MyDialogState createState() =>
      new _MyDialogState(employee: employee, type: type, order: order);
}

class _MyDialogState extends State<MyDialog> {
  Employee employee;
  String type;
  Order order;
  _MyDialogState({this.employee, this.type, this.order});
  void confirmDelivery(BuildContext context, Employee employee, Order order) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DeliveryConfirmationPageWidget(employee: employee, order: order)));
    setState(() {
    });
  }

  addDeliveryDialog(Employee employee, BuildContext context, Order order) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);

      },
    );
    Widget continueButton = FlatButton(
      child: Text("Confirm"),
      onPressed: () async {
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
            .collection('Pending Deliveries')
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
          'employeeId': employee.id,
        });

        await Firestore.instance
            .collection('users')
            .document(order.customerId)
            .collection("Delivery")
            .document(order.orderID)
            .updateData({'status': "Delivering"});

        //To add to addDeliveryDialog
        Firestore.instance
            .collection('Delivery')
            .document(order.orderID)
            .delete();

        Navigator.popUntil(context, ModalRoute.withName('home'));
//        Navigator.of(context).pushReplacement(MaterialPageRoute(
//            builder: (context) => DeliveryMainPageWidget()));
        Fluttertoast.showToast(
            msg: "Successfully added to Delivery List!", fontSize: 16.0);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Add Delivery"),
      content: Text("Do you want to add this order to your delivery list?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void addToCurr(Employee employee, BuildContext context) {
    addDeliveryDialog(employee, context, order);
    //Navigator.pop(context);
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      child: Icon(Icons.clear),
                    ),
                  )),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.075,
                  0,
                  0,
                  MediaQuery.of(context).size.width * 0.045),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.16,
                width: MediaQuery.of(context).size.width,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "OrderID: ${order.orderID}",
                          style: TextStyle(fontSize: 40),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Requested Delivery Timing:  ${order.expectedTimeString()}", style: TextStyle(fontSize: 17)),
                        SizedBox(
                          height: 2,
                        ),
                        type=="History"?Text("Actual Delivered Timing: ${order.actualTimeString()}", style: TextStyle(fontSize: 17)):SizedBox(height:0),
                        type=="History"?SizedBox(height:2):SizedBox(height:0),
                        Text("Address: ${order.address['street']} ${order.address['unit']} S(${order.address['postalCode']})",
                            style: TextStyle(fontSize: 17)),
                      ],
                    )),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: SizedBox(width: 10)),
                      Expanded(
                        flex: 2,
                        child: Container(
                            width: MediaQuery.of(context).size.width / 8,
                            child: Text("No.", style: TextStyle(fontSize: 20))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 8 * 4 - 40,
                          child: Text("Item", style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Expanded(flex: 4, child: SizedBox(width: 10)),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 8 + 10,
                          child: Text("Qty", style: TextStyle(fontSize: 20)),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(
                    height: MediaQuery.of(context).size.width * 0.02,
                    color: Theme.of(context).accentColor,
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: order.items.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Flexible(
                                fit: FlexFit.loose,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(child: SizedBox(width: 10)),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              8,
                                          child: Text("${index + 1}",
                                              style: TextStyle(fontSize: 18))),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    8 *
                                                    4 -
                                                30,
                                        child: Text("${order.items[index]['name']}",
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 4, child: SizedBox(width: 10)),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    8 +
                                                10,
                                        child: Text("${order.items[index]['quantity']}",
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                  fit: FlexFit.loose,
                                  child: SizedBox(height: 10)),
                              index + 1 != order.items.length
                                  ? Container(
                                      width: MediaQuery.of(context).size.width -
                                          30,
                                      height: 1)
                                  : Container(),
                              SizedBox(height: 10)
                            ],
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            type=="Packages"?Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: FlatButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                        addDeliveryDialog(employee, context, order);},
                    textColor: Colors.white,
                    padding: EdgeInsets.all(0),
                    child: Text(
                      "Add Order to Current",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: "Air Americana",
                      ),
                      textAlign: TextAlign.center,
                    ),
              ),
            ),
                  ),
                )):type=="History"?Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.center,
                  ),
                )):
            Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: FlatButton(
                        color: Theme.of(context).primaryColor,
                        onPressed: () => this.confirmDelivery(context, employee, order),
                        textColor: Colors.white,
                        padding: EdgeInsets.all(0),
                        child: Text(
                          "Arrived at Address",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: "Air Americana",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
