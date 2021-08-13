import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/models/shippingAddress.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShippingForm extends StatefulWidget {
  @override
  _ShippingFormState createState() => _ShippingFormState();
}

class _ShippingFormState extends State<ShippingForm> {
  String countryValue;

  String stateValue;

  String temp;

  String cityValue;

  List<ShippingAddress> shippingAddresses = [];

  var _nameCtrl = TextEditingController();

  var _phoneCtrl = TextEditingController();

  var _emailCtrl = TextEditingController();

  var _shippingAdd = TextEditingController();

  var _landmarkCtrl = TextEditingController();

  var loading = false;

  final _formKey = GlobalKey<FormState>();
  FToast fToast;

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  toast(text) {
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
      child: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(
        seconds: 1,
      ),
    );
  }

  _storedAddress() async {
    setState(() {
      loading = true;
    });
    try {
      var id = FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection('Shipping Address')
          .doc()
          .id;
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection('Shipping Address')
          .doc(id)
          .set({
        'name': _nameCtrl.text.trim(),
        'number': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'shippingAddress': _shippingAdd.text.trim(),
        'landmark': _landmarkCtrl.text.trim(),
        'country': countryValue.toString().substring(8),
        'state': stateValue.toString().trim(),
        'city': cityValue.toString().trim(),
        'shippingAddressID': id
      });
    } catch (err) {
      print(err);
      setState(() {
        loading = false;
      });
    }
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _shippingAdd.clear();
    _landmarkCtrl.clear();
    setState(() {
      loading = false;
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          color: primaryColor,
          onPressed: loading
              ? null
              : () => {
                    if (_formKey.currentState.validate())
                      {
                        print(countryValue),
                        if (countryValue == null ||
                            cityValue == null ||
                            stateValue == null)
                          {toast("Please fill all the Details.")}
                        else
                          {
                            _storedAddress(),
                          }
                      }
                  },
          child: Text(
            "Continue",
            style: TextStyle(color: Colors.white, fontSize: text_md),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Add Shipping Address"),
      ),
      body: loading
          ? Loading()
          : Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _nameCtrl,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value.length < 4) {
                              return "Name must be more than 4 Charaters";
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: "Full Name",
                            hintText: "Full Name",
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(0),
                              borderSide: new BorderSide(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value.length != 10) {
                              return "Mobile Number must be 10 digit";
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: "Phone",
                            hintText: "Phone Number",
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(0),
                              borderSide: new BorderSide(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Enter Email";
                            } else if (!isEmail(value)) {
                              return "Email not formatted properly";
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: "Email",
                            hintText: "Email",
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(0),
                              borderSide: new BorderSide(),
                            ),
                          ),
                        ),
                        SelectState(
                          onCountryChanged: (value) {
                            setState(() {
                              countryValue = value;
                              print(value);
                            });
                          },
                          onStateChanged: (value) {
                            setState(() {
                              stateValue = value;
                              print(value);
                            });
                          },
                          onCityChanged: (value) {
                            setState(() {
                              cityValue = value;
                              print(value);
                            });
                          },
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: _shippingAdd,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Address';
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: "Shipping Address",
                            hintText: "House No, Building Name",
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(0),
                              borderSide: new BorderSide(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          controller: _landmarkCtrl,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Landmark';
                            }
                            return null;
                          },
                          decoration: new InputDecoration(
                            labelText: "Landmark",
                            hintText: "School, Garden, Public Place",
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(0),
                              borderSide: new BorderSide(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
