import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/models/coupon.dart';
import 'package:easytobuy/providers/orders_provider.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  List<Coupon> coupons = [];
  List couponNames = [];
  var cont = TextEditingController();
  var showCoupon = false;
  var index;
  var fNode = FocusNode();
  var fetchedUsedCoupons = [];
  var isLoading = false;

  var etbCoins = 0;

  var allowFlipping = false;

  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> cardKey2 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> cardKey3 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> cardKey4 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> cardKey5 = GlobalKey<FlipCardState>();
  GlobalKey<FlipCardState> cardKey6 = GlobalKey<FlipCardState>();

  var coinsToCredit = [35, 42, 48, 54, 59, 65];

  getCoupons() async {
    couponNames.clear();
    coupons.clear();
    fetchedUsedCoupons.clear();
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("Coupons")
        .doc("Coins")
        .collection("Coins")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        coupons.add(Coupon(element["couponName"], element["couponDescription"],
            element["coinsToAdd"], element["couponCat"]));
        couponNames.add(element["couponName"]);
      });
    });
    print(couponNames);
    fetchedUsedCoupons =
        await Provider.of<Orders>(context, listen: false).retrieveUsedCoupon();
    setState(() {
      isLoading = false;
    });
    print("FEtched");
  }

  applyCoupon(index, coins) async {
    setState(() {
      isLoading = true;
    });
    print(fetchedUsedCoupons);
    fetchedUsedCoupons.add(coupons[index].couponName);
    print(fetchedUsedCoupons);
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .update({
      "etbCoins": coins + coupons[index].couponDiscInPercentage,
      "usedCoupons": fetchedUsedCoupons
    });
    await Provider.of<Orders>(context, listen: false).getCoins();
    setState(() {
      isLoading = false;
    });
  }

  useCoinForSurprise() async {
    // setState(() {});
    cardKey.currentState.toggleCard();
    cardKey2.currentState.toggleCard();
    cardKey3.currentState.toggleCard();
    cardKey4.currentState.toggleCard();
    cardKey5.currentState.toggleCard();
    cardKey6.currentState.toggleCard();
    await Future.delayed(Duration(seconds: 2));
    clickCardChance();
  }

  clickCardChance() async {
    coinsToCredit.shuffle();
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .update({
      "etbCoins": etbCoins - 50,
    });
    setState(() {
      isLoading = false;
      allowFlipping = true;
    });

    Fluttertoast.showToast(
        msg: "Cards Shuffled", toastLength: Toast.LENGTH_SHORT);
  }

  flipCard(key, text) {
    return FlipCard(
      key: key,
      flipOnTouch: false,
      front: GestureDetector(
        onTap: allowFlipping
            ? () async {
                key.currentState.toggleCard();
                setState(() {
                  allowFlipping = false;
                });
                await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(currentUser)
                    .update({
                  "etbCoins": etbCoins + text,
                });
                await Provider.of<Orders>(context, listen: false).getCoins();
                Fluttertoast.showToast(
                    gravity: ToastGravity.CENTER,
                    msg: text.toString() + " ETB Coins Credited",
                    toastLength: Toast.LENGTH_SHORT);
                await Future.delayed(Duration(seconds: 1));
                key.currentState.toggleCard();
              }
            : () {},
        child: Card(
          child: Container(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: coinColor, width: 2),
              color: primaryColor,
            ),
            child: Center(
              child: Image.asset(
                "lib/assets/images/coin.png",
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      back: Container(
        height: 200,
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: coinColor, width: 2),
        ),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text.toString() + " ETB Coins",
            style: TextStyle(fontSize: text_md),
          ),
        )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCoupons();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "ETB Wallet",
          style: TextStyle(fontSize: text_md),
        ),
      ),
      body: isLoading
          ? Loading()
          : SingleChildScrollView(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Users")
                      .doc(currentUser)
                      .snapshots(),
                  builder: (context, snap) {
                    !snap.hasData
                        ? etbCoins = 0
                        : etbCoins = snap.data["etbCoins"];
                    return !snap.hasData
                        ? Loading()
                        : Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  padding: EdgeInsets.all(10),
                                  height: 80,
                                  width: double.infinity,
                                  child: Container(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "ETB Coins",
                                            style:
                                                TextStyle(color: accentColor),
                                          ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  (snap.data["etbCoins"]
                                                          .toString()) +
                                                      "",
                                                  style: TextStyle(
                                                      color: coinColor,
                                                      fontSize: text_xl,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Image.asset(
                                                  "lib/assets/images/coin.png",
                                                  height: 22,
                                                  width: 22,
                                                  fit: BoxFit.cover,
                                                )
                                              ]),
                                          Text(
                                            "1 ETB Coin = 1 INR",
                                            style:
                                                TextStyle(color: accentColor),
                                          ),
                                        ]),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  // height: 200,
                                  child: Card(
                                    elevation: 5,
                                    child: Column(children: [
                                      ListTile(
                                        title: Text(
                                          "Do you have a Coin Code?",
                                          style: TextStyle(fontSize: text_md),
                                        ),
                                        subtitle: Text(
                                          "Use here and get ETB Coins",
                                          style: TextStyle(fontSize: text_sm),
                                        ),
                                        trailing: Container(
                                          width: 120,
                                          child: Image.asset(
                                            'lib/assets/images/coins.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: cont,
                                          decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: primaryColor,
                                                    width: 2.5),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: primaryColor,
                                                    width: 1),
                                              ),
                                              hintText: "Coin Code",
                                              hintStyle:
                                                  TextStyle(fontSize: text_md)),
                                          onChanged: (val) {
                                            if (couponNames.contains(val)) {
                                              setState(() {
                                                showCoupon = true;
                                              });
                                              index = coupons.indexWhere(
                                                  (element) =>
                                                      element.couponName ==
                                                      val);
                                            } else {
                                              setState(() {
                                                showCoupon = false;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      showCoupon
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                        fontSize: text_md,
                                                        color: coinColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  subtitle: Text(
                                                    coupons[index].couponDesc,
                                                    style: TextStyle(
                                                        fontSize: text_sm,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  trailing: fetchedUsedCoupons
                                                          .contains(cont.text)
                                                      ? FlatButton(
                                                          onPressed: () {},
                                                          child: Text(
                                                            "Already Used",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        )
                                                      : FlatButton(
                                                          onPressed: () {
                                                            fNode.unfocus();
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        AlertDialog(
                                                                          content:
                                                                              Text("Apply Coupon?"),
                                                                          actions: [
                                                                            FlatButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text(
                                                                                  "No",
                                                                                  style: TextStyle(color: primaryColor),
                                                                                )),
                                                                            FlatButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                  applyCoupon(index, snap.data["etbCoins"]);
                                                                                },
                                                                                child: Text("Yes,Apply", style: TextStyle(color: primaryColor)))
                                                                          ],
                                                                        ));
                                                          },
                                                          child: Text(
                                                            "Apply",
                                                            // style: TextStyle(color: coinColor),
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
                                                    style: TextStyle(
                                                        fontSize: text_md),
                                                  ),
                                                )
                                              : Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text(
                                                    "No Coupon Found",
                                                    style: TextStyle(
                                                        fontSize: text_md),
                                                  ),
                                                ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ]),
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Use ETB Coins to Flip a Card and get ETB Coins",
                                  style: TextStyle(fontSize: text_md),
                                ),
                                subtitle: Text(
                                  "50 ETB Coins for one chance",
                                ),
                                trailing: FlatButton(
                                    onPressed: () async {
                                      snap.data["etbCoins"] > 50
                                          ? await useCoinForSurprise()
                                          : Fluttertoast.showToast(
                                              msg: "Not enough Coins",
                                              toastLength: Toast.LENGTH_SHORT);
                                    },
                                    child: Text(
                                      "Try once",
                                      style: TextStyle(color: primaryColor),
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      flipCard(cardKey, coinsToCredit[0]),
                                      flipCard(cardKey2, coinsToCredit[1]),
                                      flipCard(cardKey3, coinsToCredit[2]),
                                    ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      flipCard(cardKey4, coinsToCredit[3]),
                                      flipCard(cardKey5, coinsToCredit[4]),
                                      flipCard(cardKey6, coinsToCredit[5]),
                                    ]),
                              ),

                              //

                              // GridView.count(
                              //   children: [
                              //     CacheImage(
                              //         "https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80"),
                              //     CacheImage(
                              //         "https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80"),
                              //     CacheImage(
                              //         "https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80"),
                              //     CacheImage(
                              //         "https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80"),
                              //   ],
                              //   padding: EdgeInsets.all(10),
                              //   crossAxisCount: 2,
                              //   shrinkWrap: true,
                              //   physics: NeverScrollableScrollPhysics(),
                              //   crossAxisSpacing: 5,
                              //   mainAxisSpacing: 5,
                              // )

                              // Text("Surprize Coming Soon!")
                            ],
                          );
                  }),
            ),
    );
  }
}
