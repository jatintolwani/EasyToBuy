import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/screens/mainProduct_screen.dart';
import 'package:flutter/material.dart';

import '../main_config.dart';

class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  var searchText = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Search Product",
          style: TextStyle(fontSize: text_md),
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 50,
            child: TextFormField(
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(15)),
                  hintText: "Products",
                  hintStyle: TextStyle(fontSize: text_sm)),
              onChanged: (val) {
                setState(() {
                  searchText = val;
                });
              },
            ),
          ),
        ),
        Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("SearchKeys")
                .where(
                  'searchKeys',
                  arrayContains: searchText.toLowerCase(),
                )
                .snapshots(),
            builder: (context, snap) {
              return !snap.hasData
                  ? Center(child: CircularProgressIndicator())
                  : (searchText == null || searchText == "")
                      ? Container(
                          height: 300,
                          child: Center(
                              child: Text(
                            "Type in box to Search",
                            style: TextStyle(fontSize: text_md),
                          )))
                      : Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  print("tap");
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MainProduct(
                                          snap.data.docs[index]['productId'],
                                          snap.data.docs[index]['productName'],
                                          snap.data.docs[index]['category'])));
                                },
                                child: ListTile(
                                  title: Text(
                                    snap.data.docs[index]['productName'],
                                    style: TextStyle(
                                        fontSize: text_sm,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    "from ${snap.data.docs[index]['category']}",
                                    style: TextStyle(
                                        fontSize: text_xsm,
                                        color: Colors.black),
                                  ),
                                ),
                              );
                            },
                            itemCount: snap.data.docs.length,
                          ),
                        );
            },
          ),
        ),
      ]),
    );
  }
}
