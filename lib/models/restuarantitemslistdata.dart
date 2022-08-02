class Restuarantitemslistdata {
  int errorCode;
  String errorMessage;
  List<Response> response;

  Restuarantitemslistdata({this.errorCode, this.errorMessage, this.response});

  Restuarantitemslistdata.fromJson(Map<String, dynamic> json) {
    errorCode = json['ErrorCode'];
    errorMessage = json['ErrorMessage'];
    if (json['Response'] != null) {
      response = <Response>[];
      json['Response'].forEach((v) {
        response.add(new Response.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrorCode'] = this.errorCode;
    data['ErrorMessage'] = this.errorMessage;
    if (this.response != null) {
      data['Response'] = this.response.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Response {
  int id;
  String name;
  String image;
  bool selected;
  List<Items> items;

  Response({this.id, this.name, this.image, this.items, this.selected});

  Response.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    selected = false;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['selected'] = this.selected;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  int id;
  String productName;
  String productImage;
  String mrp;
  String discount;
  String itemType;
  String shortDescription;
  String longDescription;
  String addonStatus;
  String discountPercentage;
  int quantity;
  bool selected;

  Items(
      {this.id,
        this.productName,
        this.productImage,
        this.mrp,
        this.discount,
        this.itemType,
        this.shortDescription,
        this.longDescription,
        this.addonStatus,
        this.discountPercentage,
        this.quantity, this.selected});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['product_name'];
    productImage = json['product_image'];
    mrp = json['mrp'];
    discount = json['discount'];
    itemType = json['item_type'];
    shortDescription = json['short_description'];
    longDescription = json['long_description'];
    addonStatus = json['addon_status'].toString();
    discountPercentage = (json['discount_percentage']).toString();
    quantity = json['quantity'];
    selected = json['selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_name'] = this.productName;
    data['product_image'] = this.productImage;
    data['mrp'] = this.mrp;
    data['discount'] = this.discount;
    data['item_type'] = this.itemType;
    data['short_description'] = this.shortDescription;
    data['long_description'] = this.longDescription;
    data['addon_status'] = this.addonStatus;
    data['discount_percentage'] = this.discountPercentage;
    data['quantity'] = this.quantity;
    data['selected'] = this.selected;
    return data;
  }
}