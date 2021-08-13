import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/models/cartItem.dart';
import 'package:easytobuy/screens/applyCoupon_screen.dart';
import 'package:easytobuy/screens/mainProduct_screen.dart';
import 'package:easytobuy/widgets/cacheImage.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';

class CartScreen extends StatefulWidget {
  var fromBuyScreen;
  CartScreen({this.fromBuyScreen});
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> products = [];
  List<Cart> data = [];
  var productID;
  var productCat;
  var productQuantity;
  var productTotalDiscount;
  var productTotalPrice;
  var productName;
  var productImg;
  var productRegPrice;
  var productOurPrice;

  var cartTotal = 0;
  var cartDiscount = 0;
  var listingPrice = 0;
  var qAvailInStock = 0;
  var stockOut = [];

  var message = '';
  var isLoading = false;

  var catForCoupons = [];
  var catTotalPrice = [];

  var categoriesWithSize = ["Fashion", "Shoes"];

  //fetch and set Data
  getIDs() async {
    data.clear();
    products.clear();
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection("Cart")
          .get()
          .then((value) => {
                print(products),
                value.docs.forEach((element) {
                  if (categoriesWithSize.contains(element["category"])) {
                    data.add(Cart(element["productID"], element["quantity"],
                        element["category"], element["size"]));
                  } else {
                    data.add(Cart(element["productID"], element["quantity"],
                        element["category"]));
                  }
                })
              });
      print("data");
      print(data);
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
    await getDataAgain();
    setState(() {
      isLoading = false;
    });
    return data;
  }

  var keySets = Map();
  getDataAgain() async {
    cartTotal = 0;
    cartDiscount = 0;
    listingPrice = 0;
    try {
      for (var i = 0; i < data.length; i++) {
        print("yea");
        print(data.length);
        await FirebaseFirestore.instance
            .collection(data[i].cat)
            .doc(data[i].prodID)
            .get()
            .then((value) => {
                  categoriesWithSize.contains(data[i].cat)
                      ? products.add(CartItem(
                          productID: value["productId"],
                          productCat: data[i].cat,
                          productImg: value["sliderImages"][0],
                          productName: value["productName"],
                          productOurPrice: value["ourPrice"],
                          productDiscount: value["discount"],
                          productQuantity: data[i].quantity,
                          productRegTotalPrice:
                              value["regularPrice"] * data[i].quantity,
                          productRegPrice: value["regularPrice"],
                          productTotalPrice:
                              value["ourPrice"] * data[i].quantity,
                          qAvailable: value["qAvailable"],
                          productTotalDiscount:
                              value["discount"] * data[i].quantity,
                          gender: value["gender"],
                          clothSize: data[i].size))
                      : products.add(CartItem(
                          productID: value["productId"],
                          productCat: data[i].cat,
                          productImg: value["sliderImages"][0],
                          productName: value["productName"],
                          productOurPrice: value["ourPrice"],
                          productDiscount: value["discount"],
                          productQuantity: data[i].quantity,
                          productRegTotalPrice:
                              value["regularPrice"] * data[i].quantity,
                          productRegPrice: value["regularPrice"],
                          productTotalPrice:
                              value["ourPrice"] * data[i].quantity,
                          qAvailable: value["qAvailable"],
                          productTotalDiscount:
                              value["discount"] * data[i].quantity)),
                });

        print(products.length);
      }
    } catch (err) {
      print(err);
    }
    getTotal();
    return products;
  }

  getCatForCoupons() {
    catForCoupons.clear();
    keySets.clear();
    for (var i = 0; i < products.length; i++) {
      catForCoupons.add(products[i].productCat);
      print("HCECK");
      print(catForCoupons);
      if (keySets.containsKey(products[i].productCat)) {
        print("IF");
        keySets[products[i].productCat] =
            keySets[products[i].productCat] + products[i].productTotalPrice;
        print(keySets[products[i].productCat]);
      } else {
        keySets[products[i].productCat] = products[i].productTotalPrice;
      }
    }
    print(keySets);
    // catForCoupons = [
    //   ...{...catForCoupons}
    // ];
  }

  getTotal() {
    print("total");
    for (var i = 0; i < products.length; i++) {
      listingPrice += products[i].productRegTotalPrice;
      cartTotal += products[i].productTotalPrice;
      cartDiscount += products[i].productTotalDiscount;
      qAvailInStock += products[i].qAvailable;
    }
    print(cartTotal);
  }

  //delete Data
  removeItem(index, prodIDToDelete, prodNameToDelete) async {
    setState(() {
      isLoading = true;
    });
    stockOut.clear();
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection("Cart")
          .doc(prodIDToDelete)
          .delete();
      await getIDs();
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
    toast(prodNameToDelete + " Removed");
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

  checkStock(index, quantityAvailable, quantityInCart, id, name, cat) {
    print("$index + fuck");
    message = "";
    if (quantityAvailable == 0) {
      stockOut.insert(index, "t");
      message = "Out of Stock";
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainProduct(id, name, cat)));
        },
        child: Card(
          color: Colors.grey.withOpacity(0.2),
          child: Container(
              height: 230,
              width: double.infinity,
              padding: EdgeInsets.all(15),
              child: Center(
                child: Text(
                  message,
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              )),
        ),
      );
    } else if (quantityInCart > quantityAvailable) {
      stockOut.insert(index, "t");
      message = "We have only $quantityAvailable Piece(s) Left";
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainProduct(id, name, cat)));
        },
        child: Card(
          color: Colors.grey.withOpacity(0.2),
          child: Container(
              height: 230,
              padding: EdgeInsets.all(15),
              child: Center(
                child: Text(
                  message,
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              )),
        ),
      );
    } else {
      stockOut.insert(index, "f");
      return Container();
    }
  }

  FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    getIDs();
  }

  initToast() {
    fToast = FToast();
    fToast.init(context);
    getIDs();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.fromBuyScreen
            ? AppBar(
                backgroundColor: primaryColor,
                title: Text(
                  "Order Summary",
                  style: TextStyle(fontSize: text_md),
                ),
              )
            : null,
        body: isLoading
            ? Loading()
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Card(
                                elevation: 5,
                                child: Container(
                                    padding: EdgeInsets.all(15),
                                    // height: 230,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MainProduct(
                                                        products[index]
                                                            .productID,
                                                        products[index]
                                                            .productName,
                                                        products[index]
                                                            .productCat)));
                                      },
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
                                                    products[index].productName,
                                                    overflow: products[index]
                                                                .productName
                                                                .length >
                                                            45
                                                        ? TextOverflow.ellipsis
                                                        : null,
                                                    style: TextStyle(
                                                        fontSize: text_xl,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "Quantity - ${products[index].productQuantity}",
                                                    style: TextStyle(
                                                        fontSize: text_sm,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "Category - ${products[index].productCat}",
                                                    style: TextStyle(
                                                        fontSize: text_sm,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  categoriesWithSize.contains(
                                                          products[index]
                                                              .productCat)
                                                      ? Text(
                                                          "Size - ${products[index].clothSize}",
                                                          style: TextStyle(
                                                              fontSize: text_sm,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      : Container(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  categoriesWithSize.contains(
                                                          products[index]
                                                              .productCat)
                                                      ? Text(
                                                          "Ideal for - ${products[index].gender}",
                                                          style: TextStyle(
                                                              fontSize: text_sm,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      : Container(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  RichText(
                                                      text: TextSpan(
                                                          text:
                                                              "₹${products[index].productTotalPrice}  ",
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                                text: products[
                                                                        index]
                                                                    .productRegTotalPrice
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        text_xl,
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough)),
                                                            TextSpan(
                                                                text:
                                                                    "\n₹${products[index].productTotalDiscount} off",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      text_sm,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                          .green[
                                                                      700],
                                                                ))
                                                          ],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  text_xl))),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 5),
                                              height: 130,
                                              width: 130,
                                              child: CacheImage(
                                                  products[index].productImg),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 25,
                                        ),
                                      ]),
                                    )),
                              ),
                              checkStock(
                                  index,
                                  products[index].qAvailable,
                                  products[index].productQuantity,
                                  products[index].productID,
                                  products[index].productName,
                                  products[index].productCat),
                              Positioned(
                                bottom: 0,
                                right: 10,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: FlatButton.icon(
                                      onPressed: () {
                                        removeItem(
                                            index,
                                            products[index].productID,
                                            products[index].productName);
                                      },
                                      icon: Icon(Icons.delete),
                                      label: Text("Remove")),
                                ),
                              ),
                            ],
                          );
                        }),
                    SizedBox(
                      height: 30,
                    ),
                    products.isEmpty
                        ? Container(
                            height: MediaQuery.of(context).size.height -
                                AppBar().preferredSize.height * 2 -
                                30,
                            child: Center(
                                child: Text(
                              "Your Cart is Empty",
                              style: TextStyle(fontSize: 20),
                            )))
                        : Column(children: [
                            Container(
                              width: double.infinity,
                              child: Card(
                                elevation: 5,
                                child: Container(
                                  height: 250,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Price Details",
                                            style:
                                                TextStyle(fontSize: text_md)),
                                      ),
                                      Divider(
                                        color: Colors.black,
                                      ),
                                      ListTile(
                                        leading: Text(
                                          "Total Listing Price",
                                        ),
                                        trailing:
                                            Text("₹${listingPrice.toString()}"),
                                      ),
                                      ListTile(
                                        leading: Text("Total Discount"),
                                        trailing: Text(
                                          "- ₹${cartDiscount.toString()}",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.black,
                                      ),
                                      ListTile(
                                        leading: Text(
                                          "Total Cart Amount",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: Text(
                                          "₹${cartTotal.toString()}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              "You will save ₹${cartDiscount.toString()} on this order🎉",
                              style: TextStyle(
                                  color: Colors.green, fontSize: text_sm),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              width: double.infinity,
                              height: 60,
                              child: RaisedButton(
                                color: primaryColor,
                                onPressed: () => {
                                  print(stockOut),
                                  if (stockOut.contains("t"))
                                    {
                                      toast("Items in Cart are not in Stock"),
                                    }
                                  else
                                    {
                                      // toast("Y"),
                                      getCatForCoupons(),
                                      Provider.of<Orders>(context,
                                              listen: false)
                                          .storeData(OrderItems(
                                              products,
                                              cartTotal,
                                              cartDiscount,
                                              listingPrice)),
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => ApplyCoupon(
                                                  keySets, cartTotal)))
                                          .then((value) {
                                        initToast();
                                      })
                                    }
                                },
                                child: Text(
                                  "Continue",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: text_md),
                                ),
                              ),
                            )
                          ]),
                  ]),
                ),
              ));
  }
}
