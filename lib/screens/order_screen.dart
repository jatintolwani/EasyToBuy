import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/providers/orders_provider.dart';
import 'package:easytobuy/screens/mainProduct_screen.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class AdminOrder extends StatefulWidget {
  @override
  _AdminOrderState createState() => _AdminOrderState();
}

class _AdminOrderState extends State<AdminOrder> {
  var query;
  var isLoading = false;
  var qAvailable;

  var categoriesWithSize = ["Fashion", "Shoes"];
  getUser() {
    if (currentUser == admin) {
      query = FirebaseFirestore.instance
          .collection("Orders")
          .orderBy("timeStamp", descending: true)
          .snapshots();
    } else {
      query = FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection("Orders")
          .orderBy("timeStamp", descending: true)
          .snapshots();
    }
  }

  cancelOrder(cat, prodId, orderId, quantity, coins, total, credCoin) async {
    print(total);
    print(coins);
    Navigator.pop(context);
    // print(cat);
    // print(prodId);
    // print(quantity);
    var coinsAvailable = 0;
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .collection("Orders")
        .doc(orderId)
        .update({"isCanceled": true});
    await FirebaseFirestore.instance
        .collection("Orders")
        .doc(orderId)
        .update({"isCanceled": true});
    await FirebaseFirestore.instance
        .collection(cat)
        .doc(prodId)
        .get()
        .then((value) {
      qAvailable = value["qAvailable"];
    });
    await FirebaseFirestore.instance.collection(cat).doc(prodId).update({
      "qAvailable": qAvailable + quantity,
    });

    coinsAvailable = Provider.of<Orders>(context, listen: false).etbCoins;
    if (coins > 0) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .update({"etbCoins": (coinsAvailable - credCoin) + coins});

      Provider.of<Orders>(context, listen: false).getCoins();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("My Orders"),
      ),
      body: isLoading
          ? Loading()
          : StreamBuilder(
              stream: query,
              builder: (context, snap) => !snap.hasData
                  ? Loading()
                  : (snap.hasData && snap.data.docs.length == 0)
                      ? Center(
                          child: Text(
                          "No Orders Found",
                          style: TextStyle(fontSize: text_md),
                        ))
                      : ListView.builder(
                          itemCount: snap.data.docs.length,
                          itemBuilder: (context, index) {
                            print(snap.data.docs[index]["etbCoins"]);
                            return Stack(children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                child: GestureDetector(
                                  onDoubleTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => MainProduct(
                                                snap.data.docs[index]
                                                    ["productId"],
                                                snap.data.docs[index]
                                                    ["productName"],
                                                snap.data.docs[index]
                                                    ["productCategory"])));
                                  },
                                  child: Card(
                                    child: ExpansionTile(
                                      subtitle: Text(
                                        "ETB-" +
                                            snap.data.docs[index]["orderId"],
                                        style: TextStyle(
                                            fontSize: text_xsm,
                                            color: Colors.black),
                                      ),
                                      title: Text(
                                        snap.data.docs[index]["customerName"],
                                        style: TextStyle(
                                            fontSize: text_md,
                                            color: Colors.black),
                                      ),
                                      trailing: Text(
                                        snap.data.docs[index]["orderDate"],
                                        style: TextStyle(
                                            fontSize: text_md,
                                            color: Colors.black),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Product",
                                                style: TextStyle(
                                                    fontSize: text_md),
                                              ),
                                              Spacer(),
                                              Container(
                                                width: 150,
                                                child: Center(
                                                  child: Text(
                                                    snap.data.docs[index]
                                                        ["customerEmail"],
                                                    style: TextStyle(
                                                        fontSize: text_md),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Product",
                                                style: TextStyle(
                                                    fontSize: text_md),
                                              ),
                                              Spacer(),
                                              Container(
                                                width: 150,
                                                child: Center(
                                                  child: Text(
                                                    snap.data.docs[index]
                                                        ["productName"],
                                                    style: TextStyle(
                                                        fontSize: text_md),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Quantity",
                                                style: TextStyle(
                                                    fontSize: text_md),
                                              ),
                                              Spacer(),
                                              Text(
                                                snap
                                                    .data
                                                    .docs[index]
                                                        ["productQuantity"]
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: text_md),
                                              ),
                                            ],
                                          ),
                                        ),
                                        categoriesWithSize.contains(snap.data
                                                .docs[index]["productCategory"])
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Ideal For",
                                                      style: TextStyle(
                                                          fontSize: text_md),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      snap.data
                                                          .docs[index]["gender"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: text_md),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        categoriesWithSize.contains(snap.data
                                                .docs[index]["productCategory"])
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Size",
                                                      style: TextStyle(
                                                          fontSize: text_md),
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      snap.data
                                                          .docs[index]["size"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: text_md),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text("Regular Price",
                                                  style: TextStyle(
                                                      fontSize: text_md)),
                                              Spacer(),
                                              Text(
                                                "₹${snap.data.docs[index]["regularPrice"]}",
                                                style: TextStyle(
                                                    fontSize: text_md),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Our Price",
                                                style: TextStyle(
                                                    fontSize: text_md),
                                              ),
                                              Spacer(),
                                              Text(
                                                "₹${snap.data.docs[index]["ourPrice"]}",
                                                style: TextStyle(
                                                    fontSize: text_md),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Discount",
                                                style: TextStyle(
                                                    fontSize: text_md),
                                              ),
                                              Spacer(),
                                              Text(
                                                "- ₹${snap.data.docs[index]["productDiscount"]}",
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: text_md),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text("Coupon Applied",
                                                  style: TextStyle(
                                                      fontSize: text_md)),
                                              Spacer(),
                                              Text(
                                                snap.data.docs[index]
                                                    ["productCouponApplied"],
                                                style: TextStyle(
                                                    color: snap.data.docs[index]
                                                                [
                                                                "productCouponApplied"] ==
                                                            "None"
                                                        ? Colors.black
                                                        : Colors.green,
                                                    fontSize: text_md),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text("Coupon Discount (in %)",
                                                  style: TextStyle(
                                                      fontSize: text_md)),
                                              Spacer(),
                                              Text(
                                                snap.data.docs[index][
                                                            "productCouponApplied"] ==
                                                        "None"
                                                    ? "None"
                                                    : "- ${snap.data.docs[index]['productCouponDisc']}%",
                                                style: TextStyle(
                                                    color: snap.data.docs[index]
                                                                [
                                                                "productCouponApplied"] ==
                                                            "None"
                                                        ? Colors.black
                                                        : Colors.green,
                                                    fontSize: text_md),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text("Coupon Discount (in ₹)",
                                                  style: TextStyle(
                                                      fontSize: text_md)),
                                              Spacer(),
                                              Text(
                                                snap.data.docs[index][
                                                            "productCouponApplied"] ==
                                                        "None"
                                                    ? "None"
                                                    : "- ₹${snap.data.docs[index]['productCouponDiscInRupees']}",
                                                style: TextStyle(
                                                    color: snap.data.docs[index]
                                                                [
                                                                "productCouponApplied"] ==
                                                            "None"
                                                        ? Colors.black
                                                        : Colors.green,
                                                    fontSize: text_md),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text("Total Amount",
                                                  style: TextStyle(
                                                      fontSize: text_md)),
                                              Spacer(),
                                              snap.data.docs[index]
                                                          ["etbCoins"] >
                                                      0
                                                  ? Row(children: [
                                                      Text(
                                                        "₹${snap.data.docs[index]['totalAfterCoupon']} + ${snap.data.docs[index]["etbCoins"]}",
                                                        style: TextStyle(
                                                            color: snap.data.docs[
                                                                            index]
                                                                        [
                                                                        "productCouponApplied"] ==
                                                                    "None"
                                                                ? Colors.black
                                                                : Colors.green,
                                                            fontSize: text_md),
                                                      ),
                                                      Image.asset(
                                                        "lib/assets/images/coin.png",
                                                        height: 22,
                                                        width: 22,
                                                        fit: BoxFit.cover,
                                                      )
                                                    ])
                                                  : Text(
                                                      "₹${snap.data.docs[index]['totalAfterCoupon']}",
                                                      style: TextStyle(
                                                          fontSize: text_md),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text("Payment Mode",
                                                  style: TextStyle(
                                                      fontSize: text_md)),
                                              Spacer(),
                                              Text(
                                                snap.data.docs[index]
                                                    ['paymentMode'],
                                                style: TextStyle(
                                                    fontSize: text_md),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text("Shipping Address",
                                                  style: TextStyle(
                                                      fontSize: text_md)),
                                              Spacer(),
                                              Container(
                                                width: 150,
                                                child: Center(
                                                  child: Text(
                                                    snap.data.docs[index]
                                                        ['shippingAddress'],
                                                    style: TextStyle(
                                                        fontSize: text_md),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text("Landmark",
                                                  style: TextStyle(
                                                      fontSize: text_md)),
                                              Spacer(),
                                              Container(
                                                width: 150,
                                                child: Center(
                                                  child: Text(
                                                    snap.data.docs[index]
                                                        ['landmark'],
                                                    style: TextStyle(
                                                        fontSize: text_md),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              Text("City, State, Country",
                                                  style: TextStyle(
                                                      fontSize: text_md)),
                                              Spacer(),
                                              Container(
                                                width: 150,
                                                child: Center(
                                                  child: Text(
                                                    "${snap.data.docs[index]['city']}, \n${snap.data.docs[index]['state']}, \n${snap.data.docs[index]['country']}",
                                                    style: TextStyle(
                                                        fontSize: text_md),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        currentUser == admin
                                            ? Container()
                                            : Center(
                                                child: FlatButton(
                                                    onPressed: () {
                                                      snap.data.docs[index][
                                                                  "isCanceled"] ==
                                                              true
                                                          ? null
                                                          : showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  content: Text(
                                                                      "Cancel Order?"),
                                                                  actions: [
                                                                    FlatButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "No",
                                                                          style:
                                                                              TextStyle(color: primaryColor),
                                                                        )),
                                                                    FlatButton(
                                                                        onPressed:
                                                                            () {
                                                                          if (snap.data.docs[index]["productCouponApplied"] ==
                                                                              "None") {
                                                                            cancelOrder(
                                                                                snap.data.docs[index]["productCategory"],
                                                                                snap.data.docs[index]["productId"],
                                                                                snap.data.docs[index]["orderId"],
                                                                                snap.data.docs[index]["productQuantity"],
                                                                                snap.data.docs[index]["etbCoins"],
                                                                                snap.data.docs[index]["ourPrice"],
                                                                                snap.data.docs[index]["etbCoinsCredited"]);
                                                                          } else {
                                                                            cancelOrder(
                                                                                snap.data.docs[index]["productCategory"],
                                                                                snap.data.docs[index]["productId"],
                                                                                snap.data.docs[index]["orderId"],
                                                                                snap.data.docs[index]["productQuantity"],
                                                                                snap.data.docs[index]["etbCoins"],
                                                                                snap.data.docs[index]["ourPrice"] - snap.data.docs[index]["productCouponDiscInRupees"],
                                                                                snap.data.docs[index]["etbCoinsCredited"]);
                                                                          }
                                                                        },
                                                                        child: Text(
                                                                            "Yes,Cancel",
                                                                            style:
                                                                                TextStyle(color: primaryColor)))
                                                                  ],
                                                                );
                                                              });
                                                    },
                                                    child: Text(
                                                      "Cancel Order",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: text_md),
                                                    )))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              snap.data.docs[index]["isCanceled"]
                                  ? IgnorePointer(
                                      ignoring: true,
                                      child: Container(
                                        margin: EdgeInsets.all(2),
                                        height: 80,
                                        color: Colors.red.withOpacity(0.3),
                                        child: Center(
                                          child: Text(
                                            "Cancelled",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: text_md,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container()
                            ]);
                          }),
            ),
    );
  }
}
