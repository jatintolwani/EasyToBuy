import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/screens/termsAndConditions_screen.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formkey = GlobalKey<FormState>();
  var email = TextEditingController();
  var name = TextEditingController();
  var phone = TextEditingController();
  var password = TextEditingController();
  bool isLoading = false;

  register() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      try {
        setState(() {
          isLoading = true;
        });
        print("yes");
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text, password: password.text);
        currentUser = FirebaseAuth.instance.currentUser.uid;
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser)
            .set({
          'userID': currentUser,
          'email': email.text,
          'phone': phone.text,
          'name': name.text,
          "usedCoupons": [],
          "etbCoins": 100
        });
        name.clear();
        phone.clear();
        email.clear();
        password.clear();
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        var message = 'An error occurred, please check your credentials!';
        fToast.removeQueuedCustomToasts();
        fToast.showToast(
          child: Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(
            seconds: 1,
          ),
        );
      }
    }
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
                child: Form(
            key: _formkey,
            child: Column(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(90)),
                    color: primaryColor,
                    gradient: LinearGradient(
                      colors: [(new Color(0xff324e7b)), primaryColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 50),
                        child: Image.asset(
                          "images/app_logo.png",
                          height: 90,
                          width: 90,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 20, top: 20),
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "Register",
                          style: TextStyle(fontSize: 20, color: accentColor),
                        ),
                      ),
                    ],
                  )),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 20, right: 20, top: 70),
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 50,
                          color: accentColor),
                    ],
                  ),
                  child: TextFormField(
                    controller: name,
                    validator: (value) {
                      if (value.length < 4) {
                        return "Name must be more than 4 Charaters";
                      }
                      return null;
                    },
                    cursorColor: primaryColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: primaryColor,
                      ),
                      hintText: "Full Name",
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 50,
                          color: accentColor),
                    ],
                  ),
                  child: TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Enter Email";
                      } else if (!isEmail(value)) {
                        return "Email not formatted properly";
                      }
                      return null;
                    },
                    cursorColor: primaryColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: primaryColor,
                      ),
                      hintText: "Email",
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 20),
                          blurRadius: 100,
                          color: accentColor),
                    ],
                  ),
                  child: TextFormField(
                    controller: phone,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.length != 10) {
                        return "Mobile Number must be 10 digit";
                      }
                      return null;
                    },
                    cursorColor: primaryColor,
                    decoration: InputDecoration(
                      focusColor: primaryColor,
                      icon: Icon(
                        Icons.phone,
                        color: primaryColor,
                      ),
                      hintText: "Phone Number",
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: accentColor,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 20),
                          blurRadius: 100,
                          color: accentColor),
                    ],
                  ),
                  child: TextFormField(
                    controller: password,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Enter Password";
                      }
                      return null;
                    },
                    cursorColor: primaryColor,
                    decoration: InputDecoration(
                      focusColor: primaryColor,
                      icon: Icon(
                        Icons.vpn_key,
                        color: primaryColor,
                      ),
                      hintText: "Enter Password",
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_formkey.currentState.validate()) {
                      register();
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 20, right: 20, top: 70),
                    padding: EdgeInsets.only(left: 20, right: 20),
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [(primaryColor), primaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(50),
                      color: accentColor,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 50,
                            color: accentColor),
                      ],
                    ),
                    child: Text(
                      "REGISTER",
                      style: TextStyle(color: accentColor),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("By Registering, you are agreeing to our "),
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Terms()));
                    },
                    child: Text(
                      "Terms and Conditions",
                      style: TextStyle(color: primaryColor),
                    )),
                Container(
                  margin: EdgeInsets.only(top: 12, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already Have An Account?  "),
                      GestureDetector(
                        child: Text(
                          "Login Now",
                          style: TextStyle(color: primaryColor),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          )));
  }
}
