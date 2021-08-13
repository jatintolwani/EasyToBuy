import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/providers/orders_provider.dart';
import 'package:easytobuy/screens/contact_screen.dart';
import 'package:easytobuy/screens/order_screen.dart';
import 'package:easytobuy/screens/wallet_screen.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main_config.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser)
            .snapshots(),
        builder: (context, snap) => !snap.hasData
            ? Loading()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 7,
                      child: Container(
                        height: 230,
                        width: double.infinity,
                        color: primaryColor,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: accentColor,
                                child: Text(
                                  snap.data["name"][0].toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 40, color: primaryColor),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                snap.data["name"],
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                snap.data["phone"],
                                style: TextStyle(
                                    fontSize: text_md, color: accentColor),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                snap.data["email"],
                                style: TextStyle(
                                    fontSize: text_md, color: accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Wallet())),
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.account_balance_wallet_rounded),
                          title: Text("ETB Wallet"),
                          subtitle: Text("Manage your ETB Wallet"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AdminOrder())),
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.shopping_bag),
                          title: Text("My Orders"),
                          subtitle: Text("Check your all Orders here"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                          },
                          child: Text(
                            "Logout",
                            style: TextStyle(
                                fontSize: text_sm, color: primaryColor),
                          )))
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.support_agent_outlined),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Contact())),
      ),
    );
  }
}
