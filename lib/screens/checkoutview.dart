import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sodhis_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'dart:convert';

class MyWebView extends StatefulWidget {
  MyWebView({Key key, this.title, this.url, this.userId, this.merchantTxnId}) : super(key: key);

  final String title;
  final String url;
  final String userId;
  final String merchantTxnId;

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  num position = 1;
  final key = UniqueKey();

  doneLoading(String value) {
    setState(() {
      position = 0;
    });
  }

  startLoading(String value) {
    setState(() {
      position = 1;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context,isDismissible: false);
    pr.style(
      message: 'Please wait...',
    );
    print(widget.merchantTxnId);
    print(widget.url);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // actions: <Widget>[
        //   NavigationControls(_controller.future),
        // ],
      ),
      body: WillPopScope(
          onWillPop: () async {
            await pr.show();
            var response = await http.post(
              new Uri.https(BASE_URL, API_PATH + "/transaction-status"),
              body: {
                "user_id": widget.userId,
                "merchant_txn_id": widget.merchantTxnId,
              },
              headers: {
                "Accept": "application/json",
                "authorization": basicAuth,
              },
            );
            if (response.statusCode == 200) {
              await pr.hide();
              var data = json.decode(response.body);
              var errorCode = data['ErrorCode'];
              if (errorCode == 0) {
                Navigator.of(context)
                .pushNamedAndRemoveUntil('/order-complete', (route) => false);
              } else {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/multislider-home', (route) => false);
              }
            }
            else{
              await pr.hide();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/order-failed', (route) => false);
            }

            return true;
          },
          child: IndexedStack(
          index: position,
          children: <Widget>[
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              key: key,
              onPageFinished: doneLoading,
              onPageStarted: startLoading,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
            ),
            Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture);
  final Future<WebViewController> _webViewControllerFuture;
 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      controller.reload();
                    },
            )
          ],
        );
      },
    );
  }
}


