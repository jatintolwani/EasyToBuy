import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/providers/orders_provider.dart';
import 'package:easytobuy/screens/Tabbar.dart';
import 'package:easytobuy/screens/mainProduct_screen.dart';
import 'package:easytobuy/screens/productListing_screen.dart';
import 'package:easytobuy/screens/searchProduct_screen.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:easytobuy/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  var sliders = [];
  Home(this.sliders);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    "Offers"
  ];
  var isLoading = false;

  Widget topProducts(cat) {
    return Column(children: [
      SizedBox(
        height: 20,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * .7,
              child: Text("Latest from " + cat,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: text_sm,
                      fontWeight: FontWeight.bold)),
            ),
            FlatButton(
                height: 22,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () {
                  if (cat == "Fashion" || cat == "Shoes") {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TabBarForGenders(cat)));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProductListing(cat)));
                  }
                },
                child: Text("See all",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: text_sm,
                    )))
          ],
        ),
      ),
      Container(
        height: 250,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(cat)
                .orderBy("when", descending: true)
                .snapshots(),
            builder: (context, snapShot) {
              return !snapShot.hasData
                  ? Loading()
                  : ListView.builder(
                      itemCount: snapShot.data.docs.length > 5
                          ? 5
                          : snapShot.data.docs.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => MainProduct(
                                          snapShot.data.docs[index]
                                              ["productId"],
                                          snapShot.data.docs[index]
                                              ["productName"],
                                          cat,
                                        )))
                                .then((value) {
                              Provider.of<Orders>(context, listen: false)
                                  .getRecents();
                            });
                          },
                          child: (Container(
                              height: 250,
                              width: 200,
                              child: (Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Container(
                                          height: 130,
                                          width: 200,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              snapShot.data.docs[index]
                                                  ["sliderImages"][0],
                                              fit: BoxFit.cover,
                                            ),
                                          )),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          snapShot.data.docs[index]
                                              ["productName"],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: text_md),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: RichText(
                                            text: TextSpan(
                                                text:
                                                    "₹${snapShot.data.docs[index]["ourPrice"]}  ",
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: snapShot
                                                          .data
                                                          .docs[index]
                                                              ["regularPrice"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: text_md,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough)),
                                                  TextSpan(
                                                      text:
                                                          "\n₹${snapShot.data.docs[index]["discount"]} off",
                                                      style: TextStyle(
                                                        fontSize: text_sm,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.green[700],
                                                      ))
                                                ],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: text_md))),
                                      ),
                                    ],
                                  ),
                                ),
                              )))),
                        );
                      },
                    );
            }),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    getCoins();
    getData();
  }

  getData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Orders>(context, listen: false).getRecents();
    });
  }

  getCoins() async {
    await Provider.of<Orders>(context, listen: false).getCoins();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: isLoading
          ? Loading()
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
                  child: Container(
                    height: 50,
                    child: TextFormField(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SearchProduct()));
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1),
                              borderRadius: BorderRadius.circular(15)),
                          hintText: "Search #onlyAtETB",
                          hintStyle: TextStyle(fontSize: text_sm)),
                    ),
                  ),
                ),
                Container(child: SliderCaro(widget.sliders)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Categories",
                      style: TextStyle(
                          fontSize: text_md,
                          color: primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  childAspectRatio: 1.3,
                  physics: NeverScrollableScrollPhysics(),
                  primary: false,
                  padding: const EdgeInsets.all(5),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  children: <Widget>[
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProductListing(categories[0])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage:
                                  AssetImage("lib/assets/Categories/used.jpeg"),
                            ),
                          ),
                        ),
                        Text(
                          categories[0],
                          overflow: TextOverflow.ellipsis,
                        )
                      ]),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProductListing(categories[1])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  "lib/assets/Categories/global.jpeg"),
                            ),
                          ),
                        ),
                        Text(
                          categories[1],
                          overflow: TextOverflow.ellipsis,
                        )
                      ]),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProductListing(categories[2])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  "lib/assets/Categories/new_mob.jpeg"),
                            ),
                          ),
                        ),
                        Text(
                          categories[2],
                          overflow: TextOverflow.ellipsis,
                        )
                      ]),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProductListing(categories[3])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  "lib/assets/Categories/mob_acc.jpeg"),
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            categories[3], overflow: TextOverflow.ellipsis,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ]),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProductListing(categories[4])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage:
                                  AssetImage("lib/assets/Categories/add.jpg"),
                            ),
                          ),
                        ),
                        Text(
                          categories[4],
                          overflow: TextOverflow.ellipsis,
                        )
                      ]),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    TabBarForGenders(categories[5])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  "lib/assets/Categories/fashion.jpeg"),
                            ),
                          ),
                        ),
                        Text(
                          categories[5],
                          overflow: TextOverflow.ellipsis,
                        )
                      ]),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    TabBarForGenders(categories[6])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  "lib/assets/Categories/shoes.jpeg"),
                            ),
                          ),
                        ),
                        Text(
                          categories[6],
                          overflow: TextOverflow.ellipsis,
                        )
                      ]),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProductListing(categories[7])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  "lib/assets/Categories/watch.jpeg"),
                            ),
                          ),
                        ),
                        Text(
                          categories[7],
                          overflow: TextOverflow.ellipsis,
                        )
                      ]),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProductListing(categories[8])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  "lib/assets/Categories/laptop.jpeg"),
                            ),
                          ),
                        ),
                        FittedBox(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            categories[8],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                      ]),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProductListing(categories[9])));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                  "lib/assets/Categories/offers.jpeg"),
                            ),
                          ),
                        ),
                        Text(
                          categories[9],
                          overflow: TextOverflow.ellipsis,
                        )
                      ]),
                    ),
                  ],
                ),

                topProducts(categories[0]),
                topProducts(categories[1]),
                topProducts(categories[2]),
                topProducts(categories[3]),
                topProducts(categories[4]),
                topProducts(categories[5]),
                topProducts(categories[6]),
                topProducts(categories[7]),
                topProducts(categories[8]),
                topProducts(categories[9]),

                //recents//
                Provider.of<Orders>(context, listen: true).isLoading
                    ? Loading()
                    : Provider.of<Orders>(context, listen: false)
                                .recents
                                .length <=
                            0
                        ? Container()
                        : Column(children: [
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .7,
                                    child: Text("Recently Viewed",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontSize: text_sm,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                height: 250,
                                child: ListView.builder(
                                  itemCount: Provider.of<Orders>(context,
                                                  listen: false)
                                              .recents
                                              .length >
                                          5
                                      ? 5
                                      : Provider.of<Orders>(context,
                                              listen: false)
                                          .recents
                                          .length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MainProduct(
                                                      Provider.of<Orders>(
                                                              context,
                                                              listen: false)
                                                          .items[index]
                                                          .productID,
                                                      Provider.of<Orders>(
                                                              context,
                                                              listen: false)
                                                          .items[index]
                                                          .productName,
                                                      Provider.of<Orders>(
                                                              context,
                                                              listen: false)
                                                          .items[index]
                                                          .productCat,
                                                    )));
                                      },
                                      child: (Container(
                                          height: 250,
                                          width: 200,
                                          child: (Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            elevation: 5,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Container(
                                                      height: 130,
                                                      width: 200,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image.network(
                                                          Provider.of<Orders>(
                                                                  context,
                                                                  listen: false)
                                                              .items[index]
                                                              .productImg,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      Provider.of<Orders>(
                                                              context,
                                                              listen: false)
                                                          .items[index]
                                                          .productName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: text_md),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: RichText(
                                                        text: TextSpan(
                                                            text:
                                                                "₹${Provider.of<Orders>(context, listen: false).items[index].productOurPrice}  ",
                                                            children: <
                                                                TextSpan>[
                                                              TextSpan(
                                                                  text: Provider.of<
                                                                              Orders>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .items[
                                                                          index]
                                                                      .productRegPrice
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          text_md,
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
                                                                      "\n₹${Provider.of<Orders>(context, listen: false).items[index].productDiscount} off",
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
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    text_md))),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )))),
                                    );
                                  },
                                )),
                          ])
              ],
            ),
    );
  }
}
