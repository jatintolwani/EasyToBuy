import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/providers/orders_provider.dart';
import 'package:easytobuy/screens/mainProduct_screen.dart';
import 'package:easytobuy/widgets/cacheImage.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListing extends StatefulWidget {
  var cat;
  var gender;
  ProductListing(this.cat, [this.gender]);
  @override
  _ProductListingState createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  var dropDown = "Newest First";
  var filters = ["Newest First", "Price Low-High", "Price High-Low"];
  var query;

  getQuery() {
    if (widget.gender == null) {
      if (dropDown == "Newest First") {
        query = FirebaseFirestore.instance
            .collection(widget.cat)
            .orderBy("when", descending: true)
            .snapshots();
      } else if (dropDown == "Price Low-High") {
        query = FirebaseFirestore.instance
            .collection(widget.cat)
            .orderBy("ourPrice")
            .snapshots();
      } else if (dropDown == "Price High-Low") {
        query = FirebaseFirestore.instance
            .collection(widget.cat)
            .orderBy("ourPrice", descending: true)
            .snapshots();
      }
    } else {
      if (dropDown == "Newest First") {
        query = FirebaseFirestore.instance
            .collection(widget.cat)
            .where("gender", isEqualTo: widget.gender)
            .orderBy("when", descending: true)
            .snapshots();
      } else if (dropDown == "Price Low-High") {
        query = FirebaseFirestore.instance
            .collection(widget.cat)
            .where("gender", isEqualTo: widget.gender)
            .orderBy("ourPrice")
            .snapshots();
      } else if (dropDown == "Price High-Low") {
        query = FirebaseFirestore.instance
            .collection(widget.cat)
            .where("gender", isEqualTo: widget.gender)
            .orderBy("ourPrice", descending: true)
            .snapshots();
      }
    }

    return query;
  }

  @override
  void initState() {
    super.initState();
    getQuery();
    print(widget.cat + "PRODDDDDDDDDDDD");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.gender != null
          ? null
          : AppBar(
              backgroundColor: primaryColor,
              title: Text(
                widget.cat,
                style: TextStyle(fontSize: text_md),
              ),
            ),
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text(
            "Filters",
            style: TextStyle(fontSize: text_sm),
          ),
          DropdownButton(
            value: dropDown,
            onChanged: (newValue) {
              setState(() {
                dropDown = newValue;
                getQuery();
              });
            },
            items: filters.map((cat) {
              return DropdownMenuItem(
                child: Text(
                  cat,
                  style: TextStyle(fontSize: text_sm),
                ),
                value: cat,
              );
            }).toList(),
          ),
        ]),
        StreamBuilder(
          builder: (context, snap) => !snap.hasData
              ? Loading()
              : (snap.hasData && snap.data.docs.length == 0)
                  ? Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                          child: Text(
                        "No Products Found",
                        style: TextStyle(fontSize: text_md),
                      )),
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: snap.data.docs.length,
                          itemBuilder: (context, index) {
                            return Stack(children: [
                              Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  height: 150,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => MainProduct(
                                                  snap.data.docs[index]
                                                      ["productId"],
                                                  snap.data.docs[index]
                                                      ["productName"],
                                                  widget.cat)))
                                          .then((value) {
                                        Provider.of<Orders>(context,
                                                listen: false)
                                            .getRecents();
                                      });
                                    },
                                    child: Column(children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 130,
                                            width: 130,
                                            child: CacheImage(
                                                snap.data.docs[index]
                                                    ["sliderImages"][0]),
                                          ),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  snap.data.docs[index]
                                                      ["productName"],
                                                  overflow: snap
                                                              .data
                                                              .docs[index][
                                                                  "productName"]
                                                              .length >
                                                          45
                                                      ? TextOverflow.ellipsis
                                                      : null,
                                                  style: TextStyle(
                                                      fontSize: text_md),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                RichText(
                                                    text: TextSpan(
                                                        text:
                                                            "₹${snap.data.docs[index]["ourPrice"]}  ",
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: snap
                                                                  .data
                                                                  .docs[index][
                                                                      "regularPrice"]
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
                                                                  "\n₹${snap.data.docs[index]["discount"]} off",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    text_sm,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .green[700],
                                                              ))
                                                        ],
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                text_md))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                                  )),
                              snap.data.docs[index]["qAvailable"] != 0
                                  ? Container()
                                  : InkWell(
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => MainProduct(
                                                  snap.data.docs[index]
                                                      ["productId"],
                                                  snap.data.docs[index]
                                                      ["productName"],
                                                  widget.cat))),
                                      child: Card(
                                        color: Colors.grey.withOpacity(0.2),
                                        child: Container(
                                          height: 140,
                                          padding: EdgeInsets.all(15),
                                          child: Center(
                                              child: Text(
                                            "Out Of Stock",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          )),
                                        ),
                                      ),
                                    )
                            ]);
                          }),
                    ),
          stream: query,
        ),
      ]),
    );
  }
}
