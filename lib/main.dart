import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  runApp(const MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('STMZ Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
                  fixedSize: MaterialStatePropertyAll(Size.fromWidth(300))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WebViewPage(
                            url:
                                'https://www.stmz.ch/de/index.php?lang=de&page=1&pageId=320',
                            endUrl: 'https://www.stmz.ch/de/',
                            appBarTitle: 'Animal Missing Form',
                          )),
                );
              },
              child: const Text(
                'Animal Missing Form',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
                  fixedSize: MaterialStatePropertyAll(Size.fromWidth(300))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WebViewPage(
                            url:
                                'https://www.stmz.ch/de/index.php?lang=de&page=60&pageId=20',
                            endUrl: 'https://www.stmz.ch/de/',
                            appBarTitle: 'Register as an STMZ helper',
                          )),
                );
              },
              child: const Text(
                'Register as an STMZ helper',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  final String url;
  final String endUrl;
  final String appBarTitle;

  const WebViewPage(
      {super.key,
      required this.url,
      required this.endUrl,
      required this.appBarTitle});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        final controller = webViewController;
        if (controller != null) {
          if (await controller.canGoBack()) {
            controller.goBack();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle),
        ),
        body: Stack(
          children: <Widget>[
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                allowsBackForwardNavigationGestures: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  isLoading = false;
                });
                if (url.toString() == widget.endUrl) {
                  Navigator.of(context)
                      .pop(); // Navigate back to Flutter home page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      closeIconColor: Colors.white,
                      dismissDirection: DismissDirection.down,
                      showCloseIcon: true,
                      elevation: 10,
                      content: Text('Form submitted successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 10),
                    ),
                  );
                }
              },
            ),
            if (isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
