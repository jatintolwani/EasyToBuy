import 'package:easytobuy/main_config.dart';
import 'package:flutter/material.dart';

class Terms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Terms and Conditions",
          style: TextStyle(fontSize: text_md),
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Text(
                "Conditions Relating to Your Use of ETB ( Easy To Buy )\n\n1. Your Account If you use the website, you are responsible for maintaining the confidentiality of your account and password and for restricting access to your computer to prevent unauthorised access to your account. You agree to accept responsibility for all activities that occur under your account or password. You should take all necessary steps to ensure that the password is kept confidential and secure and should inform us immediately if you have any reason to believe that your password has become known to anyone else, or if the password is being, or is likely to be, used in an unauthorised manner. Please ensure that the details you provide us with are correct and complete and inform us immediately of any changes to the information that you provided when registering.You agree and acknowledge that you will use your account on the website to purchase products only for your personal use and not for business purposes. ETB  reserves the right to refuse access to the website, terminate accounts, remove or edit content at any time without notice to you.\n\n2. Privacy\n Privacy Policy governs your visit to ETB, to understand our practices. The personal information / data provided to us by you during the course of usage of ETB will be treated as strictly confidential and in accordance with the Privacy Policy and applicable laws and regulations. If you object to your information being transferred or used, please do not use ETB.\n\n3. E-Platform for Communication\nYou agree, understand and acknowledge that the app is an online platform that enables you to purchase products listed on the app at the price indicated therein at any time from any location in India. You further agree and acknowledge that ETB is only a facilitator and is not and cannot be a party to or control in any manner any transactions on the app. Accordingly, the contract of sale of products on the website shall be a strictly bipartite contract between you and the sellers on ETB.\n\n4. Disclaimer\n You acknowledge and undertake that you are accessing the services on the app and transacting at your own risk and are using your best and prudent judgment before entering into any transactions through the app. You further acknowledge and undertake that you will use the app to order products only for your personal use and not for business purposes. We shall neither be liable nor responsible for any actions or inactions of sellers nor any breach of conditions, representations or warranties by the sellers or manufacturers of the products and hereby expressly disclaim and any all responsibility and liability in that regard. We shall not mediate or resolve any dispute or disagreement between you and the sellers or manufacturers of the products.By registering to ETB you are agreeing to never take any legal actions against ETB and the founder and co-founder of ETB.\n\n5. Losses\n We will not be responsible for any business loss (including loss of profits, revenue, contracts, anticipated savings, data, goodwill or wasted expenditure) or any other indirect or consequential loss that is not reasonably foreseeable to both you and us when you commenced using the app.\n\nTHANKS FOR BEING A PART OF ETB."),
          ),
        ),
      ),
    );
  }
}
