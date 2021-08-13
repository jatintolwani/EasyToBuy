import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/screens/developerContact_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailto/mailto.dart';

class Contact extends StatelessWidget {
  void _contact() async {
    final url = Mailto(to: ['easytobuyetb@gmail.com']);
    await launch('$url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      appBar: AppBar(
        title: Text(
          "Contact Us",
          style: TextStyle(fontSize: text_md),
        ),
        backgroundColor: primaryColor,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              padding: new EdgeInsets.all(20.0),
              child: Card(
                color: primaryColor,
                elevation: 10,
                shadowColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Center(
                            child: Text(
                              "Bhavesh Jagnani (Founder)",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 2,
                        top: 10,
                      ),
                      child: Text("+91 9624367254",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: 18)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Container(
                        margin: EdgeInsets.only(left: 2),
                        child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          color: accentColor,
                          onPressed: () {
                            _contact();
                          },
                          icon: Icon(Icons.mail),
                          splashColor: primaryColor,
                          label: Text("easytobuyetb@gmail.com"),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 2,
                        top: 10,
                      ),
                      child: Text("Follow us on Telegram",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: text_md)),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 2,
                        top: 10,
                      ),
                      child: Text("Bhavesh Jagnani",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: text_md)),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              padding: new EdgeInsets.all(20.0),
              child: Card(
                color: primaryColor,
                elevation: 10,
                shadowColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Center(
                            child: Text(
                              "Pranav Tiwari (Co-Founder)",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 2,
                        top: 10,
                      ),
                      child: Text("+91 7575896860",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: 18)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Container(
                        margin: EdgeInsets.only(left: 2),
                        child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: accentColor,
                          onPressed: () {
                            _contact();
                          },
                          icon: Icon(Icons.mail),
                          splashColor: primaryColor,
                          label: Text("easytobuyetb@gmail.com"),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 2,
                        top: 10,
                      ),
                      child: Text("Follow us on Telegram",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: text_md)),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 2,
                        top: 10,
                      ),
                      child: Text("Pranav Tiwari",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: text_md)),
                    ),
                  ],
                ),
              ),
            ),
            // Text("Developer Contact",
            //     style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         color: Colors.black,
            //         fontSize: text_xl)),
            // GestureDetector(
            //   onTap: () => Navigator.of(context)
            //       .push(MaterialPageRoute(builder: (context) => Developer())),
            //   child: Card(
            //       child: ListTile(
            //     leading: CircleAvatar(
            //       radius: 30,
            //       backgroundImage: NetworkImage(
            //           "https://firebasestorage.googleapis.com/v0/b/easytobuy-b2dea.appspot.com/o/Developer%2Fdev.png?alt=media&token=1720e00f-8ecd-4c4f-bc38-0f743ad3f84f"),
            //     ),
            //     title: Text("J SQUARE",
            //         style: TextStyle(
            //             fontWeight: FontWeight.normal,
            //             color: primaryColor,
            //             fontSize: text_xl)),
            //     subtitle: Text("j.square0625@gmail.com"),
            //     trailing: Icon(
            //       Icons.arrow_forward_ios,
            //       color: primaryColor,
            //     ),
            //   )),
            // ),
          ],
        ),
      ),
    );
  }
}
