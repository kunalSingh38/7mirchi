import 'package:flutter/material.dart';
import 'package:emoji_feedback/emoji_feedback.dart';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/constants.dart';
import 'package:flutter/services.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'dart:convert';
import 'package:sodhis_app/components/general.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _emojiRating = 3;
  var _userId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
  }

  Widget _emojiRatingContainer() {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 30),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'How was the experience you got?',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Colors.grey),
              ),
            ),
            EmojiFeedback(
              onChange: (index) {
                setState(() {
                  _emojiRating = index + 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: commentController,
          cursorColor: Color(0xFF372D61),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 10,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your comments';
            }
            return null;
          },
          onSaved: (String value) {
            commentController.text = value;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter Comments...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: new EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 30),
      child: Align(
        alignment: Alignment.center,
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          child: RaisedButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                setState(() {
                  _loading = true;
                });
                var response = await http.post(
                  new Uri.https(BASE_URL, API_PATH + "/add-feedback"),
                  body: {
                    "user_id": _userId.toString(),
                    "emoji_rating": _emojiRating.toString(),
                    "comments": commentController.text,
                  },
                  headers: {
                    "Accept": "application/json",
                    "authorization": basicAuth
                  },
                );
                if (response.statusCode == 200) {
                  setState(() {
                    _loading = false;
                  });
                  var data = json.decode(response.body);
                  var errorCode = data['ErrorCode'];
                  var errorMessage = data['ErrorMessage'];
                  if (errorCode == 0) {
                    // _formKey.currentState.reset();
                    commentController.clear();
                    Fluttertoast.showToast(
                        msg: 'Feedback submitted successfully');
                  } else {
                    showAlertDialog(context, ALERT_DIALOG_TITLE, errorMessage);
                  }
                }
              }
            },
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            shape: StadiumBorder(),
            child: Text(
              "SUBMIT",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: Center(
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              children: <Widget>[
                _emojiRatingContainer(),
                _commentTextbox(),
                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
