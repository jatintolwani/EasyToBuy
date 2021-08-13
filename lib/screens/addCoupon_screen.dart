import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddCoupon extends StatefulWidget {
  @override
  _AddCouponState createState() => _AddCouponState();
}

class _AddCouponState extends State<AddCoupon> {
  final __formkey = GlobalKey<FormState>();

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

  FToast fToast;

  var categories = [
    "Used Mobiles",
    "Global Mobiles",
    "New Mobiles",
    "Mobile Accessories",
    "Add Ons",
    "Fashion",
    "Shoes",
    "Watches",
    "Laptops & Accessories",
    "Offers",
    "Coins"
  ];
  var dropDown = "Used Mobiles";
  var isLoading = false;
  var cName = TextEditingController();
  var cDisc = TextEditingController();
  var cDesc = TextEditingController();
  Widget box() {
    return SizedBox(
      height: 20,
    );
  }

  save() async {
    if (__formkey.currentState.validate()) {
      __formkey.currentState.save();
      setState(() {
        isLoading = true;
      });
      try {
        var id = FirebaseFirestore.instance
            .collection("Coupons")
            .doc(dropDown)
            .collection(dropDown)
            .doc()
            .id;
        dropDown == "Coins"
            ? await FirebaseFirestore.instance
                .collection("Coupons")
                .doc(dropDown)
                .collection(dropDown)
                .doc(id)
                .set({
                "id": id,
                "couponCat": dropDown,
                "couponDescription": cDesc.text,
                "coinsToAdd": int.parse(cDisc.text),
                "couponName": cName.text
              })
            : await FirebaseFirestore.instance
                .collection("Coupons")
                .doc(dropDown)
                .collection(dropDown)
                .doc(id)
                .set({
                "id": id,
                "couponCat": dropDown,
                "couponDescription": cDesc.text,
                "couponDiscount": int.parse(cDisc.text),
                "couponName": cName.text
              });
        cDesc.clear();
        cName.clear();
        cDisc.clear();
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        print(err);
      }
    }
    setState(() {
      isLoading = false;
    });
    toast("Coupon Added");
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
        title: Text("Add Coupon"),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                save();
              })
        ],
      ),
      body: isLoading
          ? Loading()
          : SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: __formkey,
                child: Column(
                  children: [
                    TextFormField(
                        controller: cName,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 1),
                          ),
                          hintText: "Coupon Name",
                        ),
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Enter a Valid Name";
                          }
                          return null;
                        }),
                    box(),
                    TextFormField(
                        controller: cDesc,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 1),
                          ),
                          hintText: "Coupon Description",
                        ),
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Enter a Valid Description";
                          } else if (val.length < 10) {
                            return "Enter a Description of Atleast 10 characters";
                          }
                          return null;
                        }),
                    box(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Category",
                          style: TextStyle(fontSize: text_md),
                        ),
                        DropdownButton(
                          value: dropDown,
                          onChanged: (newValue) {
                            setState(() {
                              dropDown = newValue;
                            });
                          },
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              child: Text(
                                cat,
                                style: TextStyle(fontSize: text_md),
                              ),
                              value: cat,
                            );
                          }).toList(),
                        ),
                        box(),
                      ],
                    ),
                    TextFormField(
                        controller: cDisc,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 1),
                          ),
                          hintText: dropDown == "Coins"
                              ? "Coins to Add in Wallet"
                              : "Coupon Discount (in %)",
                        ),
                        validator: (val) {
                          if (val.isEmpty || int.parse(val) == 0) {
                            return dropDown == "Coins"
                                ? "Enter Valid Coins"
                                : "Enter a Valid Discount";
                          }
                          return null;
                        }),
                  ],
                ),
              ),
            )),
    );
  }
}
