import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easytobuy/main_config.dart';
import 'package:easytobuy/widgets/loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_select/smart_select.dart';

class AddProduct extends StatefulWidget {
  var edit;
  var id;
  var category;
  AddProduct(this.edit, {this.id, this.category});
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  List<Asset> resultList = <Asset>[];
  List<File> fileFromAssets = [];
  List imageuUrl = [];
  final __formkey = GlobalKey<FormState>();
  var dropDown = "Used Mobiles";
  var clothType = "Men";
  var isLoading = false;
  var productName = TextEditingController();
  var regularPrice = TextEditingController();
  var ourPrice = TextEditingController();
  var description = TextEditingController();
  var qAvailable = TextEditingController();
  var categories = [];

  var productNameSearchKeys;
  var temp;
  var sizes = [
    S2Choice<String>(value: "S", title: "S"),
    S2Choice<String>(value: "M", title: "M"),
    S2Choice<String>(value: "L", title: "L"),
    S2Choice<String>(value: "XL", title: "XL"),
    S2Choice<String>(value: "XXL", title: "XXL"),
    S2Choice<String>(value: "28", title: "28"),
    S2Choice<String>(value: "30", title: "30"),
    S2Choice<String>(value: "32", title: "32"),
    S2Choice<String>(value: "34", title: "34"),
    S2Choice<String>(value: "36", title: "36"),
    S2Choice<String>(value: "38", title: "38"),
    S2Choice<String>(value: "5", title: "5"),
    S2Choice<String>(value: "6", title: "6"),
    S2Choice<String>(value: "7", title: "7"),
    S2Choice<String>(value: "8", title: "8"),
    S2Choice<String>(value: "9", title: "9"),
    S2Choice<String>(value: "10", title: "10"),
  ];
  var selectedSizes = [];
  List<String> value = [];

  var categoriesWithSize = ["Fashion", "Shoes"];

  Widget box() {
    return SizedBox(
      height: 20,
    );
  }

  toast(text) {
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(
        seconds: 1,
      ),
    );
  }

  getUserKeys() {
    productNameSearchKeys = [];
    temp = "";
    var pprodName = "";
    pprodName = productName.text.trim().toLowerCase();
    for (var i = 0; i < pprodName.length; i++) {
      temp = temp + pprodName[i];
      productNameSearchKeys.add(temp);
    }
    print(productNameSearchKeys);
  }

  save() async {
    print(selectedSizes);
    print("fuk u");
    print(dropDown);
    if (categoriesWithSize.contains(dropDown) && selectedSizes.isEmpty) {
      toast("Select Sizes");
      return;
    }
    if (__formkey.currentState.validate()) {
      __formkey.currentState.save();
      if (resultList.length == 0) {
        toast("Select Images");
      } else {
        setState(() {
          isLoading = true;
        });
        for (var i = 0; i < fileFromAssets.length; i++) {
          print(fileFromAssets);
          try {
            var ref = FirebaseStorage.instance
                .ref()
                .child(dropDown)
                .child(fileFromAssets[i].path + DateTime.now().toString());
            await ref.putFile(fileFromAssets[i]);
            final url = await ref.getDownloadURL();
            imageuUrl.add(url);
          } catch (err) {
            setState(() {
              isLoading = false;
            });
            print(err);
          }
        }
        getUserKeys();
        var discount = int.parse(regularPrice.text) - int.parse(ourPrice.text);
        print(discount);
        try {
          var id = FirebaseFirestore.instance.collection(dropDown).doc().id;
          if (categoriesWithSize.contains(dropDown)) {
            await FirebaseFirestore.instance.collection(dropDown).doc(id).set({
              "productName": productName.text.trim().toLowerCase(),
              "gender": clothType,
              "sizesAvailable": selectedSizes,
              "regularPrice": int.parse(regularPrice.text.trim()),
              "ourPrice": int.parse(ourPrice.text.trim()),
              "description": description.text.trim(),
              "productId": id,
              "sliderImages": imageuUrl,
              "discount": discount,
              "qAvailable": int.parse(qAvailable.text),
              "when": DateTime.now(),
            });
          } else {
            await FirebaseFirestore.instance.collection(dropDown).doc(id).set({
              "productName": productName.text.trim().toLowerCase(),
              "regularPrice": int.parse(regularPrice.text.trim()),
              "ourPrice": int.parse(ourPrice.text.trim()),
              "description": description.text.trim(),
              "productId": id,
              "sliderImages": imageuUrl,
              "discount": discount,
              "qAvailable": int.parse(qAvailable.text),
              "when": DateTime.now(),
            });
          }
          await FirebaseFirestore.instance
              .collection("SearchKeys")
              .doc(id)
              .set({
            "productId": id,
            "category": dropDown,
            "productName": productName.text.trim().toLowerCase(),
            "searchKeys": productNameSearchKeys,
            "when": DateTime.now(),
          });
          print(imageuUrl);
        } catch (err) {
          setState(() {
            isLoading = false;
          });
          print(err);
        }
      }
      setState(() {
        isLoading = false;
        productName.clear();
        regularPrice.clear();
        ourPrice.clear();
        description.clear();
        imageuUrl.clear();
        resultList.clear();
        qAvailable.clear();
        print(imageuUrl);
      });
      toast("Product Added");
    }
  }

  saveEdited() async {
    print("YEAHHHHH");
    if (__formkey.currentState.validate()) {
      __formkey.currentState.save();
      setState(() {
        isLoading = true;
      });
      getUserKeys();
      var discount = int.parse(regularPrice.text) - int.parse(ourPrice.text);
      print(discount);
      try {
        await FirebaseFirestore.instance
            .collection(dropDown)
            .doc(widget.id)
            .update({
          "productName": productName.text.trim().toLowerCase(),
          "regularPrice": int.parse(regularPrice.text.trim()),
          "ourPrice": int.parse(ourPrice.text.trim()),
          "description": description.text.trim(),
          "discount": discount,
          "qAvailable": int.parse(qAvailable.text),
        });
        await FirebaseFirestore.instance
            .collection("SearchKeys")
            .doc(widget.id)
            .update({
          "productName": productName.text.trim().toLowerCase(),
          "searchKeys": productNameSearchKeys,
        });
      } catch (err) {
        setState(() {
          isLoading = false;
        });

        print(err);
      }

      setState(() {
        isLoading = false;
        productName.clear();
        regularPrice.clear();
        ourPrice.clear();
        description.clear();
        imageuUrl.clear();
        resultList.clear();
        print(imageuUrl);
      });
      toast("Product Updated");
      Navigator.pop(context);
    }
  }

  getImageFileFromAssets(Asset asset) async {
    final byteData = await asset.getByteData();
    final tempFile =
        File("${(await getTemporaryDirectory()).path}/${asset.name}");
    final file = await tempFile.writeAsBytes(
      byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    fileFromAssets.add(file);
    return fileFromAssets;
  }

  pickImages() async {
    resultList.clear();
    print(resultList);
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 6,
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarColor: "#55ACEE",
          actionBarTitle: "Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e.toString());
    }
    setState(() {});
    fileFromAssets.clear();
    for (var i = 0; i < resultList.length; i++) {
      await getImageFileFromAssets(resultList[i]);
      print(fileFromAssets);
    }
  }

  getDataToEdit() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection(widget.category)
          .doc(widget.id)
          .get()
          .then((value) {
        productName.text = value["productName"];
        regularPrice.text = value["regularPrice"].toString();
        ourPrice.text = value["ourPrice"].toString();
        description.text = value["description"];
        qAvailable.text = value["qAvailable"].toString();
        dropDown = widget.category;
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

  FToast fToast;
  getCategories() {
    if (currentUser == admin) {
      categories = [
        "Used Mobiles",
        "Global Mobiles",
        "New Mobiles",
        "Mobile Accessories",
        "Add Ons",
        "Fashion",
        "Shoes",
        "Watches",
        "Laptops & Accessories",
        "Offers"
      ];
      dropDown = "Used Mobiles";
    } else if (currentUser == etbShoesWatches) {
      categories = ["Shoes", "Watches"];
      dropDown = "Shoes";
    } else if (currentUser == etbClothes) {
      categories = [
        "Fashion",
      ];
      dropDown = "Fashion";
    } else if (currentUser == etbMobiles) {
      categories = [
        "Used Mobiles",
        "Global Mobiles",
        "New Mobiles",
      ];
      dropDown = "Used Mobiles";
    } else if (currentUser == etbAccessories) {
      categories = [
        "Mobile Accessories",
      ];
      dropDown = "Mobile Accessories";
    } else if (currentUser == etbLaptop) {
      categories = [
        "Laptop & Laptop Accessories",
      ];
      dropDown = "Laptop & Laptop Accessories";
    }
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    print("inittt");
    if (widget.edit) {
      getDataToEdit();
    }
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Add Product",
          style: TextStyle(fontSize: text_md),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.save,
              ),
              onPressed: () => widget.edit ? saveEdited() : save())
        ],
      ),
      body: isLoading
          ? Loading()
          : SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  key: __formkey,
                  child: Column(
                    children: [
                      TextFormField(
                          controller: productName,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1),
                            ),
                            hintText: "Product Name",
                          ),
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Enter a Valid Name";
                            }
                            return null;
                          }),
                      box(),
                      TextFormField(
                          controller: qAvailable,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1),
                            ),
                            hintText: "Product Quantity",
                          ),
                          validator: widget.edit
                              ? (val) {
                                  if (val.isEmpty) {
                                    return "Enter a Valid Quantity";
                                  }
                                  return null;
                                }
                              : (val) {
                                  if (val.isEmpty) {
                                    return "Enter a Valid Quantity";
                                  } else if (int.parse(val) <= 0) {
                                    return "Quantity Should Greater Than 0";
                                  }
                                  return null;
                                }),
                      box(),
                      widget.edit
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Category",
                                  style: TextStyle(fontSize: text_md),
                                ),
                                DropdownButton(
                                  value: dropDown,
                                  onChanged: (newValue) {
                                    setState(() {
                                      dropDown = newValue;
                                    });
                                  },
                                  items: categories.map((cat) {
                                    return DropdownMenuItem(
                                      child: Text(
                                        cat,
                                        style: TextStyle(fontSize: text_md),
                                      ),
                                      value: cat,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                      widget.edit
                          ? Container()
                          : categoriesWithSize.contains(dropDown)
                              ? Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Men",
                                        style: TextStyle(fontSize: text_md),
                                      ),
                                      Radio(
                                          value: "Men",
                                          groupValue: clothType,
                                          onChanged: (val) {
                                            setState(() {
                                              clothType = val;
                                            });
                                          }),
                                      Text("Women",
                                          style: TextStyle(fontSize: text_md)),
                                      Radio(
                                          value: "Women",
                                          groupValue: clothType,
                                          onChanged: (val) {
                                            setState(() {
                                              clothType = val;
                                            });
                                          })
                                    ],
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SmartSelect<String>.multiple(
                                          title: 'Sizes',
                                          modalType: S2ModalType.popupDialog,
                                          value: value,
                                          choiceItems: sizes,
                                          onChange: (state) {
                                            setState(() => value = state.value);
                                            selectedSizes = state.value;
                                            selectedSizes.removeWhere(
                                                (element) => element == "");
                                            selectedSizes.sort();
                                            print(selectedSizes);
                                          }))
                                ])
                              : box(),
                      Row(
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: regularPrice,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: primaryColor, width: 2.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: primaryColor, width: 1),
                                  ),
                                  hintText: "Regular Price",
                                ),
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return "Enter a Valid Price";
                                  } else if (int.parse(val) <= 0) {
                                    return "Price should be greater than 0";
                                  }
                                  return null;
                                }),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: ourPrice,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: primaryColor, width: 2.5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: primaryColor, width: 1),
                                  ),
                                  hintText: "Our Price",
                                ),
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return "Enter a Valid Price";
                                  } else if (int.parse(val) <= 0) {
                                    return "Price should be greater than 0";
                                  }
                                  return null;
                                }),
                          ))
                        ],
                      ),
                      box(),
                      resultList.isEmpty
                          ? Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(color: primaryColor)),
                              child: Center(
                                  child: Text(
                                "Select Images",
                                style: TextStyle(fontSize: text_md),
                              )),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: primaryColor)),
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                children:
                                    List.generate(resultList.length, (index) {
                                  Asset asset = resultList[index];
                                  // print(asset);
                                  return AssetThumb(
                                    asset: asset,
                                    width: 300,
                                    height: 300,
                                  );
                                }),
                              ),
                            ),
                      box(),
                      Container(
                        child: RaisedButton(
                            color: primaryColor,
                            onPressed: widget.edit ? null : () => pickImages(),
                            child: Text(
                              "Select Images",
                              style: TextStyle(
                                  color: accentColor, fontSize: text_sm),
                            )),
                      ),
                      box(),
                      TextFormField(
                          controller: description,
                          maxLines: 5,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 2.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1),
                            ),
                            hintText: "Description",
                          ),
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Enter a Valid Description";
                            }
                            return null;
                          }),
                    ],
                  )),
            )),
    );
  }
}
