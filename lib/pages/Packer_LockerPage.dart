import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:neutral_creep_dev/services/edbService.dart';
import './Packer_MainPage.dart';
import '../models/employee.dart';
import '../models/delivery.dart';


class PackerLockerPageWidget extends StatefulWidget {
  final Employee employee;
  final Order order;
  final EDBService edb;
  PackerLockerPageWidget({this.employee, this.order, this.edb});

  @override
  _PackerLockerPageWidgetState createState() => _PackerLockerPageWidgetState(employee: employee, order: order, edb: edb);
}

class _PackerLockerPageWidgetState extends State<PackerLockerPageWidget> {
  final Employee employee;
  final Order order;
  final EDBService edb;
  _PackerLockerPageWidgetState({this.employee, this.order, this.edb});

  void enteredLockerNum(BuildContext context) async {

    if (lockerNum) {
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
        //Add Self-Collect collection
        await Firestore.instance
            .collection('Self-Collect')
            .document(order.orderID)
            .setData({
          'transactionId': order.orderID,
          'name': order.name,
          'address': order.address,
          'totalAmount': order.totalAmount,
          'items': order.items,
          'dateOfTransaction': order.date,
          'customerId': order.customerId,
        });
        await Firestore.instance
            .collection('users')
            .document(order.customerId)
            .collection(order.collectType)
            .document(order.orderID)
            .updateData({
          'status': "Self-Collect",
          'lockerNum': lockerNo.text,
        });
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

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(
          builder: (context) => PackerMainPageWidget(
            employee: employee,
            edb: edb,
          )));

      Fluttertoast.showToast(
          msg: "Successfully packaged order!", fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Please enter a valid locker number!");
    }
  }

  bool lockerNum=false;

  TextEditingController lockerNo = TextEditingController();

  bool lockerCheck(String lockerNum) {
    bool temp = true;
    if (lockerNum.length==0 || lockerNum.isEmpty||lockerNum==""||lockerNum==null) temp = false;

    if (int.parse(lockerNum) > 100 || int.parse(lockerNum) < 1) {
      temp = false;
    }

    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(

        child: SingleChildScrollView(

          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            constraints: BoxConstraints.tightFor(
              height: MediaQuery.of(context).size.height * 0.95,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
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
                              color: Theme.of(context).canvasColor,
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.2,
                                      color: Theme.of(context).primaryColor))),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.075,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.06,
                                top: MediaQuery.of(context).size.height * 0.025),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Locker No.",
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize:
                                        MediaQuery.of(context).size.width * 0.12,
                                    letterSpacing: 3,
                                    fontFamily: "Air Americana",
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "OrderID: ${widget.order.orderID}",
                                  style: TextStyle(
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).size.width * 0.05,
                                MediaQuery.of(context).size.width * 0.1,
                                0,
                                MediaQuery.of(context).size.width * 0.05),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Choose a free locker no.:",style: TextStyle(fontSize: 20),),
                                    SizedBox(height: 10,),
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.75,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          contentPadding:
                                          const EdgeInsets.all(30.0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(5.0),
                                          ),
                                          hintText: "LockerNo.",
                                        ),
                                        controller: lockerNo,
                                        keyboardType: TextInputType.number,
                                        onChanged: (text) {
                                          lockerNum=false;
                                          try {
                                            if (int.parse(text) > 0 &&
                                                int.parse(text) <= 100)
                                              lockerNum = true;
                                          } catch(Exception) {
                                            lockerNum=false;
                                          }
                                          setState(() {
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      color: Theme.of(context).canvasColor,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: FlatButton(
                            color: lockerNum==true?Theme.of(context).primaryColor:Theme.of(context).cardColor,
                            onPressed: () => this.enteredLockerNum(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            textColor: Colors.white,
                            padding: EdgeInsets.all(0),
                            child: Text(
                              "Done Packing",
                              style: TextStyle(
                                fontSize: 30,
                                fontFamily: "Air Americana",
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
