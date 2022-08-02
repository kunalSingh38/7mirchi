// import 'package:barcode_scan/model/android_options.dart';
// import 'package:barcode_scan/model/scan_options.dart';
// import 'package:barcode_scan/platform_wrapper.dart';
import 'package:flutter/material.dart';

class ScanStore extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}
class _ScanPageState extends State<ScanStore> {
  @override
  void initState() {
    super.initState();
  }
  /* scan() async {
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
      Navigator.pushNamed(context, '/store');
    }
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Store"),
      ),
      floatingActionButton: FloatingActionButton.extended(
       // onPressed: scan,
        label: Text('Enter Store'),
        icon: Icon(Icons.crop_free),
        backgroundColor: Colors.pink,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}