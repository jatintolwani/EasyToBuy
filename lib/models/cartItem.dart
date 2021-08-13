class CartItem {
  var productID;
  var productName;
  var productImg;
  var productRegPrice;
  var productOurPrice;
  var productDiscount;
  var productQuantity;
  var productRegTotalPrice;
  var productTotalPrice;
  var productTotalDiscount;
  var productCat;
  var qAvailable;
  var gender;
  var clothSize;

  CartItem(
      {this.productID,
      this.productName,
      this.productImg,
      this.productRegPrice,
      this.productOurPrice,
      this.productDiscount,
      this.productQuantity,
      this.productRegTotalPrice,
      this.productTotalPrice,
      this.productTotalDiscount,
      this.qAvailable,
      this.productCat,
      this.gender,
      this.clothSize});
}

class Cart {
  var prodID;
  var quantity;
  var cat;
  var size;
  Cart(this.prodID, this.quantity, this.cat, [this.size]);
}
