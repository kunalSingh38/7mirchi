import 'package:flutter/material.dart';
// import 'package:barcode_scan/barcode_scan.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {

  /*Future scanLocateProduct() async {
    var options = ScanOptions(
      strings: {
        "cancel": 'Cancel',
        "flash_on": 'Flash on',
        "flash_off": 'Flash off',
      },
      useCamera: -1,
      android: AndroidOptions(
        useAutoFocus: true,
      ),
    );

    var result = await BarcodeScanner.scan(options: options);
    if (result.type.toString() == 'Barcode') {
      Navigator.pushNamed(
        context,
        '/locate-product',
        arguments: <String, String>{
          'barcode': result.rawContent.toString(),
        },
      );
      //Navigator.pushNamed(context,'/locate-product');
    }
  }*/

 /* Future scanShelfOffers() async {
    var options = ScanOptions(
      strings: {
        "cancel": 'Cancel',
        "flash_on": 'Flash on',
        "flash_off": 'Flash off',
      },
      useCamera: -1,
      android: AndroidOptions(
        useAutoFocus: true,
      ),
    );

    var result = await BarcodeScanner.scan(options: options);
    if (result.type.toString() == 'Barcode') {
      Navigator.pushNamed(
        context,
        '/shelf-offers',
        arguments: <String, String>{
          'shelf_id': result.rawContent.toString(),
        },
      );
      //Navigator.pushNamed(context,'/shelf-offers');
    }
  }*/

 /* Future scanBestPrice() async {
    var options = ScanOptions(
      strings: {
        "cancel": 'Cancel',
        "flash_on": 'Flash on',
        "flash_off": 'Flash off',
      },
      useCamera: -1,
      android: AndroidOptions(
        useAutoFocus: true,
      ),
    );

    var result = await BarcodeScanner.scan(options: options);
    if (result.type.toString() == 'Barcode') {
      Navigator.pushNamed(
        context,
        '/best-price',
        arguments: <String, String>{
          'barcode': result.rawContent.toString(),
        },
      );
      //Navigator.pushNamed(context,'/best-price');
    }
  }*/

  Widget _locateProduct() {
    return InkWell(
      onTap: () {
        //scanLocateProduct();
        Navigator.pushNamed(context,'/locate-product-new');
      },
      child: Container(
        margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey[400],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Text(
              "Locate Product",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
                "Lorem Ipsum is simply dummy text of the typesetting industry."),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Icon(
              Icons.location_searching,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _shelfOffers() {
    return InkWell(
      onTap: () {
        //scanShelfOffers();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey[400],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Text(
              "Shelf Offers",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text("Scan Shelf QR code to get current shelf offers."),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Icon(
              Icons.local_offer,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bestPrice() {
    return InkWell(
      onTap: () {
        //scanBestPrice();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey[400],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Text(
              "Best Price",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text("Scan product barcode to get best available price."),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Icon(
              Icons.monetization_on,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _myList() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/shopping-list');
      },
      child: Container(
        margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey[400],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Text(
              "Shop From My List",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
                "Lorem Ipsum is simply dummy text of the typesetting industry."),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Icon(
              Icons.shopping_basket,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sodhi Store Sector 55'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _locateProduct(),
            _shelfOffers(),
            _bestPrice(),
            _myList(),
          ],
        ),
      ),
    );
  }
}
