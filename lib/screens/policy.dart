import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:umee/utils/shared.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bar,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Privacy Policy',style: TextStyle(color: textColor,fontSize: 20),),
        ),
      ),
      backgroundColor: background,
      body: Builder(builder: (BuildContext context) {
        return connectivityResult == ConnectivityResult.wifi ||
            connectivityResult == ConnectivityResult.mobile ?
            WebView(
          initialUrl: PRIVACY_POLICY,
          javascriptMode: JavascriptMode.unrestricted,
        ) : Center(child: Text('No Internet Connection!',style: TextStyle(fontSize: 20,color: textColor),));
      }),
    );
  }
}
