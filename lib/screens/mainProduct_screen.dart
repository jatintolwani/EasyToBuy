import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/providers/orders_provider.dart';
import 'package:easytobuy/screens/cart_screen.dart';
import 'package:easytobuy/screens/contact_screen.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:easytobuy/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:smart_select/smart_select.dart';

class MainProduct extends StatefulWidget {
  var prodId;
  var prodName;
  var cat;

  MainProduct(this.prodId, this.prodName, this.cat);
  @override
  _MainProductState createState() => _MainProductState();
}

class _MainProductState extends State<MainProduct> {
  var toggleOverflow = true;
  var ourPrice;
  var totalDiscount;
  var isLoading = false;
  var qInStock;

  var sizes = [S2Choice<String>(value: "", title: "")];
  var value = "";
  var selectedSize = "";

  var categoriesWithSize = ["Fashion", "Shoes"];

  var recents = [];
  var etbCoins = 0;

  var etbCoinsUsable = 0;

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

  convertSizes(sizestoConvert) {
    // print("convert");
    sizes.clear();
    for (var i = 0; i < sizestoConvert.length; i++) {
      sizes.add(
          S2Choice<String>(value: sizestoConvert[i], title: sizestoConvert[i]));
    }
    // value = sizestoConvert[0];
    return sizestoConvert;
  }

  FToast fToast;
  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    addToRecents();
  }

  getRecents() {
    recents = Provider.of<Orders>(context, listen: false).recents;
    // getCoins();
  }

  // getCoins() {
  //   etbCoins = Provider.of<Orders>(context, listen: false).etbCoins;
  //   // etbCoinsUsable = (etbCoins * 100 / 10).floor();
  // }

  addToRecents() async {
    getRecents();
    if (!recents.contains(widget.prodId)) {
      recents.add(widget.prodId);
      FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection("Recents")
          .doc(widget.prodId)
          .set({
        "prodId": widget.prodId,
        "cat": widget.cat,
        "when": DateTime.now()
      });
    } else {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection("Recents")
          .doc(widget.prodId)
          .update({"when": DateTime.now()});
    }
  }

  initToast() {
    fToast = FToast();
    fToast.init(context);
  }

  addToCart(quantity) async {
    if (categoriesWithSize.contains(widget.cat) && selectedSize == "") {
      toast("Select Size");
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        if (categoriesWithSize.contains(widget.cat)) {
          print(selectedSize);
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser)
              .collection("Cart")
              .doc(widget.prodId)
              .set({
            "productID": widget.prodId,
            "quantity": quantity,
            "category": widget.cat,
            "size": selectedSize,
          });
        } else {
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser)
              .collection("Cart")
              .doc(widget.prodId)
              .set({
            "productID": widget.prodId,
            "quantity": quantity,
            "category": widget.cat
          });
        }
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        print(err);
      }
      setState(() {
        isLoading = false;
      });
      toast("Product Added to Cart");
    }
  }

  showModal(ourPrice, totalDiscount, inStock) {
    var counter = 1;
    var cartDiscount = totalDiscount;
    var cartPrice = ourPrice;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 150,
              child: Column(children: [
                SizedBox(
                  height: 20,
                ),
                Divider(
                  color: Colors.black,
                  endIndent: MediaQuery.of(context).size.width * 0.45,
                  indent: MediaQuery.of(context).size.width * 0.45,
                  thickness: 2.5,
                ),
                ListTile(
                  leading: Text(
                    "Quantity",
                    style: TextStyle(
                      fontSize: text_md,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (counter > 1) counter--;
                              {
                                cartPrice = ourPrice * counter;
                                cartDiscount = totalDiscount * counter;
                              }
                            });
                          }),
                      Text(counter.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: text_md,
                          )),
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            print(counter);
                            setState(() {
                              if (counter < inStock) counter++;
                              {
                                counter == inStock
                                    ? toast(
                                        "You Cannot add more than $inStock Items")
                                    : null;
                                cartPrice = ourPrice * counter;
                                cartDiscount = totalDiscount * counter;
                                print(cartDiscount);
                              }
                            });
                          }),
                    ],
                  ),
                  trailing: Text(
                    "₹$cartPrice",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: text_md,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        addToCart(counter);
                      },
                      child: Text(
                        "Add",
                        style:
                            TextStyle(fontSize: text_md, color: Colors.white),
                      ),
                      color: primaryColor,
                    ),
                  ),
                ),
              ]),
            );
          });
        });
  }

  getPriceWithCoins(price) {
    etbCoinsUsable = (price * 2 / 100).floor();
    return (etbCoinsUsable);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.prodName,
          style: TextStyle(fontSize: text_md),
        ),
      ),
      body: isLoading
          ? Loading()
          : StreamBuilder(
              builder: (context, snap) {
                print(widget.cat);
                print(widget.prodId);
                ourPrice = snap.hasData ? snap.data["ourPrice"] : "xx";
                totalDiscount = snap.hasData ? snap.data["discount"] : "xx";
                qInStock = snap.hasData ? snap.data["qAvailable"] : "xx";
                categoriesWithSize.contains(widget.cat)
                    ? snap.hasData
                        ? convertSizes(snap.data["sizesAvailable"])
                        : null
                    : null;

                return !snap.hasData
                    ? Loading()
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                SliderCaro(snap.data["sliderImages"]),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15, bottom: 15),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          toggleOverflow = !toggleOverflow;
                                        });
                                      },
                                      child: Text(
                                        "#onlyAtETB",
                                        style: TextStyle(
                                            fontSize: text_md,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                        text: TextSpan(
                                            text: "₹${snap.data["ourPrice"]}  ",
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: snap
                                                      .data["regularPrice"]
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      decoration: TextDecoration
                                                          .lineThrough)),
                                              TextSpan(
                                                  text:
                                                      "\n₹${snap.data["discount"]} off",
                                                  style: TextStyle(
                                                    fontSize: text_md,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[700],
                                                  ))
                                            ],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20))),
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 15.0, top: 4),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Or",
                                      style: TextStyle(
                                          fontSize: text_sm,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 15.0, top: 4),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(children: [
                                      Text(
                                        "₹${snap.data["ourPrice"] - getPriceWithCoins(snap.data["ourPrice"])} + ${getPriceWithCoins(snap.data["ourPrice"])}",
                                        style: TextStyle(
                                            fontSize: text_md,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Image.asset(
                                        "lib/assets/images/coin.png",
                                        height: 22,
                                        width: 22,
                                        fit: BoxFit.cover,
                                      )
                                    ]),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      snap.data["productName"],
                                      style: TextStyle(
                                          fontSize: text_xl,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15, bottom: 15),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          toggleOverflow = !toggleOverflow;
                                        });
                                      },
                                      child: Text(
                                        snap.data["description"],
                                        maxLines: toggleOverflow ? 5 : null,
                                        overflow: toggleOverflow
                                            ? TextOverflow.ellipsis
                                            : null,
                                        style: TextStyle(fontSize: text_md),
                                      ),
                                    ),
                                  ),
                                ),
                                categoriesWithSize.contains(widget.cat)
                                    ? SmartSelect<String>.single(
                                        title: 'Sizes',
                                        modalType: S2ModalType.popupDialog,
                                        value: value,
                                        choiceItems: sizes,
                                        onChange: (state) {
                                          print(state.value);
                                          setState(() => value = state.value);
                                          selectedSize = state.value;
                                        })
                                    : Container(),
                                qInStock == 0
                                    ? Container(
                                        margin: EdgeInsets.only(top: 30),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "This Item is Out of Stock",
                                            style: TextStyle(
                                                fontSize: text_md,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ],
                        ),
                      );
              },
              stream: FirebaseFirestore.instance
                  .collection(widget.cat)
                  .doc(widget.prodId)
                  .snapshots(),
            ),
      bottomNavigationBar: Container(
        height: 120,
        child: Column(children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: FlatButton(
                  onPressed: qInStock == 0
                      ? () {
                          print(qInStock);
                          toast("This item is Out Of Stock");
                        }
                      : () async {
                          print(qInStock);
                          await addToCart(1);
                          if (categoriesWithSize.contains(widget.cat) &&
                              selectedSize != "") {
                            print(selectedSize);
                            print("SIXE CHECK");
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => CartScreen(
                                          fromBuyScreen: true,
                                        )))
                                .then((value) {
                              initToast();
                            });
                          } else if (!categoriesWithSize.contains(widget.cat)) {
                            print("check this");
                            print(selectedSize);
                            print(widget.cat);
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => CartScreen(
                                          fromBuyScreen: true,
                                        )))
                                .then((value) {
                              initToast();
                            });
                          }
                        },
                  color: primaryColor,
                  child: Text("Buy Now",
                      style:
                          TextStyle(fontSize: text_sm, color: Colors.white)))),
          Row(children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(
                right: BorderSide(width: 1.5, color: Colors.grey),
              )),
              width: MediaQuery.of(context).size.width * .5,
              height: 60,
              child: FlatButton(
                color: Colors.white,
                onPressed: () {
                  qInStock == 0
                      ? toast("This item is Out Of Stock")
                      : categoriesWithSize.contains(widget.cat)
                          ? addToCart(1)
                          : showModal(ourPrice, totalDiscount, qInStock);
                },
                child: Text(
                  "Add To Cart",
                  style: TextStyle(fontSize: text_sm),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * .5,
              height: 60,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Contact()));
                },
                child: Text(
                  "Inquire",
                  style: TextStyle(
                    fontSize: text_sm,
                  ),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
