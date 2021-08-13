import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/screens/addCoupon_screen.dart';
import 'package:easytobuy/screens/addProduct_screen.dart';
import 'package:easytobuy/screens/deleteCoupon_screen.dart';
import 'package:easytobuy/screens/deleteSlider.dart';
import 'package:easytobuy/screens/editDeleteProduct_screen.dart';
import 'package:easytobuy/screens/slider.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  var oldContext;
  MainDrawer(this.oldContext);
  drawerTile(context, text, widgetToShow) {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => widgetToShow));
        },
        child: ListTile(
            title: Text(
          text,
          style: TextStyle(fontSize: text_md),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            "ETB",
            style: TextStyle(fontSize: text_md),
          ),
        ),
        body: Column(
          children: [
            drawerTile(context, "Add Slider", AddSlider()),
            drawerTile(context, "Delete Slider", DeleteSlider()),
            drawerTile(context, "Add Coupon", AddCoupon()),
            drawerTile(context, "Delete Coupon", DeleteCoupon()),
            drawerTile(context, "Add Product", AddProduct(false)),
            drawerTile(context, "Edit Product", EditDelete()),
          ],
        ));
  }
}
