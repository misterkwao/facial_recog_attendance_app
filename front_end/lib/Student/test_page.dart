import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:student_attendance_app/Student/notifications.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with WidgetsBindingObserver {
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };
  UniqueKey _key = UniqueKey();
  late WebViewController _webViewController;
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer

    // Initialize the WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isloading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isloading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(passedtestLink));
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // When the app goes to the background, close the modal bottom sheet
      Navigator.of(context)
          .popUntil((route) => !Navigator.of(context).canPop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: height,
            width: width,
            child: WebViewWidget(
              key: _key,
              gestureRecognizers: gestureRecognizers,
              controller: _webViewController,
            ),
          ),
          if (_isloading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 50,
            right: 50,
            child: InkWell(
              onTap: () {
                _webViewController.reload();
              },
              child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent,
                  ),
                  child: Icon(
                    Icons.replay_outlined,
                    size: 30,
                    color: Colors.white,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
