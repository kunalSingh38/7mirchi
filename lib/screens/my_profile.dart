import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:sodhis_app/services/shared_preferences.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  var _userId;
  String _name;
  String _shortName = '';
  String _mobile_number;
  String _email_address;
  String _address;

  @override
  void initState() {
    super.initState();
    Preference().getPreferences().then((prefs) {
      setState(() {
        _userId = prefs.getInt('user_id').toString();
        _name = prefs.getString('name');
        _shortName = _name[0];
        _mobile_number = prefs.getString('mobile_number');
        _email_address = prefs.getString('email_address');
        _address = prefs.getString('address');
      });
    });
  }

  Future _myProfileData() async {
    var response = await http
        .post(new Uri.https(BASE_URL, API_PATH + "/my-profile"), body: {
      "user_id": _userId,
    }, headers: {
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

  Widget _profileBuilder() {
    return FutureBuilder(
      future: _myProfileData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            child: Column(
              children: <Widget>[
                AvatarGlow(
                  startDelay: Duration(milliseconds: 1000),
                  glowColor: Colors.blue,
                  endRadius: 90.0,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  showTwoGlows: true,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF372D61),
                    child: Text(
                      snapshot.data['name'][0].toString().toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                  ),
                  shape: BoxShape.circle,
                  animate: true,
                  curve: Curves.fastOutSlowIn,
                ),
                ListTile(
                  title: Text(snapshot.data['name'].toString().toUpperCase()),
                  subtitle: Text('Name'),
                  leading: Icon(Icons.person_outline),
                ),
                Divider(),
                ListTile(
                  title: Text(snapshot.data['mobile_number']),
                  subtitle: Text('Mobile Number'),
                  leading: Icon(Icons.phone_iphone),
                ),
                Divider(),
                ListTile(
                  title: Text(snapshot.data['email_address']),
                  subtitle: Text('Email Address'),
                  leading: Icon(Icons.mail_outline),
                ),
                Divider(),
                ListTile(
                  title: Text(snapshot.data['address']),
                  subtitle: Text('Address'),
                  leading: Icon(Icons.location_city),
                ),
              ],
            ),
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
        title: Text('My Profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          )
        ],
      ),
      body: Center(
        child: _profileBuilder(),
      ),
    );
  }
}
