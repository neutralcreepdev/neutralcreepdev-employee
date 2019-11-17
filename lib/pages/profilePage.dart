import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

import '../models/employee.dart';

import '../helpers/color_helper.dart';

import '../services/edbService.dart';

class ProfilePage extends StatefulWidget {
  Employee employee;
  EDBService edb;

  ProfilePage({this.employee, this.edb});

  _ProfilePageState createState() =>
      _ProfilePageState(employee: employee, edb: edb);
}

class _ProfilePageState extends State<ProfilePage> {
  Employee employee;
  EDBService edb;

  bool update;

  _ProfilePageState({this.employee, this.edb});

  final _formKey = GlobalKey<FormState>();
  List<String> selectableMonths = new List<String>();

  List<String> selectableYear = new List<String>();
  String dropdownValue, newValue;
  String month, year;
  bool visibilityTag = false;
  bool initial = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Back button
        automaticallyImplyLeading: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: alablaster,
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
              letterSpacing: 3),
        ),
        elevation: 0.2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: new BoxDecoration(
                          // Circle shape
                          shape: BoxShape.circle,
                          // The border you want
                          border: new Border.all(
                            width: 1.0,
                            color: heidelbergRed,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                          (employee.role=='Packer')?AssetImage('assets/images/P.jpg'):AssetImage('assets/images/D.jpg'),
                          radius: 40.0,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                          width: 100,
                          height: 100,
                          child: QrImage(
                            data: employee.id,
                            foregroundColor: heidelbergRed,
                          )
                      ),
                    ],
                  )),
              Divider(
                height: 60.0,
                color: heidelbergRed,
              ),
              Row(
                children: <Widget>[
                  Text('Full Name: ',
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 2.0,
                      )),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                '${employee.lastName} ${employee.firstName}',
                style: TextStyle(
                    color: heidelbergRed,
                    letterSpacing: 2.0,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25.0),
              Row(
                children: <Widget>[
                  Text('Role:',
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 2.0,
                      )),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                '${employee.role}',
                style: TextStyle(
                    color: heidelbergRed,
                    letterSpacing: 2.0,
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25.0),
              Row(
                children: <Widget>[
                  Text('Gender:',
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 2.0,
                      )),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                '${employee.gender}',
                style: TextStyle(
                    color: heidelbergRed,
                    letterSpacing: 2.0,
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height:25.0),
              Row(
                children: <Widget>[
                  Text('Date of Birth:',
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 2.0,
                      )),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                '${employee.dob['day']}/${employee.dob['month']}/${employee.dob['year']}',
                style: TextStyle(
                    color: heidelbergRed,
                    letterSpacing: 2.0,
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height:25.0),
              Row(
                children: <Widget>[
                  Text('Contact Number:',
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 2.0,
                      )),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                '${employee.contactNum}',
                style: TextStyle(
                    color: heidelbergRed,
                    letterSpacing: 2.0,
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25.0),
              Row(
                children: <Widget>[
                  Text('Email:',
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 2.0,
                      )),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                '${employee.email}',
                style: TextStyle(
                    color: heidelbergRed,
                    letterSpacing: 2.0,
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height:25.0),
              Row(
                children: <Widget>[
                  Text('Address:',
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 2.0,
                      )),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                'Blk ${employee.address['unit']}\n${employee.address['street']}\nS(${employee.address['postalCode']})',
                style: TextStyle(
                    color: heidelbergRed,
                    letterSpacing: 2.0,
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25.0),
            ],
          ),
        ),
      ),
    );
  }
}