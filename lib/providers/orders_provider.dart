import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/models/cartItem.dart';
import 'package:easytobuy/models/coupon.dart';
import 'package:flutter/widgets.dart';

import '../main_config.dart';

class OrderItems {
  List<CartItem> cartItems;
  var cartTotal;
  var cartDiscount;
  var listingPrice;
  OrderItems(
      this.cartItems, this.cartTotal, this.cartDiscount, this.listingPrice);
}

class Orders with ChangeNotifier {
  OrderItems allItems;
  Coupon saveCoupon;
  var amountToPay;
  List usedCouponNames;
  var etbCoins = 0;

  storeData(OrderItems data) {
    // print(allItems.cartTotal);
    allItems = data;
    print(allItems.cartTotal);
  }

  storeCoupon(aPay, [Coupon coupon]) {
    saveCoupon = coupon;
    print(aPay);
    print("YEAYEAYEA");
    amountToPay = aPay;
  }

  storeUsedCoupons(uCoupons) {
    print(uCoupons);
    usedCouponNames = uCoupons;
  }

  OrderItems retrieveData() {
    return allItems;
  }

  retrieveCoupon() {
    print(amountToPay);
    return [saveCoupon, amountToPay];
  }

  retrieveUsedCoupon() async {
    // print(usedCouponNames.isEmpty);
    if (usedCouponNames == [] || usedCouponNames == null) {
      print(usedCouponNames);
      print("IF");
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .get()
          .then((value) {
        usedCouponNames = value["usedCoupons"];
      });
      return usedCouponNames;
    } else {
      print(usedCouponNames);
      print("ELse");
      return usedCouponNames;
    }
  }

  getCoins() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser)
        .get()
        .then((value) {
      etbCoins = value["etbCoins"];
    });
    print(etbCoins);
  }

  var recents = [];
  var cats = [];
  var isLoading = false;
  List<CartItem> items = [];
  getRecents() async {
    print("RECET");
    recents.clear();
    cats.clear();
    items.clear();
    isLoading = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser)
          .collection("Recents")
          .orderBy("when", descending: true)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          recents.add(element["prodId"]);
          cats.add(element["cat"]);
        });
      });
      print(recents);
      print(cats);
      print(recents.length);
      print(cats.length);
      for (var i = 0; i < recents.length; i++) {
        await FirebaseFirestore.instance
            .collection(cats[i])
            .doc(recents[i])
            .get()
            .then((value) {
          items.add(CartItem(
            productID: value["productId"],
            productCat: cats[i],
            productImg: value["sliderImages"][0],
            productName: value["productName"],
            productOurPrice: value["ourPrice"],
            productDiscount: value["discount"],
            productRegTotalPrice: value["regularPrice"],
            productRegPrice: value["regularPrice"],
            productTotalPrice: value["ourPrice"],
            qAvailable: value["qAvailable"],
            productTotalDiscount: value["discount"],
          ));
        });
      }
      // print(items[0].productCat);
      // print(items[1].productCat);
      // print(items[2].productCat);
      // print(items[3].productCat);
      // print(items[4].productCat);
    } catch (err) {
      print(err);
      isLoading = false;
      notifyListeners();
    }
    await getCoins();
    notifyListeners();
    isLoading = false;
  }
}
