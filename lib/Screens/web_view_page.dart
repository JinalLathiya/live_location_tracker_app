import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../main.dart';

class Web_View_Page extends StatefulWidget {
  const Web_View_Page({Key? key}) : super(key: key);

  @override
  State<Web_View_Page> createState() => _Web_View_PageState();
}

class _Web_View_PageState extends State<Web_View_Page> {
  final GlobalKey googleMapWebViewKey = GlobalKey();
  final TextEditingController mapController = TextEditingController();

  double view = 0;
  List Bookmarks = [];

  InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController;


  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  wikiInitRefreshController() async {
    pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: Colors.blue),
        onRefresh: () async {
          if (Platform.isAndroid) {
            webViewController?.reload();
          } else if (Platform.isIOS) {
            webViewController?.loadUrl(
                urlRequest: URLRequest(url: await webViewController?.getUrl()));
          }
        });
  }

  @override
  initState() {
    super.initState();
    wikiInitRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: TextField(
                  controller: mapController,
                  onSubmitted: (val) async {
                    Uri uri = Uri.parse(val);
                    if (uri.scheme.isEmpty) {
                      uri = Uri.parse("https://www.google.co.in/search?q=$val");
                    }
                    await webViewController!
                        .loadUrl(urlRequest: URLRequest(url: uri));
                  },
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ),
          ),
          (view < 1)
              ? LinearProgressIndicator(
                  value: view,
                  color: Colors.green[700],
                )
              : Container(),
          Expanded(
            flex: 10,
            child: InAppWebView(
              key: googleMapWebViewKey,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              initialOptions: options,
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      "https://www.google.co.in/search?q=$lat,$long")),
              onLoadStart: (controller, uri) {
                setState(() {
                  mapController.text =
                      "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              onLoadStop: (controller, uri) {
                pullToRefreshController.endRefreshing();
                setState(() {
                  mapController.text =
                      "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
              onProgressChanged: (controller, val) {
                if (val == 100) {
                  pullToRefreshController.endRefreshing();
                }
                setState(() {
                  view = val / 100;
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () async {
                    await webViewController!.loadUrl(
                      urlRequest: URLRequest(
                        url: Uri.parse("https://www.google.co.in/"),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () async {
                    await webViewController!.goBack();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_sharp,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      await webViewController!.reload();
                    } else if (Platform.isIOS) {
                      await webViewController!.loadUrl(
                        urlRequest: URLRequest(
                          url: Uri.parse(
                            "${await webViewController?.getUrl()}",
                          ),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () async {
                    await webViewController!.goForward();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.bookmark_add,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () async {
                    Uri? uri = await webViewController!.getUrl();
                    String MyURL =
                        uri!.scheme.toString() + "://" + uri.host + uri.path;

                    setState(() {
                      Bookmarks.add(MyURL);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Added Successfully in Bookmark .. !!"),
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.list_alt_outlined,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Center(
                            child: Text("My BookMarks"),
                          ),
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: Bookmarks.map(
                              (e) => Padding(
                                padding: const EdgeInsets.all(12),
                                child: GestureDetector(
                                  onTap: () async {
                                    await webViewController!.loadUrl(
                                      urlRequest: URLRequest(
                                        url: Uri.parse(e),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(e),
                                ),
                              ),
                            ).toList(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
