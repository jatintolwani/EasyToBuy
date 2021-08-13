import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddSlider extends StatefulWidget {
  @override
  _AddSliderState createState() => _AddSliderState();
}

class _AddSliderState extends State<AddSlider> {
  var pickedImageFile;
  File img;
  final imagePicker = ImagePicker();
  bool isLoading = false;
  var nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var result;
  var fileName;

  FToast fToast;

  _pickImage() async {
    pickedImageFile = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      img = File(pickedImageFile.path);
    });
  }

  _addSlider() async {
    if (pickedImageFile == null) {
      fToast.removeQueuedCustomToasts();
      fToast.showToast(
          child: Text(
            "Please Select File",
            style: TextStyle(fontSize: 20),
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2));
    }
    try {
      setState(() {
        isLoading = true;
      });
      var ref = FirebaseStorage.instance
          .ref()
          .child('Slider')
          .child(pickedImageFile.path + '.jpg');
      await ref.putFile(img);
      final url = await ref.getDownloadURL();
      var id = FirebaseFirestore.instance.collection('Slider').doc().id;
      FirebaseFirestore.instance.collection('Slider').doc(id).set({
        'name': nameController.text,
        'ImgId': url,
        "when": DateTime.now(),
        "id": id
      });

      fToast.removeQueuedCustomToasts();
      fToast.showToast(
          child: Text(
            "Slider Added",
            style: TextStyle(fontSize: 20),
          ),
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 2));
      pickedImageFile = null;
      img = null;
      nameController.clear();
    } catch (err) {
      setState(() {
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget textField() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 2.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 1),
            ),
            hintText: "Name",
          ),
          validator: (value) {
            if (value.length == 0) {
              return 'Enter a Valid Name';
            }
            return null;
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Add Slider"),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _addSlider();
                }
              })
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: isLoading
              ? Container(
                  height: 500,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: pickedImageFile != null
                          ? Container(
                              child: Image.file(
                              img,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ))
                          : Text(
                              "No Image Taken",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                      alignment: Alignment.center,
                    ),
                    FlatButton.icon(
                      icon: Icon(
                        Icons.photo,
                        color: primaryColor,
                      ),
                      label: Text(
                        "Select Picture",
                        style: TextStyle(
                          fontSize: text_md,
                          color: primaryColor,
                        ),
                      ),
                      onPressed: () => _pickImage(),
                    ),
                    textField(),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
