import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  var _userId;
  Future<dynamic> _mystoreLocation;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      _mystoreLocation = _storeLocations();
    });
  }

  Future<Null> refreshList() async {
    await Future.delayed(
      Duration(milliseconds: 500),
    );
    setState(() {
      _mystoreLocation = _storeLocations();
    });
    //setState(() {});
    return null;
  }

  Future _storeLocations() async {
    var response = await http.post(
        new Uri.https(BASE_URL, API_PATH + "/store-locations"),
        body: {
          "user_id": _userId,
        },
        headers: {
          "Accept": "application/json",
          "authorization": basicAuth
        });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _storeLocationsBuilder() {
    return FutureBuilder(
      future: _mystoreLocation,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.separated(
            //padding: const EdgeInsets.only(top: 5),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    title: Text(snapshot.data[index]['name']),
                    leading: Icon(Icons.store),
                  ),
                  ListTile(
                    title: Text(snapshot.data[index]['mobile']),
                    leading: Icon(Icons.phone_android),
                  ),
                  ListTile(
                    title: Text(snapshot.data[index]['address']),
                    leading: Icon(Icons.location_on),
                  ),
                  // Container(
                  //   padding: const EdgeInsets.only(top: 15, bottom: 15),
                  //   child: OutlineButton.icon(
                  //     icon: Icon(
                  //       Icons.location_searching,
                  //     ),
                  //     label: Text(
                  //       'Get Direction',
                  //       style: TextStyle(
                  //           //color: Color(0xFF372D61),
                  //           ),
                  //     ),
                  //     onPressed: () {
                  //       var _name = snapshot.data[index]['name'];
                  //       var _address = snapshot.data[index]['address'];
                  //       var _finaladdress = _name + ', ' + _address;
                  //       MapsLauncher.launchQuery(_finaladdress);
                  //     },
                  //   ),
                  // ),
                ],
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Location'),
      ),
      body: RefreshIndicator(
        child: Center(
          child: _storeLocationsBuilder(),
        ),
        onRefresh: refreshList,
      ),
    );
  }
}
