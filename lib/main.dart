import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

String userId = "_";
String prevUrl = "https://m.youtube.com/";
List<dynamic> speedList = [];
num endPoint = 0;

Future main() async {
  // 위젯 바인딩 초기화 : 웹뷰와 플러터 엔진과의 상호작용을 위함
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    userId = '${info.id}${info.device}';
  } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    IosDeviceInfo info = await deviceInfo.iosInfo;
    userId = '${info.identifierForVendor}${info.model}';
  }
  debugPrint("userId: $userId");
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  //const MyApp({Key? key}) : super(key: key); 이 옳은 표현? 알아보기
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  // 인앱웹뷰 컨트롤러
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      // 웹뷰 설정 추후 더 알아보기
      isInspectable: kDebugMode, // 디버깅 모드 여부
      mediaPlaybackRequiresUserGesture: false, // 미디어 재생 사용자 제스처 필요 여부
      allowsInlineMediaPlayback: true, // 인라인 미디어 재생 허용
      //iframeAllow: "camera; microphone", // iframe 카메라, 마이크 허용
      javaScriptEnabled: true, // 자바스크립트 실행 여부
      iframeAllowFullscreen: true, // iframe 전체화면 허용
      allowsBackForwardNavigationGestures: true // 뒤로가기, 앞으로가기 제스처 허용
      );

  PullToRefreshController? pullToRefreshController; // 당겨서 새로고침 컨트롤러
  String url = ""; // url 주소
  double progress = 0; // 페이지 로딩 프로그레스 바
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.black, // 새로고침 아이콘 색상
            ),
            // 플랫폼별 새로고침
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    //변경점
    return PopScope(
      canPop: false, //홈화면에서 뒤로가기시 종료하는 기능 추가해야함
      onPopInvoked: (didPop) async {
        // detect Android back button click
        final controller = webViewController;
        if (controller != null) {
          if (url == "https://m.youtube.com/") {
            didPop = true;
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          } else {
            if (await controller.canGoBack()) {
              await controller.goBack();
            }
          }
        }
      },
      //변경점
      child: Scaffold(
          body: SafeArea(
              child: Column(children: <Widget>[
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                // 시작 페이지
                initialUrlRequest:
                    URLRequest(url: WebUri("https://m.youtube.com/")),
                // 초기 설정

                initialSettings: settings,
                // 당겨서 새로고침 컨트롤러 정의
                pullToRefreshController: pullToRefreshController,
                // 인앱웹뷰 생성 시 컨트롤러 정의
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },

                // 페이지 로딩 시 수행 메서드 정의
                onLoadStart: (controller, url) async {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                    //debugPrint("onLoadStart: $url");
                    //debugPrint("who: $userId");
                  });
                  controller.evaluateJavascript(source: """
                    let previousTime = 0;
                    let currentTime = 0;
                    let backward = [];
                    let forward = [];
                    var isDetected = false;
                    var speedIntervals = []; 
                    let save =0;

                    setInterval(() => {
                      currentTime = document.querySelector('video').currentTime;
                      
                      const timeDifference = currentTime - previousTime;
                      if (timeDifference >= 9.5) {
                            forward.push(currentTime);
                      }
                      if (timeDifference <= -2.5) {
                            backward.push(currentTime);
                      }
                      previousTime = currentTime;
                    }, 1000);

                    setInterval(function() {
                        const element = document.querySelector('.player-controls-top-tooltip-label.typography-narrow-default-action-m');
                        if (element && !isDetected) {
                            speedIntervals.push([currentTime]); 
                            isDetected = true;
                        } else if (!element && isDetected) {
                            speedIntervals[speedIntervals.length - 1].push(currentTime); 
                            isDetected = false; 
                        }
                      if(currentTime!=0){
                        save = currentTime;
                      }

                    }, 1000);

                    setInterval(function() {
                      const adAvatarElements = document.querySelectorAll('.ytp-ad-avatar-lockup-card.ytp-ad-component--clickable');
                      const adInfoElements = document.querySelectorAll('.ytp-ad-player-overlay-layout__ad-info-container');
                      adAvatarElements.forEach(adElement => {
                          adElement.remove();
                      });
                      adInfoElements.forEach(adElement => {
                          adElement.remove();
                      });
                      const skipButton = document.querySelector('.ytp-skip-ad-button');   
                      if (skipButton) {
                          skipButton.click();
                      }
                      if (document.querySelectorAll('.ad-showing').length > 0) {
                        const titleLinkElements = document.querySelectorAll('.ytp-title-link.yt-uix-sessionlink.ytp-title-fullerscreen-link');
                        titleLinkElements.forEach(titleLinkElement => {
                            titleLinkElement.remove();
                        });
                        const video = document.querySelector('video');
                        if(video) {
                          video.currentTime = video.duration;
                        }
                      }
                    }, 100);
                  """);
                },

                // 페이지 로딩 완료 시 수행 메서드 정의
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT);
                },

                // URL 로딩 제어
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;
                  // 아래의 키워드가 포함되면 페이지 로딩
                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri.scheme)) {
                    // 앱 실행
                    if (await canLaunchUrl(uri)) {
                      // Launch the App
                      await launchUrl(
                        uri,
                      );
                      // and cancel the request
                      return NavigationActionPolicy.CANCEL;
                    }
                  }
                  // 페이지 로딩 허용
                  return NavigationActionPolicy.ALLOW;
                },

                // 페이지 로딩이 정지 시 메서드 정의
                onLoadStop: (controller, url) async {
                  pullToRefreshController?.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                    //debugPrint("onLoadStop: $url");
                  });
                },

                // 페이지 로딩 중 오류 발생 시 메서드 정의
                onReceivedError: (controller, request, error) {
                  pullToRefreshController?.endRefreshing();
                },

                // 페이지 로딩 중 프로그레스 바 표시
                onProgressChanged: (controller, progress) async {
                  if (progress == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = url;
                    //debugPrint("onProgressChanged: $url");
                  });
                },

                //
                onUpdateVisitedHistory:
                    (controller, url, androidIsReload) async {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                  if (!this.url.contains("#")) {
                    if (prevUrl != this.url) {
                      DateTime endNow = DateTime.now();
                      var endBack = await controller.evaluateJavascript(
                          source: "JSON.stringify(backward);");

                      var endForward = await controller.evaluateJavascript(
                          source: "JSON.stringify(forward);");

                      var endPushSpeed = await controller.evaluateJavascript(
                          source: "JSON.stringify(speedIntervals);");
                      endPoint =
                          await controller.evaluateJavascript(source: "save;");
                      //debugPrint("endPoint: $endPoint");
                      if (prevUrl.toString().contains("watch?v=")) {
                        // String goChannel = channel ?? "ijoiji";
                        FirebaseDatabase endChange = FirebaseDatabase.instance;
                        await endChange
                            .ref("eisnx02m") //userId
                            .child(endNow.toString().replaceAll(".", "_"))
                            .set({
                          "URL": prevUrl.toString(),
                          // "Channel": goChannel,
                          // "Duration": duration,
                          "Speed": speedList.toString(),
                          "Back": endBack,
                          "Forward": endForward,
                          "Dash": endPushSpeed,
                          "EndPoint": endPoint
                        });
                      }

                      controller.evaluateJavascript(source: """

                        previousTime = 0;
                        currentTime = 0;
                        backward = [];
                        forward = [];
                        isDetected = false;
                        speedIntervals = []; 
                        """);
                      speedList = [];
                    }

                    prevUrl = this.url;

                    var speed = await controller.evaluateJavascript(
                        source:
                            "document.querySelector('video').playbackRate;");
                    var time = await controller.evaluateJavascript(
                        source: "document.querySelector('video').currentTime;");
                    List<dynamic> speedTime = [speed, time];
                    speedList.add(speedTime);

                    //ui 조정 코드
                    controller.evaluateJavascript(
                        source:
                            """document.querySelector('.yt-spec-button-shape-next--overlay.yt-spec-button-shape-next--outline').style.borderColor = 'black';
                               document.querySelector('.yt-spec-button-shape-next--overlay.yt-spec-button-shape-next--outline').style.color = 'black';
                               document.querySelector('.ytp-unmute-box').click();
                               document.querySelector('.yt-spec-button-shape-next--size-l.yt-spec-button-shape-next--icon-button').style.width = '0';
                               document.querySelector('.yt-spec-button-shape-next--overlay.yt-spec-button-shape-next--text').style.color = 'black';
                            """);
                  }
                  //await Future.delayed(Duration(seconds: 2));

                  // if (this.url.contains("watch?v=")) {
                  //   channel = await controller.evaluateJavascript(
                  //       source:
                  //           "document.querySelectorAll('a.slim-owner-icon-and-title')[0].getAttribute('aria-label');");
                  //   duration = await controller.evaluateJavascript(
                  //       source:
                  //           "document.getElementById('movie_player').getDuration();");
                  // }
                  //debugPrint("channel: $channel");
                  //debugPrint("duration: $duration");
                },

                // 페이지 로딩 중 콘솔 메시지 출력
                onConsoleMessage: (controller, consoleMessage) {
                  if (kDebugMode) {
                    //print(consoleMessage);
                  }
                },
                onEnterFullscreen: (controller) {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft
                  ]);
                },
                onExitFullscreen: (controller) {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                },
              ),

              // 페이지 로딩 중 프로그레스 바 표시
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
        ),
      ]))),
    );
  }
}
