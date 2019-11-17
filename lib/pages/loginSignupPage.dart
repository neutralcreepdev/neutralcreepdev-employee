import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neutral_creep_dev/models/customer.dart';
import 'package:neutral_creep_dev/models/employee.dart';

import '../helpers/color_helper.dart';

import '../services/authService.dart';
import '../services/dbService.dart';
import '../services/edbService.dart';

import './homePage.dart';
import './EmployeeHomeScreen.dart';
import './PackagerHomeScreen.dart';

class LoginSignUpPage extends StatefulWidget {
  _LoginSignUpPageState createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormFieldState>();
  final _auth = AuthService();

  //final _db = DBService();
  final _edb = EDBService();
  var isSignUp = true;
  var isRememberMe = false;
  String role = "Packager";
  String _email, _password;

  Container buildLoginSignUpButtonContainer() {
    return Container(
      width: double.infinity,
      //color: Colors.yellow,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text(
                "LOGIN",
                style: TextStyle(
                    color: isSignUp
                        ? heidelbergRed.withOpacity(0.5)
                        : heidelbergRed,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  isSignUp = false;
                });
              },
            ),
            SizedBox(
              width: 10,
            ),
            FlatButton(
              child: Text(
                "SIGN UP",
                style: TextStyle(
                    color: isSignUp
                        ? heidelbergRed
                        : heidelbergRed.withOpacity(0.5),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  isSignUp = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Container buildTermsAndConditionContainer() {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "By pressing \"SIGN UP\" you are agreeing to our",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text("Terms & Conditions",
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Container buildRememberMeAndForgetPassContainer() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                if (isRememberMe) {
                  isRememberMe = false;
                } else {
                  isRememberMe = true;
                }
              });
            },
            child: Container(
                child: Row(
              children: <Widget>[
                isRememberMe
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
                Text("Remember me",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )),
          ),
          Text(
            "Forget Password?",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Align buildSocialSignUpContainer() {
    return Align(
      alignment: Alignment(0, 0.9),
      child: Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        height: 100,
        width: 400,
        child: Column(
          children: <Widget>[
            Text(
              "use social media:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ButtonTheme(
                  height: 40,
                  minWidth: 150,
                  child: RaisedButton(
                    color: Colors.blue,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.facebookF,
                          color: Colors.white,
                        ),
                        SizedBox(width: 20),
                        Text("Facebook",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20))
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)),
                    onPressed: () {},
                  ),
                ),
                ButtonTheme(
                  height: 40,
                  minWidth: 150,
                  child: RaisedButton(
                    color: Colors.orangeAccent,
                    child: Row(
                      children: <Widget>[
                        Icon(FontAwesomeIcons.googlePlusG, color: Colors.white),
                        SizedBox(width: 20),
                        Text("Google",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20))
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)),
                    onPressed: () {
                      print("Google Signup");
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/startPageBG.jpg"),
                fit: BoxFit.fitHeight)),
        child: Stack(
          children: <Widget>[
            //  title text ====================================
            Align(
                alignment: Alignment(0, -0.8),
                child: Text(
                  "NEUTRAL CREEP",
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                )),

            //  login signup container ====================================
            Center(
              child: Form(
                key: _formKey,
                child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  height: 500,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      color: alablaster),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      //  login signup button container ====================================
                      buildLoginSignUpButtonContainer(),

                      //  form container ====================================
                      Container(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Column(
                            children: <Widget>[
                              //  Email text form ====================================
                              TextFormField(
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "EMAIL",
                                ),
                                onSaved: (emailInput) => _email = emailInput,
                                validator: (emailInput) {
                                  if (emailInput.isEmpty) {
                                    return "This field is blank";
                                  }
                                },
                              ),

                              //  password text form ====================================
                              SizedBox(height: 10),
                              TextFormField(
                                key: _passKey,
                                obscureText: true,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: "PASSWORD",
                                ),
                                onSaved: (passwordInput) =>
                                    _password = passwordInput,
                                validator: (passwordInput) {
                                  if (passwordInput.isEmpty) {
                                    return "This field is blank";
                                  }
                                },
                              ),

                              //  confirm password text form ====================================
                              SizedBox(height: 10),
                              isSignUp
                                  ? TextFormField(
                                      obscureText: true,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        hintText: "CONFIRMED PASSWORD",
                                      ),
                                      validator: (confirmPasswordInput) {
                                        if (confirmPasswordInput.isEmpty) {
                                          return "This field is blank";
                                        }

                                        if (confirmPasswordInput !=
                                            _passKey.currentState.value) {
                                          return "Confirm Password should match password";
                                        }
                                      },
                                    )
                                  : Container(),
                            ],
                          )),

                      //  button and terms and condition container ====================================
                      Container(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: <Widget>[
                            isSignUp
                                ? buildTermsAndConditionContainer()
                                : buildRememberMeAndForgetPassContainer(),

                            //  login sign up button ====================================
                            SizedBox(height: 15),
                            ButtonTheme(
                              height: 70,
                              minWidth: 250,
                              child: RaisedButton(
                                color: heidelbergRed,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35)),
                                child: Text(
                                  isSignUp ? "SIGN UP" : "LOGIN",
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    if (isSignUp) {
                                      Future<FirebaseUser> user =
                                          _auth.handleSignUp(_email, _password);
                                      user.then((userValue) {
                                        Firestore.instance
                                            .collection("users")
                                            .document("${userValue.uid}")
                                            .setData({
                                          "id": userValue.uid,
                                          "lastLoggedIn": DateTime.now()
                                        });
                                        Employee employee = new Employee();
                                        Customer customer = new Customer();

                                        if (role == "Delivery") {
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  settings: RouteSettings(
                                                      name: "home"),
                                                  builder: (context) =>
                                                      MyHomePage(
                                                        employee: employee,
                                                        auth: _auth,
                                                        edb: _edb,
                                                      )));
                                        } else if (role == "Packager") {
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  settings: RouteSettings(
                                                      name: "home"),
                                                  builder: (context) =>
                                                      MyHomePage(
                                                        employee: employee,
                                                        auth: _auth,
                                                        edb: _edb,
                                                      )));
                                        }
                                      });
                                    } else {
                                      Future<FirebaseUser> user = _auth
                                          .handleEmailSignIn(_email, _password);
                                      user.then((userValue) {
                                        _edb
                                            .getEmployeeData(userValue.uid)
                                            .then((employee) {
                                          if (role == "Delivery") {
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        settings:
                                                            RouteSettings(
                                                                name: "home"),
                                                        builder: (context) =>
                                                            MyHomePage(
                                                                employee:
                                                                    employee,
                                                                auth: _auth,
                                                                edb: _edb)));
                                          } else if (role == "Packager") {
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        settings:
                                                            RouteSettings(
                                                                name: "home"),
                                                        builder: (context) =>
                                                            PackagerHomePage(
                                                                employee:
                                                                    employee,
                                                                auth: _auth,
                                                                edb: _edb)));
                                          }
                                        });
                                      });
                                    }
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //  facebook and google signup/login container ====================================
            buildSocialSignUpContainer()
          ],
        ),
      ),
    );
  }
}
