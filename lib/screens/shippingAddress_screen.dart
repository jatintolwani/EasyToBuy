import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/models/shippingAddress.dart';
import 'package:easytobuy/providers/orders_provider.dart';
import 'package:easytobuy/screens/payment_screen.dart';
import 'package:easytobuy/widgets/cacheImage.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:easytobuy/widgets/shippingForm.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  String countryValue;
  String stateValue;
  String temp;
  String cityValue;
  List<ShippingAddress> shippingAddresses = [];
  var loading = false;

  var selectedAddress = "";

  OrderItems productData;
  List couponData;

  var payUsingETBCoins = true;
  var coins;
  var hasBalance = true;
  var coinsToUse = 0;

  var total = 0;
  checkCoins() {
    coins = Provider.of<Orders>(context, listen: false).etbCoins;
    print(coins);
    if (coins > 0) {
      hasBalance = true;
    } else {
      hasBalance = false;
    }
    print(hasBalance);
  }

  getCoinsToUse(total) {
    var normalReduction = (total * 2 / 100).floor();
    if (coins >= normalReduction) {
      coinsToUse = normalReduction;
    } else {
      coinsToUse = coins;
    }
    return coinsToUse;
  }

  fetchShippingAddress() async {
    setState(() {
      loading = true;
    });
    shippingAddresses.clear();
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection("Shipping Address")
          .get()
          .then((value) {
        value.docs.forEach((element) {
          shippingAddresses.add(ShippingAddress(
            element["shippingAddressID"],
            element["name"],
            element["number"],
            element["email"],
            element["country"],
            element["state"],
            element["city"],
            element["landmark"],
            element["shippingAddress"],
          ));
        });
        selectedAddress = shippingAddresses[0].id;
      });
    } catch (err) {
      print(err);
      setState(() {
        loading = false;
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkCoins();
    fetchShippingAddress();
  }

  @override
  Widget build(BuildContext context) {
    productData = Provider.of<Orders>(context, listen: false).retrieveData();
    couponData = Provider.of<Orders>(context, listen: false).retrieveCoupon();
    print(couponData);
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          color: primaryColor,
          onPressed: loading
              ? null
              : shippingAddresses.isEmpty
                  ? () => Fluttertoast.showToast(
                      msg: "Please Select Shipping Address")
                  : () {
                      var index = shippingAddresses.indexWhere(
                          (element) => element.id == selectedAddress);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Payment(
                              shippingAddresses[index].name,
                              shippingAddresses[index].number,
                              shippingAddresses[index].email,
                              shippingAddresses[index].shippingAddress,
                              shippingAddresses[index].landmark,
                              shippingAddresses[index].city,
                              shippingAddresses[index].state,
                              shippingAddresses[index].country,
                              coinsToUse,
                              payUsingETBCoins)));
                    },
          child: Text(
            "Continue",
            style: TextStyle(color: Colors.white, fontSize: text_md),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Order Summary",
          style: TextStyle(fontSize: text_md),
        ),
        backgroundColor: primaryColor,
      ),
      body: loading
          ? Loading()
          : SingleChildScrollView(
              child: Column(children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: productData.cartItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        child: Container(
                            padding: EdgeInsets.all(15),
                            // height: 200,
                            child: InkWell(
                              onTap: () {},
                              child: Column(children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            productData
                                                .cartItems[index].productName,
                                            overflow: productData
                                                        .cartItems[index]
                                                        .productName
                                                        .length >
                                                    45
                                                ? TextOverflow.ellipsis
                                                : null,
                                            style: TextStyle(
                                                fontSize: text_md,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Quantity - ${productData.cartItems[index].productQuantity}",
                                            style: TextStyle(
                                                fontSize: text_sm,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Category - ${productData.cartItems[index].productCat}",
                                            style: TextStyle(
                                                fontSize: text_sm,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          RichText(
                                              text: TextSpan(
                                                  text:
                                                      "₹${productData.cartItems[index].productTotalPrice}  ",
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: productData
                                                            .cartItems[index]
                                                            .productRegTotalPrice
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: text_xl,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough)),
                                                    TextSpan(
                                                        text:
                                                            "\n₹${productData.cartItems[index].productTotalDiscount} off",
                                                        style: TextStyle(
                                                          fontSize: text_md,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.green[700],
                                                        ))
                                                  ],
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: text_xl))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      height: 130,
                                      width: 130,
                                      child: CacheImage(productData
                                          .cartItems[index].productImg),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ]),
                            )),
                      );
                    }),
                couponData[0].couponName == "None"
                    ? Card(
                        elevation: 5,
                        child: Container(
                          height: hasBalance ? 130 : 60,
                          child: Column(children: [
                            hasBalance
                                ? ListTile(
                                    leading: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("Pay using ETB Coins"),
                                          Switch(
                                            activeColor: primaryColor,
                                            onChanged: (val) {
                                              setState(() {
                                                payUsingETBCoins =
                                                    !payUsingETBCoins;
                                              });
                                            },
                                            value: payUsingETBCoins,
                                          ),
                                        ]),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "- ${getCoinsToUse(couponData[1])}",
                                            style: TextStyle(
                                                color: payUsingETBCoins
                                                    ? coinColor
                                                    : Colors.grey),
                                          ),
                                          Image.asset(
                                            "lib/assets/images/coin.png",
                                            height: 22,
                                            width: 22,
                                            fit: BoxFit.cover,
                                          )
                                        ]),
                                  )
                                : Container(),
                            ListTile(
                              leading: Text(
                                "Total Amount to Pay",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                payUsingETBCoins
                                    ? "₹${couponData[1] - coinsToUse}"
                                    : "₹${couponData[1]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      )
                    : Card(
                        elevation: 5,
                        child: Container(
                          height: hasBalance ? 240 : 190,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Text("Coupon Applied"),
                                trailing: Text(
                                  "${couponData[0].couponName}",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              ListTile(
                                leading: Text(
                                  "Total Coupon Discount",
                                ),
                                trailing: Text(
                                  "- ₹${couponData[0].couponDiscInRupee}",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              hasBalance
                                  ? ListTile(
                                      leading: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Pay using ETB Coins"),
                                            Switch(
                                              activeColor: primaryColor,
                                              onChanged: (val) {
                                                setState(() {
                                                  payUsingETBCoins =
                                                      !payUsingETBCoins;
                                                });
                                              },
                                              value: payUsingETBCoins,
                                            ),
                                          ]),
                                      trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "- ${getCoinsToUse(couponData[1])}",
                                              style: TextStyle(
                                                  color: payUsingETBCoins
                                                      ? coinColor
                                                      : Colors.grey),
                                            ),
                                            Image.asset(
                                              "lib/assets/images/coin.png",
                                              height: 20,
                                              width: 20,
                                              fit: BoxFit.cover,
                                            )
                                          ]),
                                    )
                                  : Container(),
                              Divider(
                                color: Colors.black,
                              ),
                              ListTile(
                                leading: Text(
                                  "Total Amount to Pay",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  payUsingETBCoins
                                      ? "₹${couponData[1] - coinsToUse}"
                                      : "₹${couponData[1]}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                Column(children: [
                  shippingAddresses.length > 0
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Select Shipping Address",
                            style: TextStyle(
                                fontSize: text_md, fontWeight: FontWeight.bold),
                          ),
                        )
                      : Container(),
                  ListView.builder(
                      itemCount: shippingAddresses.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Card(
                            elevation: 5,
                            child: Container(
                              padding: EdgeInsets.all(15),
                              // height: 180,
                              child: Column(children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Radio(
                                        value: shippingAddresses[index].id,
                                        groupValue: selectedAddress,
                                        onChanged: (val) {
                                          print(val);
                                          setState(() {
                                            selectedAddress = val.toString();
                                          });
                                        }),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            shippingAddresses[index]
                                                .shippingAddress,
                                            overflow: shippingAddresses[index]
                                                        .shippingAddress
                                                        .length >
                                                    45
                                                ? TextOverflow.ellipsis
                                                : null,
                                            style: TextStyle(
                                                fontSize: text_md,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            shippingAddresses[index].landmark,
                                            overflow: shippingAddresses[index]
                                                        .landmark
                                                        .length >
                                                    45
                                                ? TextOverflow.ellipsis
                                                : null,
                                            style: TextStyle(
                                                fontSize: text_md,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            shippingAddresses[index].name,
                                            style: TextStyle(
                                                fontSize: text_md,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          RichText(
                                              text: TextSpan(
                                                  text: shippingAddresses[index]
                                                      .city,
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text:
                                                            ", ${shippingAddresses[index].state}, ",
                                                        style: TextStyle(
                                                          fontSize: text_md,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                    TextSpan(
                                                        text: shippingAddresses[
                                                                index]
                                                            .country,
                                                        style: TextStyle(
                                                          fontSize: text_md,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ))
                                                  ],
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: text_md))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ]),
                            ),
                          )),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: RaisedButton(
                        color: primaryColor,
                        elevation: 0,
                        child: Text(
                          "Add Shipping Address",
                          style: TextStyle(
                            fontSize: text_md,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => ShippingForm()))
                              .then((value) {
                            fetchShippingAddress();
                          });
                        }),
                  ),
                ]),
              ]),
            ),
    );
  }
}
