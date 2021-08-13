import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import '../main_config.dart';

class DeleteCoupon extends StatefulWidget {
  @override
  _DeleteCouponState createState() => _DeleteCouponState();
}

class _DeleteCouponState extends State<DeleteCoupon> {
  deleteCoupon(id) async {
    try {
      await FirebaseFirestore.instance
          .collection("Coupons")
          .doc(dropDown)
          .collection(dropDown)
          .doc(id)
          .delete();
    } catch (err) {
      print(err);
    }
  }

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
    "Offers",
    "Coins"
  ];
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Select Coupon",
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
                        .collection("Coupons")
                        .doc(dropDown)
                        .collection(dropDown)
                        .snapshots(),
                    builder: (context, snap) {
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
                                            ["couponName"]),
                                        subtitle: Text(
                                          snap.data.docs[index]
                                              ["couponDescription"],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: primaryColor,
                                            ),
                                            onPressed: () {
                                              deleteCoupon(
                                                  snap.data.docs[index]["id"]);
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
