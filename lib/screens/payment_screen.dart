import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/providers/orders_provider.dart';
import 'package:easytobuy/screens/orderConfirm.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Payment extends StatefulWidget {
  var name;
  var number;
  var email;
  var shippingAddress;
  var landmark;
  var city;
  var state;
  var country;
  var coins;
  var payUsingCoins;
  Payment(
      this.name,
      this.number,
      this.email,
      this.shippingAddress,
      this.landmark,
      this.city,
      this.state,
      this.country,
      this.coins,
      this.payUsingCoins);
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Razorpay razorpay;
  TextEditingController textEditingController = new TextEditingController();
  FToast fToast;

  var selectedMode = "COD";
  var productData;
  OrderItems orders;
  List usedCoupons;

  var outOfStock = false;
  List qAvailable = [];
  var isLoading = false;

  var categoriesWithSize = ["Fashion", "Shoes"];
  var userCoinsAvailable = 0;

  var success = false;
  getUsedCoupons() async {
    usedCoupons =
        await Provider.of<Orders>(context, listen: false).retrieveUsedCoupon();
  }

  @override
  void initState() {
    super.initState();
    productData = Provider.of<Orders>(context, listen: false).retrieveCoupon();
    orders = Provider.of<Orders>(context, listen: false).retrieveData();
    userCoinsAvailable = Provider.of<Orders>(context, listen: false).etbCoins;
    getUsedCoupons();
    fToast = FToast();
    fToast.init(context);
    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

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

  getCoinsForDiscount(i) {
    var coins = 0;
    if (i == index) {
      coins = widget.coins;
    } else {
      coins = 0;
    }
    return coins;
  }

  var maxPrice = 0;
  var index = 0;
  addOrder() async {
    // setState(() {
    //   isLoading = true;
    // });

    for (var i = 0; i < orders.cartItems.length; i++) {
      if (orders.cartItems[i].productOurPrice > maxPrice) {
        maxPrice = orders.cartItems[i].productOurPrice;
        index = i;
      }
    }

    print("ADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
    for (var i = 0; i < orders.cartItems.length; i++) {
      try {
        var orderId = FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser)
            .collection("Orders")
            .doc()
            .id;

        //Order Added to User
        if (categoriesWithSize.contains(orders.cartItems[i].productCat)) {
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser)
              .collection("Orders")
              .doc(orderId)
              .set({
            "orderId": orderId,
            "productId": orders.cartItems[i].productID,
            "gender": orders.cartItems[i].gender,
            "size": orders.cartItems[i].clothSize,
            "customerName": widget.name,
            "customerContact": widget.number,
            "customerEmail": widget.email,
            "productName": orders.cartItems[i].productName,
            "productCategory": orders.cartItems[i].productCat,
            "productQuantity": orders.cartItems[i].productQuantity,
            "regularPrice": orders.cartItems[i].productRegTotalPrice,
            "ourPrice": orders.cartItems[i].productTotalPrice,
            "productDiscount": orders.cartItems[i].productTotalDiscount,
            "productCouponApplied":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? productData[0].couponName
                    : "None",
            "productCouponDisc":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? productData[0].couponDiscInPercentage
                    : "None",
            "productCouponDiscInRupees":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice *
                        productData[0].couponDiscInPercentage /
                        100
                    : "None",
            "etbCoinsCredited":
                i == index ? (productData[1] * 1 / 100).floor() : 0,
            "etbCoins": widget.payUsingCoins
                ? i == index
                    ? (widget.coins).floor()
                    : 0
                : 0,
            "totalAfterCoupon": widget.payUsingCoins
                ? productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice -
                        ((orders.cartItems[i].productTotalPrice *
                                productData[0].couponDiscInPercentage /
                                100) +
                            getCoinsForDiscount(i))
                    : orders.cartItems[i].productTotalPrice -
                        getCoinsForDiscount(i)
                : productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice -
                        (orders.cartItems[i].productTotalPrice *
                            productData[0].couponDiscInPercentage /
                            100)
                    : orders.cartItems[i].productTotalPrice,
            "paymentMode": selectedMode,
            "shippingAddress": widget.shippingAddress,
            "landmark": widget.landmark,
            "city": widget.city,
            "state": widget.state,
            "country": widget.country,
            "orderDate": DateFormat.yMMMd().format(new DateTime.now()),
            "timeStamp": Timestamp.now(),
            "isCanceled": false
          });

          //Order added to Admin
          await FirebaseFirestore.instance
              .collection("Orders")
              .doc(orderId)
              .set({
            "orderId": orderId,
            "productId": orders.cartItems[i].productID,
            "gender": orders.cartItems[i].gender,
            "size": orders.cartItems[i].clothSize,
            "customerName": widget.name,
            "customerContact": widget.number,
            "customerEmail": widget.email,
            "productName": orders.cartItems[i].productName,
            "productCategory": orders.cartItems[i].productCat,
            "productQuantity": orders.cartItems[i].productQuantity,
            "regularPrice": orders.cartItems[i].productRegTotalPrice,
            "ourPrice": orders.cartItems[i].productTotalPrice,
            "productDiscount": orders.cartItems[i].productTotalDiscount,
            "productCouponApplied":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? productData[0].couponName
                    : "None",
            "productCouponDisc":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? productData[0].couponDiscInPercentage
                    : "None",
            "productCouponDiscInRupees":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice *
                        productData[0].couponDiscInPercentage /
                        100
                    : "None",
            "etbCoinsCredited":
                i == index ? (productData[1] * 1 / 100).floor() : 0,
            "etbCoins": widget.payUsingCoins
                ? i == index
                    ? (widget.coins).floor()
                    : 0
                : 0,
            "totalAfterCoupon": widget.payUsingCoins
                ? productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice -
                        ((orders.cartItems[i].productTotalPrice *
                                productData[0].couponDiscInPercentage /
                                100) +
                            getCoinsForDiscount(i))
                    : orders.cartItems[i].productTotalPrice -
                        getCoinsForDiscount(i)
                : productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice -
                        (orders.cartItems[i].productTotalPrice *
                            productData[0].couponDiscInPercentage /
                            100)
                    : orders.cartItems[i].productTotalPrice,
            "paymentMode": selectedMode,
            "shippingAddress": widget.shippingAddress,
            "landmark": widget.landmark,
            "city": widget.city,
            "state": widget.state,
            "country": widget.country,
            "orderDate": DateFormat.yMMMd().format(new DateTime.now()),
            "timeStamp": Timestamp.now(),
            "isCanceled": false
          });
        } else {
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser)
              .collection("Orders")
              .doc(orderId)
              .set({
            "orderId": orderId,
            "productId": orders.cartItems[i].productID,
            "customerName": widget.name,
            "customerContact": widget.number,
            "customerEmail": widget.email,
            "productName": orders.cartItems[i].productName,
            "productCategory": orders.cartItems[i].productCat,
            "productQuantity": orders.cartItems[i].productQuantity,
            "regularPrice": orders.cartItems[i].productRegTotalPrice,
            "ourPrice": orders.cartItems[i].productTotalPrice,
            "productDiscount": orders.cartItems[i].productTotalDiscount,
            "productCouponApplied":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? productData[0].couponName
                    : "None",
            "productCouponDisc":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? productData[0].couponDiscInPercentage
                    : "None",
            "productCouponDiscInRupees":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice *
                        productData[0].couponDiscInPercentage /
                        100
                    : "None",
            "etbCoinsCredited":
                i == index ? (productData[1] * 1 / 100).floor() : 0,
            "etbCoins": widget.payUsingCoins
                ? i == index
                    ? (widget.coins).floor()
                    : 0
                : 0,
            "totalAfterCoupon": widget.payUsingCoins
                ? productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice -
                        ((orders.cartItems[i].productTotalPrice *
                                productData[0].couponDiscInPercentage /
                                100) +
                            getCoinsForDiscount(i))
                    : orders.cartItems[i].productTotalPrice -
                        getCoinsForDiscount(i)
                : productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice -
                        (orders.cartItems[i].productTotalPrice *
                            productData[0].couponDiscInPercentage /
                            100)
                    : orders.cartItems[i].productTotalPrice,
            "paymentMode": selectedMode,
            "shippingAddress": widget.shippingAddress,
            "landmark": widget.landmark,
            "city": widget.city,
            "state": widget.state,
            "country": widget.country,
            "orderDate": DateFormat.yMMMd().format(new DateTime.now()),
            "timeStamp": Timestamp.now(),
            "isCanceled": false
          });

          //Order added to Admin
          await FirebaseFirestore.instance
              .collection("Orders")
              .doc(orderId)
              .set({
            "orderId": orderId,
            "productId": orders.cartItems[i].productID,
            "customerName": widget.name,
            "customerContact": widget.number,
            "customerEmail": widget.email,
            "productName": orders.cartItems[i].productName,
            "productCategory": orders.cartItems[i].productCat,
            "productQuantity": orders.cartItems[i].productQuantity,
            "regularPrice": orders.cartItems[i].productRegTotalPrice,
            "ourPrice": orders.cartItems[i].productTotalPrice,
            "productDiscount": orders.cartItems[i].productTotalDiscount,
            "productCouponApplied":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? productData[0].couponName
                    : "None",
            "productCouponDisc":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? productData[0].couponDiscInPercentage
                    : "None",
            "productCouponDiscInRupees":
                productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice *
                        productData[0].couponDiscInPercentage /
                        100
                    : "None",
            "etbCoinsCredited":
                i == index ? (productData[1] * 1 / 100).floor() : 0,
            "etbCoins": widget.payUsingCoins
                ? i == index
                    ? (widget.coins).floor()
                    : 0
                : 0,
            "totalAfterCoupon": widget.payUsingCoins
                ? productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice -
                        ((orders.cartItems[i].productTotalPrice *
                                productData[0].couponDiscInPercentage /
                                100) +
                            getCoinsForDiscount(i))
                    : orders.cartItems[i].productTotalPrice -
                        getCoinsForDiscount(i)
                : productData[0].couponCat == orders.cartItems[i].productCat
                    ? orders.cartItems[i].productTotalPrice -
                        (orders.cartItems[i].productTotalPrice *
                            productData[0].couponDiscInPercentage /
                            100)
                    : orders.cartItems[i].productTotalPrice,
            "paymentMode": selectedMode,
            "shippingAddress": widget.shippingAddress,
            "landmark": widget.landmark,
            "city": widget.city,
            "state": widget.state,
            "country": widget.country,
            "orderDate": DateFormat.yMMMd().format(new DateTime.now()),
            "timeStamp": Timestamp.now(),
            "isCanceled": false
          });
        }

        //

      } catch (err) {
        print(err);
        setState(() {
          isLoading = false;
        });
        toast("An Error Occured");
        // toast(err.toString());
      }
    }
    await emptycart();
    await reduceQuantity();
    await balanceCoins(productData[1]);
    await expireCoupon();
    print(
        "ADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD EXITTTTTTTTTTTTTTTTTTTTTTT");
    setState(() {
      isLoading = false;
    });
  }

  balanceCoins(totalAmount) async {
    print("total AMMM");
    print(totalAmount);
    print(userCoinsAvailable);
    print(widget.coins);
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .update({
        "etbCoins": widget.payUsingCoins
            ? userCoinsAvailable +
                (totalAmount * 1 / 100).floor() -
                widget.coins
            : userCoinsAvailable + (totalAmount * 1 / 100).floor(),
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      print(err);
    }
    await Provider.of<Orders>(context, listen: false).getCoins();
  }

  reduceQuantity() async {
    for (var i = 0; i < orders.cartItems.length; i++) {
      try {
        await FirebaseFirestore.instance
            .collection(orders.cartItems[i].productCat)
            .doc(orders.cartItems[i].productID)
            .update({
          "qAvailable": qAvailable[i] - orders.cartItems[i].productQuantity
        });
      } catch (err) {
        print(err);
        setState(() {
          isLoading = false;
        });
        toast("An Error Occured");
      }
    }
  }

  emptycart() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection("Cart")
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
      toast("An Error Occured");
    }
  }

  expireCoupon() async {
    if (productData[0].couponName != "None") {
      usedCoupons.add(productData[0].couponName);
      try {
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser)
            .update({
          "usedCoupons": usedCoupons,
        });
      } catch (err) {
        print(err);
        setState(() {
          isLoading = false;
        });
        toast("An Error Occured");
      }
    }
  }

  checkQuantity() async {
    qAvailable.clear();
    print("object");
    setState(() {
      isLoading = true;
    });
    for (var i = 0; i < orders.cartItems.length; i++) {
      try {
        await FirebaseFirestore.instance
            .collection(orders.cartItems[i].productCat)
            .doc(orders.cartItems[i].productID)
            .get()
            .then((value) {
          qAvailable.add(value["qAvailable"]);
          print(value["qAvailable"]);
          print(qAvailable);
        });
      } catch (err) {
        print(err);
        setState(() {
          isLoading = false;
        });
        toast("An Error Occured");
      }
      if (qAvailable[i] < orders.cartItems[i].productQuantity) {
        print(outOfStock);
        outOfStock = true;
        print(outOfStock);
        toast("An Error Occured, Please try Again");
        Navigator.popUntil(
            context, ModalRoute.withName(Navigator.defaultRouteName));
        break;
      }
    }
    // setState(() {
    //   isLoading = false;
    // });
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_6CEIlay11ZlEvT",
      "amount": widget.payUsingCoins
          ? (double.parse(productData[1].toString()) * 100) - widget.coins * 100
          : (double.parse(productData[1].toString()) * 100),
      "name": "Easy To Buy",
      // 'description': 'Fine T-Shirt',
      // "prefill": {"contact": "8200464922", "email": "dev@dev.com"},
      "external": {
        "wallets": ["paytm"]
      }
    };
    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: "Success:Payment Completed");
    success = true;
    print("SUCCCC");
    print(success);
    if (success) {
      print("AFTER SUCCCCCCCCCC");
      await addOrder();
      Navigator.popUntil(
          context, ModalRoute.withName(Navigator.defaultRouteName));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OrderConfirmPage((productData[1] * 1 / 100).floor())));
    }
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Error:Payment Not Completed", toastLength: Toast.LENGTH_SHORT);
    success = false;
    setState(() {
      isLoading = false;
    });
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName,
        toastLength: Toast.LENGTH_SHORT);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (isLoading) {
          return Future<bool>.value(false);
        } else {
          return Future<bool>.value(true);
        }
      },
      child: Scaffold(
          bottomNavigationBar: Row(children: [
            Container(
              width: MediaQuery.of(context).size.width * .5,
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.money_sharp,
                    size: 30,
                  ),
                ),
                subtitle: widget.payUsingCoins
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(widget.coins > 0 ? "${widget.coins}" : "",
                            style: TextStyle(
                                fontSize: text_md,
                                fontWeight: FontWeight.bold)),
                        Image.asset(
                          "lib/assets/images/coin.png",
                          height: 22,
                          width: 22,
                          fit: BoxFit.cover,
                        )
                      ])
                    : null,
                title: widget.payUsingCoins
                    ? Text(
                        widget.coins > 0
                            ? "₹${productData[1].floor() - widget.coins} +"
                            : "₹${productData[1]}",
                        style: TextStyle(
                            fontSize: text_md, fontWeight: FontWeight.bold))
                    : Text("₹${productData[1]}",
                        style: TextStyle(
                            fontSize: text_md, fontWeight: FontWeight.bold)),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * .5,
              height: 60,
              child: RaisedButton(
                color: primaryColor,
                onPressed: isLoading
                    ? null
                    : selectedMode == "COD"
                        ? () async {
                            await checkQuantity();
                            if (outOfStock == false) {
                              await addOrder();
                              Navigator.popUntil(
                                  context,
                                  ModalRoute.withName(
                                      Navigator.defaultRouteName));
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderConfirmPage(
                                          (productData[1] * 1 / 100).floor())));
                            }
                          }
                        : () async {
                            await checkQuantity();
                            if (outOfStock == false) {
                              openCheckout();
                            }
                          },
                child: Text(
                  selectedMode == "COD" ? "Place Order" : "Continue",
                  style: TextStyle(color: Colors.white, fontSize: text_md),
                ),
              ),
            ),
          ]),
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: Text(
              "Payment",
              style: TextStyle(fontSize: text_md),
            ),
          ),
          body: isLoading
              ? Loading()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "Select Payment Mode",
                        style: TextStyle(
                            fontSize: text_md, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: Radio(
                          value: "COD",
                          groupValue: selectedMode,
                          onChanged: (val) {
                            print(val);
                            setState(() {
                              selectedMode = val;
                            });
                          }),
                      title: Text("Cash on Delivery (COD)"),
                    ),
                    ListTile(
                      leading: Radio(
                          value: "Online",
                          groupValue: selectedMode,
                          onChanged: (val) {
                            print(val);
                            setState(() {
                              selectedMode = val;
                            });
                          }),
                      title: Text("Online Transaction"),
                      subtitle: Text(
                          "(Card, UPI, NetBanking and many other options)"),
                    ),
                  ],
                )),
    );
  }
}
