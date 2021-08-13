import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/screens/bottomBar.dart';
import 'package:flutter/material.dart';

class OrderConfirmPage extends StatefulWidget {
  var coinsEarned = 0;
  OrderConfirmPage(this.coinsEarned);
  @override
  _OrderConfirmPageState createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  ConfettiController _controllerCenter;
  ConfettiController _controllerCenterRight;
  ConfettiController _controllerCenterLeft;
  ConfettiController _controllerTopCenter;
  ConfettiController _controllerBottomCenter;

  @override
  void initState() {
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenterRight =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenterRight.play();
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    _controllerCenterRight.dispose();
    _controllerCenterLeft.dispose();
    _controllerTopCenter.dispose();
    _controllerBottomCenter.dispose();
    super.dispose();
  }

  // Path drawStar(Size size) {
  //   // Method to convert degree to radians
  //   double degToRad(double deg) => deg * (pi / 180.0);

  //   const numberOfPoints = 5;
  //   final halfWidth = size.width / 2;
  //   final externalRadius = halfWidth;
  //   final internalRadius = halfWidth / 2.5;
  //   final degreesPerStep = degToRad(360 / numberOfPoints);
  //   final halfDegreesPerStep = degreesPerStep / 2;
  //   final path = Path();
  //   final fullAngle = degToRad(360);
  //   path.moveTo(size.width, halfWidth);

  //   for (double step = 0; step < fullAngle; step += degreesPerStep) {
  //     path.lineTo(halfWidth + externalRadius * cos(step),
  //         halfWidth + externalRadius * sin(step));
  //     path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
  //         halfWidth + internalRadius * sin(step + halfDegreesPerStep));
  //   }
  //   path.close();
  //   return path;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        width: double.infinity,
        height: 60,
        child: RaisedButton(
          color: primaryColor,
          onPressed: () => {Navigator.of(context).pop()},
          child: Text(
            "Continue Shopping",
            style: TextStyle(color: Colors.white, fontSize: text_md),
          ),
        ),
      ),
      body: Container(
        color: primaryColor,
        child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                height: 200,
                child: Column(
                  children: [
                    _display('\nYour Order has been Placed 🎉'),
                    _display('\nYou can check it in "My Orders"'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Your Order will be Shipped in 24 Hours.",
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("ETB Coins Earned -  ${widget.coinsEarned}",
                                style: TextStyle(
                                  color: coinColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            Image.asset(
                              "lib/assets/images/coin.png",
                              height: 20,
                              width: 20,
                              fit: BoxFit.cover,
                            )
                          ]),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _controllerCenterRight,
                blastDirection: pi / 2, // radial value - LEFT
                particleDrag: 0.05, // apply drag to the confetti
                emissionFrequency: 0.05, // how often it should emit
                numberOfParticles: 20, // number of particles to emit
                gravity: 0.1, // gravity - or fall speed
                shouldLoop: false,
                colors: [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.amber,
                ], // manually specify the colors to be used
                // createParticlePath: drawStar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Text _display(String text) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.white, fontSize: text_md, fontWeight: FontWeight.bold),
    );
  }
}
