import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as Path;

class DeleteSlider extends StatefulWidget {
  @override
  _DeleteSliderState createState() => _DeleteSliderState();
}

class _DeleteSliderState extends State<DeleteSlider> {
  String dropdownValue = 'Slider';
  File img;
  FToast fToast;
  var names = [
    "Slider",
  ];
  var images = [
    "https://firebasestorage.googleapis.com/v0/b/easytobuy-b2dea.appspot.com/o/Slider%2Fdata%2Fuser%2F0%2Fcom.easytobuy.easytobuy%2Fcache%2Fimage_picker2708221823034657889.jpg.jpg?alt=media&token=15dfeec3-5e67-49cf-80d7-1ac1752006b3"
  ];
  var ids = ["0"];

  var isLoading = false;
  var index = 0;

  getImges() async {
    names.clear();
    images.clear();
    ids.clear();
    setState(() {
      isLoading = true;
    });
    names.add("Slider");
    images.add(
        "https://firebasestorage.googleapis.com/v0/b/easytobuy-b2dea.appspot.com/o/Slider%2Fdata%2Fuser%2F0%2Fcom.easytobuy.easytobuy%2Fcache%2Fimage_picker2708221823034657889.jpg.jpg?alt=media&token=15dfeec3-5e67-49cf-80d7-1ac1752006b3");
    ids.add("0");
    try {
      await FirebaseFirestore.instance.collection("Slider").get().then((value) {
        value.docs.forEach((element) {
          names.add(element["name"]);
          images.add(element["ImgId"]);
          ids.add(element["id"]);
        });
      });
      print(names);
      print(images);
      print(ids);
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

  toast(text) {
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2));
  }

  delete(id, link) async {
    print(id);
    print(link);
    print(dropdownValue);
    if (dropdownValue == "Slider") {
      toast("Please Select a File");
    } else {
      setState(() {
        isLoading = true;
      });

      //delete Filename
      await FirebaseFirestore.instance.collection("Slider").doc(id).delete();
      names.remove(dropdownValue);
      dropdownValue = "Slider";
      images.remove(link);
      ids.remove(id);
      print(names);
      toast("Slider Deleted");
      index = 0;

      //delete image
      String fileUrl = Uri.decodeFull(Path.basename(link))
          .replaceAll(RegExp(r'(\?alt).*'), '');
      try {
        Reference ref = FirebaseStorage.instance.ref().child(fileUrl);
        await ref.delete();
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
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    getImges();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GestureDetector(
        onTap: () {
          delete(ids[index], images[index]);
        },
        child: Container(
          margin: EdgeInsets.all(10),
          width: 100,
          height: 50,
          color: primaryColor,
          child: Center(
            child: Text(
              "Delete",
              style: TextStyle(color: accentColor, fontSize: text_md),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Delete Slider"),
      ),
      body: isLoading
          ? Loading()
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(100),
                      width: double.infinity,
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(null),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black),
                        underline: Container(
                          height: 2,
                          color: Colors.black,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue = newValue;
                            index = names.indexOf(newValue);
                            print(index);
                          });
                        },
                        items:
                            names.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
