import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encPkg;
import 'package:encrypt/encrypt.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './Packer_MainPage.dart';
import './Delivery_MainPage.dart';
import '../services/authService.dart';
import '../services/edbService.dart';


class LoginPageWidget extends StatefulWidget {
  @override
  _LoginPageWidgetState createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  void onLogInButtonPressed(BuildContext context)=> Navigator.push(
      context, MaterialPageRoute(builder: (context) => PackerMainPageWidget()));


  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _edb = EDBService();
  final emailText = TextEditingController();
  final passwordText = TextEditingController();
  bool isRememberMe = false;
  SharedPreferences sp;

  //Encryption AES and RSA
  static final key = encPkg.Key.fromUtf8('CSIT-321 FYPQRCODEORDERINGSYSTEM');
  final iv = IV.fromLength(16);
  final enc = Encrypter(AES(key));

  void initState() {
    super.initState();
    getEmailPassword();
  }

  _onChanged(bool value) async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      isRememberMe = value;
      if(isRememberMe) {
        if(emailText.text!="" && passwordText.text!="") {
          final emailEnc = enc.encrypt(emailText.text, iv: iv);
          final passwordEnc = enc.encrypt(passwordText.text, iv: iv);
          sp.setBool("check", isRememberMe);
          sp.setString("email", emailEnc.base64);
          sp.setString("password", passwordEnc.base64);
          sp.commit();
          getEmailPassword();
        }
      } else {
        sp.clear();
      }

    });
  }

  getEmailPassword() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      isRememberMe = sp.getBool("check");
      if (isRememberMe != null) {
        if (isRememberMe) {
          if(sp.getString("email")!="" && sp.getString("password")!="") {
            String decEmailText = enc.decrypt64(sp.getString("email"), iv: iv);
            String decPasswordText = enc.decrypt64(sp.getString("password"), iv: iv);
            emailText.text = decEmailText;
            passwordText.text = decPasswordText;
          }
        } else {
          emailText.clear();
          passwordText.clear();
          sp.clear();
        }
      } else {
        isRememberMe = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(
                height: MediaQuery.of(context).size.height,
              ),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/BG.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 9,
                      child: Container(
                        child: Align(
                          alignment:Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(top:30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/images/logo-neutralcreep2019-2.png"),
                                      fit: BoxFit.cover,
                                    ),),
                                  width: MediaQuery.of(context).size.width*0.4,
                                  height: MediaQuery.of(context).size.height*0.18,
                                ),
                                Text("Employee Version"),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Text(
                                    "LOGIN",
                                    style: TextStyle(fontSize: 40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Spacer(flex: 2),
                            Expanded(
                              flex: 23,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Email:",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.85,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(15.0),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        hintText: "Email",
                                      ),
                                      validator: (emailInput) {
                                        if (emailInput.isEmpty) {
                                          return "This field is blank";
                                        }
                                        bool checkEmail = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailInput);
                                        if(checkEmail==false)
                                          return "Please enter a valid email";
                                      },
                                      controller: emailText,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Spacer(
                              flex: 2,
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Spacer(flex: 2),
                            Expanded(
                              flex: 23,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Password:",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.85,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(15.0),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        hintText: "Password",
                                      ),
                                      obscureText: true,
                                      validator: (passwordInput) {
                                        if (passwordInput.isEmpty) {
                                          return "This field is blank";
                                        }
                                      },
                                      controller: passwordText,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right:12.0),
                                        child: Row(
                                          children: <Widget>[
                                            Checkbox(
                                              value: isRememberMe,
                                              onChanged: _onChanged
                                            ),
                                            Text(
                                              "Remember Me",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Spacer(
                              flex: 2,
                            )
                          ],
                        ),
                      ),
                    ),
                    Spacer(flex: 3,),
                      Container(
                        height: 50,
                        child: Center(child: Column(
                          children: <Widget>[Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.height * 0.07,
                              child: FlatButton(
                                color: Theme.of(context).primaryColor,
                                onPressed: () async{
                                  bool x =true;
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          Future<FirebaseUser> user = _auth
                                              .handleEmailSignIn(emailText.text, passwordText.text, context);
                                          user.then((userValue) {
                                            _edb
                                                .getEmployeeData(userValue.uid)
                                                .then((employee) {
                                              if (employee.role == "Delivery") {
                                                _onChanged(isRememberMe);
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                    MaterialPageRoute(
                                                        settings:
                                                        RouteSettings(
                                                            name: "home"),
                                                        builder: (context) =>
                                                            DeliveryMainPageWidget(
                                                                employee:
                                                                employee,
                                                                edb: _edb)));
                                              } else if (employee.role == "Packer") {
                                                _onChanged(isRememberMe);
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                    MaterialPageRoute(
                                                        settings:
                                                        RouteSettings(
                                                            name: "home"),
                                                        builder: (context) =>
                                                            PackerMainPageWidget(
                                                                employee:
                                                                employee,
                                                                edb: _edb)));
                                              } else{
                                                Fluttertoast.showToast(msg: "Unable to login, please contact your manager.");
                                              }
                                            }).catchError((error, stackTrace) {
                                              Navigator.pop(context);
                                              x = false;
                                            });
                                          }).catchError((error, stackTrace) {
                                            Navigator.pop(context);
                                            x = false;
                                          });
                                          return Dialog(
                                              backgroundColor:
                                              Colors.transparent,
                                              child: x
                                                  ? SpinKitRotatingCircle(
                                                color: Colors.white,
                                                size: 50.0,
                                              )
                                                  : Text("Check Authentication"));
                                        });
                                    if (x == false) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          // return object of type Dialog
                                          return AlertDialog(
                                            title: new Text("Error"),
                                            content: new Text(
                                                "Incorrect Login Details"),
                                            actions: <Widget>[
                                              // usually buttons at the bottom of the dialog
                                              new FlatButton(
                                                child: new Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                textColor: Colors.white,
                                padding: EdgeInsets.all(0),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 30
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          ],
                        ),),
                      ),
                    Spacer(flex: 2,)
                  ],
                ) /* add child content here */,
              ),
            ),
          ),
        ),
      ),
    );
  }
}