import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  var _userId;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void dispose() {
    super.dispose();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
  }

  Future notificationsList() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/notifications"),
      body: {
        "user_id": _userId,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget notificationsListBuilder() {
    return FutureBuilder(
      future: notificationsList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var errorCode = snapshot.data['ErrorCode'];
          var response = snapshot.data['Response'];
          if (errorCode == 0) {
            return ListView.separated(
              itemCount: response.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(response[index]['title']),
                      subtitle: Text(response[index]['body']),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            );
          } else {
            return _emptyNotification();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _emptyNotification() {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 150,
              width: 150,
              margin: const EdgeInsets.only(bottom: 20),
              child: Image.asset("assets/images/notify_bell.png"),
            ),
            Text(
              "No Notifications Yet!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 80),
              child: Text(
                "Check this section for updates, exclusive offers and general notifications.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: SafeArea(
        child: notificationsListBuilder(),
      ),
    );
  }
}
