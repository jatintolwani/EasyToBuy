import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/models/coupon.dart';
import 'package:easytobuy/providers/orders_provider.dart';
import 'package:easytobuy/screens/shippingAddress_screen.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';

class ApplyCoupon extends StatefulWidget {
  Map keySets;
  var totalValue;
  ApplyCoupon(this.keySets, this.totalValue);
  @override
  _ApplyCouponState createState() => _ApplyCouponState();
}

class _ApplyCouponState extends State<ApplyCoupon> {
  List<Coupon> coupons = [];

  var couponApplied = "";
  var couponDesc = "";
  var couponDisocunt;
  var couponPercentage;
  var amountToPay;

  var catToApplyCoupon = "";

  var isLoading = false;
  var showCoupon = false;
  var index;

  var couponNames = [];
  var fetchedUsedCoupons = [];

  var cont = TextEditingController();

  var fNode = FocusNode();
  getCoupons() async {
    setState(() {
      isLoading = true;
    });
    print("fokfok");
    couponNames.clear();
    fetchedUsedCoupons.clear();
    var catForCoupons = widget.keySets.keys.toList();
    for (var i = 0; i < catForCoupons.length; i++) {
      print(catForCoupons);
      try {
        await FirebaseFirestore.instance
            .collection("Coupons")
            .doc(catForCoupons[i])
            .collection(catForCoupons[i])
            .get()
            .then((value) {
          value.docs.forEach((element) {
            coupons.add(Coupon(
                element["couponName"],
                element["couponDescription"],
                element["couponDiscount"],
                element["couponCat"]));
            couponNames.add(element["couponName"]);
          });

          print(couponNames);
        });
        fetchedUsedCoupons = await Provider.of<Orders>(context, listen: false)
            .retrieveUsedCoupon();
        // await FirebaseFirestore.instance
        //     .collection("Users")
        //     .doc(currentUser)
        //     .get()
        //     .then((value) {
        //   fetchedUsedCoupons = value["usedCoupons"];
        // });
        print("USED FETCHED");
        print(fetchedUsedCoupons);
      } catch (err) {
        print(err);
        setState(() {
          isLoading = false;
        });
      }
      setState(() {
        isLoading = false;
      });
    }
    Provider.of<Orders>(context, listen: false)
        .storeUsedCoupons(fetchedUsedCoupons);
  }

  applyCoupon(cApplied, cDisc, cCat, cDesc) {
    setState(() {
      catToApplyCoupon = cCat;
      couponApplied = cApplied;
      couponDesc = cDesc;
      couponDisocunt =
          ((widget.keySets[catToApplyCoupon] * cDisc) / 100).floor();
      couponPercentage = cDisc;
      amountToPay = widget.totalValue - couponDisocunt;
      print(amountToPay);
    });
  }

  placeOrder() async {
    // couponsUsed = fetchedUsedCoupons;
    if (couponApplied == "") {
      amountToPay = double.parse(widget.totalValue.toString());
      Provider.of<Orders>(context, listen: false)
          .storeCoupon(amountToPay, Coupon("None", "None", "None", "None"));
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => MyCustomForm()));
    } else if (couponApplied != "") {
      Provider.of<Orders>(context, listen: false).storeCoupon(
          amountToPay,
          Coupon(couponApplied, couponDesc, couponPercentage, catToApplyCoupon,
              couponDisocunt));
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => MyCustomForm()));
    }
  }

  @override
  void initState() {
    super.initState();
    getCoupons();
    print("INNIT COPNA");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Apply Coupon",
          style: TextStyle(fontSize: text_md),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: primaryColor)),
              child: Column(
                children: [
                  ListTile(
                    title: Text("Total Amount"),
                    trailing: Text("₹${widget.totalValue.toString()}"),
                  ),
                  ListTile(
                    title: Text("Coupon Category"),
                    trailing: Text(
                        catToApplyCoupon == "" ? "None" : catToApplyCoupon),
                  ),
                  ListTile(
                    title: Text("Coupon Applied"),
                    trailing:
                        Text(couponApplied != "" ? couponApplied : "None"),
                  ),
                  ListTile(
                    title: Text("Coupon Discount"),
                    trailing: Text(
                      couponDisocunt == null
                          ? "0"
                          : "₹${couponDisocunt.toString()}",
                      style: TextStyle(
                          color: couponDisocunt == null
                              ? Colors.black
                              : Colors.green),
                    ),
                  ),
                  ListTile(
                    title: Text("Amount to Pay",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                        amountToPay == null
                            ? "₹${widget.totalValue.toString()}"
                            : "₹${amountToPay.toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (amountToPay == null ||
                                    amountToPay == widget.totalValue)
                                ? Colors.black
                                : Colors.green)),
                  ),
                ],
              ),
            ),
          ),
          isLoading
              ? Loading()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 170,
                    child: Card(
                      elevation: 5,
                      child: Column(children: [
                        ListTile(
                          title: Text(
                            "Do you have a Coupon Code?",
                            style: TextStyle(fontSize: text_md),
                          ),
                          subtitle: Text(
                            "Avail Exciting Offers",
                            style: TextStyle(fontSize: text_sm),
                          ),
                          trailing: Container(
                            height: 150,
                            width: 150,
                            child: Image.asset(
                              'lib/assets/images/coupon.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: cont,
                            focusNode: fNode,
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: primaryColor, width: 2.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: primaryColor, width: 1),
                                ),
                                hintText: "Coupon Code",
                                hintStyle: TextStyle(fontSize: text_md)),
                            onChanged: (val) {
                              if (couponNames.contains(val)) {
                                setState(() {
                                  showCoupon = true;
                                });
                                index = coupons.indexWhere(
                                    (element) => element.couponName == val);
                              } else {
                                setState(() {
                                  showCoupon = false;
                                });
                              }
                            },
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
          showCoupon
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DottedBorder(
                    color: primaryColor,
                    strokeWidth: 3,
                    dashPattern: [
                      8,
                      4,
                    ],
                    borderType: BorderType.Rect,
                    child: ListTile(
                      title: Text(
                        coupons[index].couponName,
                        style: TextStyle(
                            fontSize: text_md, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        coupons[index].couponDesc,
                        style: TextStyle(
                            fontSize: text_sm, fontWeight: FontWeight.bold),
                      ),
                      trailing: fetchedUsedCoupons.contains(cont.text)
                          ? FlatButton(
                              onPressed: () {},
                              child: Text(
                                "Already Used",
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : FlatButton(
                              onPressed: () {
                                fNode.unfocus();
                                //print(coupons[0][]);
                                applyCoupon(
                                    coupons[index].couponName,
                                    coupons[index].couponDiscInPercentage,
                                    coupons[index].couponCat,
                                    coupons[index].couponDesc);
                              },
                              child: Text(
                                "Apply",
                              ),
                            ),
                    ),
                  ),
                )
              : cont.text.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Coupons will be Shown here",
                        style: TextStyle(fontSize: text_md),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "No Coupon Found",
                        style: TextStyle(fontSize: text_md),
                      ),
                    ),
          SizedBox(
            height: 100,
          ),
        ]),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          color: primaryColor,
          onPressed: () => {placeOrder()},
          child: Text(
            "Continue",
            style: TextStyle(color: Colors.white, fontSize: text_md),
          ),
        ),
      ),
    );
  }
}
