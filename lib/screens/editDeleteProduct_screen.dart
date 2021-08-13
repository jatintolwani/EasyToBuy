import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';

import '../main_config.dart';
import 'addProduct_screen.dart';

class EditDelete extends StatefulWidget {
  @override
  _EditDeleteState createState() => _EditDeleteState();
}

class _EditDeleteState extends State<EditDelete> {
  var dropDown = "Used Mobiles";
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Select Product",
          style: TextStyle(fontSize: text_md),
        ),
      ),
      body: isLoading
          ? Loading()
          : Column(
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: DropdownButton(
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
                  ),
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(dropDown)
                        .snapshots(),
                    builder: (context, snap) {
                      // print(snap.data.docs.length);
                      return !snap.hasData
                          ? Loading()
                          : Flexible(
                              child: (ListView.builder(
                                  itemCount:
                                      snap.hasData ? snap.data.docs.length : 0,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: primaryColor)),
                                      child: ListTile(
                                        title: Text(snap.data.docs[index]
                                            ["productName"]),
                                        trailing: IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: primaryColor,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddProduct(
                                                            true,
                                                            id: snap.data
                                                                    .docs[index]
                                                                ["productId"],
                                                            category: dropDown,
                                                          )));
                                            }),
                                      ),
                                    );
                                  })),
                            );
                    })
              ],
            ),
    );
  }
}
