import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/screens/cart_screen.dart';
import 'package:easytobuy/screens/home_screen.dart';
import 'package:easytobuy/screens/profile_screen.dart';
import 'package:easytobuy/widgets/drawer.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  List<Widget> pages = [
    Home(sliders),
    CartScreen(
      fromBuyScreen: false,
    ),
    Profile()
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static var sliders = [];
  var isLoading = false;
  getSliders() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("Slider")
          .orderBy("when", descending: true)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          sliders.add(element["ImgId"]);
        });
      });
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

  void initState() {
    super.initState();
    getSliders();
    currentUser = FirebaseAuth.instance.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    print(admins);
    print(currentUser);
    return Scaffold(
      drawer: admins.contains(currentUser)
          ? Drawer(
              child: MainDrawer(context),
              elevation: 7,
            )
          : null,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 55,
            width: 55,
            padding: EdgeInsets.all(10),
            child: Image.asset(
              "lib/assets/images/logo.png",
              fit: BoxFit.contain,
            ),
          ),
          Text(
            "Easy To Buy",
            style: TextStyle(fontSize: text_md),
          ),
        ]),
      ),
      body: isLoading ? Loading() : pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
              size: 30,
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
