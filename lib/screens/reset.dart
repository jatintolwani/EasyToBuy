import 'package:easytobuy/main_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetScreen extends StatefulWidget {
  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  String _email;
  final auth = FirebaseAuth.instance;
  FToast fToast;

  toast(text) {
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(
        seconds: 1,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Reset Password'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: 'Email'),
              onChanged: (value) {
                setState(() {
                  _email = value.trim();
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RaisedButton(
                child: Text(
                  'Send Request',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  try {
                    await auth.sendPasswordResetEmail(email: _email);
                    toast("Mail sent, please check your mail box");
                    Navigator.of(context).pop();
                  } catch (err) {
                    print("catchhh");
                    print(err);
                    toast(err.toString());
                  }
                },
                color: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
