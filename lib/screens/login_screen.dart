import 'package:easytobuy/screens/reset.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main_config.dart';
import './signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var forgotPasswordController = TextEditingController();
  final __formkey = GlobalKey<FormState>();
  var email = TextEditingController();
  var password = TextEditingController();
  var show = true;
  bool isLoading = false;

  loginscreen() async {
    if (__formkey.currentState.validate()) {
      __formkey.currentState.save();
      try {
        setState(() {
          isLoading = true;
        });
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.text.trim(), password: password.text);
        print(FirebaseAuth.instance.currentUser.uid);
        currentUser = FirebaseAuth.instance.currentUser.uid;
        setState(() {
          isLoading = false;
        });
      } catch (err) {
        print(err);
        setState(() {
          isLoading = false;
        });
        fToast.removeQueuedCustomToasts();
        fToast.showToast(
          child: Text(
            err.toString(),
            style: TextStyle(fontSize: 16),
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(
            seconds: 3,
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
            key: __formkey,
            child: Column(
              children: [
                Container(
                  height: 300,
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
                          "Login",
                          style:
                              TextStyle(fontSize: 20, color: Color(0xffd8e3e7)),
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
                    color: Color(0xffd8e3e7),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 50,
                          color: Color(0xffd8e3e7)),
                    ],
                  ),
                  child: TextFormField(
                    controller: email,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Enter Email";
                      } else if (!isEmail(value)) {
                        return "Email not Formatted Properly";
                      }
                      return null;
                    },
                    cursorColor: primaryColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: primaryColor,
                      ),
                      hintText: "Enter Email",
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
                    color: Color(0xffd8e3e7),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 20),
                          blurRadius: 100,
                          color: Color(0xffd8e3e7)),
                    ],
                  ),
                  child: TextFormField(
                    obscureText: show ? false : true,
                    controller: password,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Enter Password";
                      }
                      return null;
                    },
                    cursorColor: primaryColor,
                    decoration: InputDecoration(
                      suffixIcon: show
                          ? IconButton(
                              icon: Icon(Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  show = !show;
                                });
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  show = !show;
                                });
                              },
                            ),
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
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ResetScreen()));
                    },
                    child: Text("Forget Password?"),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    loginscreen();
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
                      color: Color(0xffd8e3e7),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 50,
                            color: Color(0xffd8e3e7)),
                      ],
                    ),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(color: Color(0xffd8e3e7)),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't Have An Account?  "),
                      GestureDetector(
                        child: Text(
                          "Register Now",
                          style: TextStyle(color: primaryColor),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ));
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
