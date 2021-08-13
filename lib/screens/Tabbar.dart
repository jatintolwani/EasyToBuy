import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/screens/productListing_screen.dart';
import 'package:flutter/material.dart';

class TabBarForGenders extends StatelessWidget {
  var cat;
  TabBarForGenders(this.cat);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          bottom: TabBar(
            indicatorColor: primaryColor,
            tabs: [
              Tab(text: "Men"),
              Tab(text: "Women"),
            ],
          ),
          title: Text(cat),
        ),
        body: TabBarView(
          children: [
            ProductListing(cat, "Men"),
            ProductListing(cat, "Women"),
          ],
        ),
      ),
    );
  }
}
