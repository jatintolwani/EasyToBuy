import 'package:easytobuy/main_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class Developer extends StatelessWidget {
  Future<void> _launchURL(BuildContext context, url) async {
    final theme = Theme.of(context);
    try {
      await launch(
        url,
        option: CustomTabsOption(
          toolbarColor: theme.primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          extraCustomTabs: const <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor,
      appBar: AppBar(
        title: Text(
          "Developer Contact",
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
              height: 220,
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
                          CircleAvatar(
                            backgroundColor: accentColor,
                            backgroundImage: NetworkImage(
                                "https://firebasestorage.googleapis.com/v0/b/easytobuy-b2dea.appspot.com/o/Developer%2FIMG-20210508-WA0062.jpg?alt=media&token=d14a5cca-1702-45c2-9bc8-83429c6b0fc1"),
                            radius: 35,
                          ),
                          Center(
                            child: Text(
                              "Jesswin Chetnani",
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
                      margin: EdgeInsets.only(top: 10),
                      child: Container(
                        margin: EdgeInsets.only(left: 2),
                        child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          color: accentColor,
                          onPressed: () {
                            _launchURL(context,
                                "https://jesswindevelops.netlify.app/");
                          },
                          icon: Icon(
                            Icons.link,
                            size: 20,
                          ),
                          splashColor: primaryColor,
                          label: Text(
                            "https://jesswindevelops.netlify.app/",
                            style: TextStyle(fontSize: text_xsm),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 220,
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
                          CircleAvatar(
                            backgroundColor: accentColor,
                            backgroundImage: NetworkImage(
                                "https://firebasestorage.googleapis.com/v0/b/easytobuy-b2dea.appspot.com/o/Developer%2FWhatsApp%20Image%202021-06-17%20at%2012.36.34%20AM.jpeg?alt=media&token=bbef2a88-9668-452c-a6fa-7b2568c60fb6"),
                            radius: 35,
                          ),
                          Center(
                            child: Text(
                              "Jatin Tolwani",
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
                      margin: EdgeInsets.only(top: 10),
                      child: Container(
                        margin: EdgeInsets.only(left: 2),
                        child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          color: accentColor,
                          onPressed: () {
                            _launchURL(
                                context, "https://jatin-tolwani.netlify.app/");
                          },
                          icon: Icon(
                            Icons.link,
                            size: 20,
                          ),
                          splashColor: primaryColor,
                          label: Text(
                            "https://jatin-tolwani.netlify.app/",
                            style: TextStyle(fontSize: text_xsm),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
