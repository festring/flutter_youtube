import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

String prevUrl = "https://m.youtube.com/";
List<dynamic> speedList = [];
num? endPoint = 0;
List<dynamic> saveResult = [0, [], "0"];

Future main() async {
  // 위젯 바인딩 초기화 : 웹뷰와 플러터 엔진과의 상호작용을 위함
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeRandomNumber();
  int randomNumber = await getRandomNumber(); // 랜덤 숫자를 가져와서 변수에 저장

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {}

  runApp(MaterialApp(
    theme: ThemeData.light(), // 라이트 테마
    darkTheme: ThemeData.dark(), // 다크 테마
    themeMode: ThemeMode.system, // 시스템 모드에 따라 테마 변경
    home: MyApp(randomNumber: randomNumber),
  ));
}

Future<void> initializeRandomNumber() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'random_number';

  if (!prefs.containsKey(key)) {
    final random = Random();
    final randomNumber = random.nextInt(1000000); // 0부터 999999 사이의 난수 생성
    await prefs.setInt(key, randomNumber);
  }
}

Future<int> getRandomNumber() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('random_number') ?? 0;
}

Future<List<dynamic>> sendPostRequest(String userId, String url) async {
  final apiUrl =
      Uri.parse('http://163.180.160.143:5000/process'); // 실제 서버 IP 주소로 변경
  final List<dynamic> defaultResult = [0, 1, 1, "0"]; // 기본 배열

  try {
    // POST 요청 보내기
    final response = await http.post(
      apiUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'user_id': userId, 'url': url}),
    );

    // 서버로부터 성공적인 응답을 받았는지 확인
    if (response.statusCode == 200) {
      // 응답이 성공적이면, 응답 데이터 파싱
      final List<dynamic> responseData = jsonDecode(response.body);

      return responseData;
    } else {
      // 오류 발생 시 기본 배열 반환
      debugPrint('Failed to send request. Status code: ${response.statusCode}');
      return defaultResult;
    }
  } catch (e) {
    // 예외 처리 발생 시 기본 배열 반환
    debugPrint('Error sending request: $e');
    return defaultResult;
  }
}

class MyApp extends StatefulWidget {
  final int randomNumber;
  //const MyApp({Key? key}) : super(key: key); 이 옳은 표현? 알아보기
  const MyApp({super.key, required this.randomNumber});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String adblock = '';
  String check = '';
  String control = '';
  String dash = '';
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
    // debugPrint('MyAppState Random Number: ${widget.randomNumber}');
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setStatusBarColor(); // 의존성 변경 시 상태바 색상을 업데이트
  }

  void _setStatusBarColor() {
    // 현재 테마의 밝기 (라이트 모드 또는 다크 모드) 가져오기
    final Brightness brightness = Theme.of(context).brightness;

    // 상태바의 색상과 아이콘 밝기를 설정
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: brightness == Brightness.light
          ? Colors.white
          : Colors.black, // 라이트 모드면 흰색, 다크 모드면 검정색
      statusBarIconBrightness: brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light, // 아이콘 색상 설정
      statusBarBrightness: brightness, // iOS에서 상태바 아이콘 색상을 설정하는 데 사용
    ));
  }

  // 비동기적으로 서버 요청을 보내고 결과를 처리하는 함수
  void sendPostRequestAndUpdateJavascript(String userId, String url) async {
    // 비디오가 로드되면 시작 배속을 1로 설정
    await webViewController!.evaluateJavascript(source: """
      (function() {
        const intervalId = setInterval(() => {
          const video = document.querySelector('video');
          if (video) {
            if (video.currentTime >= 1) {
              video.playbackRate = 1;
              clearInterval(intervalId);
            }
          }
        }, 10);
      })();
    """);
    // 서버로부터 받은 값을 전역 변수 saveResult에 바로 저장
    saveResult = await sendPostRequest(userId, url);
    // 자바스크립트 실행
    debugPrint("sendPostRequestAndUpdateJavascript: $saveResult");
    if (webViewController != null) {
      debugPrint(this.url.toString());
      if (this.url.toString().contains(saveResult[2])) {
        if (saveResult[0].toString() == "0") {
          if (saveResult[1] != []) {
            debugPrint("4444번 구역 진입");
            webViewController!.evaluateJavascript(source: """
          startMonitoringVideoTime(${saveResult[1][0]}, ${saveResult[1][1]}, ${saveResult[1][2]});
        """);
          }
        } else {
          debugPrint("5555번 구역 진입");
          webViewController!.evaluateJavascript(source: """
          setPlaybackRates(${saveResult[1]});
        """);
        }
      }
    }
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
                    // debugPrint(
                    //     'onLoadStart Random Number: ${widget.randomNumber}');
                  });
                  debugPrint("onLoadStart: $url");
                  // controller.evaluateJavascript(source: """
                  //   function startInterval() {
                  //     const intervalId = setInterval(() => {
                  //       const video = document.querySelector('video');
                  //       if (video) {
                  //         if (video.currentTime >= 1) {
                  //           video.playbackRate = 1;
                  //           clearInterval(intervalId);
                  //         }
                  //       }
                  //     }, 10);
                  //   }
                  // """);
                },

                // 페이지 로딩 완료 시 수행 메서드 정의
                onPermissionRequest: (controller, request) async {
                  debugPrint("onPermissionRequest: $request");
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
                  debugPrint("onLoadStop: $url");
                  adblock = await rootBundle.loadString('assets/adblock.js');
                  check = await rootBundle.loadString('assets/check.js');
                  control = await rootBundle.loadString('assets/control.js');
                  dash = await rootBundle.loadString('assets/dash.js');
                  controller.evaluateJavascript(source: check);
                  controller.evaluateJavascript(source: adblock);
                  controller.evaluateJavascript(source: control);
                  controller.evaluateJavascript(source: dash);
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
                      if (this.url.toString().contains("watch?v=")) {
                        DateTime whatTime = DateTime.now();
                        int hour = whatTime.hour; // 시간 부분만 추출
                        debugPrint(hour.toString()); // 시간 출력
                        debugPrint("영상인 것 만 판별?: $url");

                        //시작배속 무조건 1로 초기화
                        // controller.evaluateJavascript(
                        //     source: "startInterval();");

                        ///여기서 서버 통신하고 밑에서 실행하는 걸로
                        sendPostRequestAndUpdateJavascript(
                            '${widget.randomNumber}', this.url.toString());
                      } //순서바꾸기 고려해볼것

                      debugPrint("여기는 취합하는 곳");
                      DateTime endNow = DateTime.now();
                      var endBack = await controller.evaluateJavascript(
                          source: "JSON.stringify(backward);");

                      var endForward = await controller.evaluateJavascript(
                          source: "JSON.stringify(forward);");

                      var endPushSpeed = await controller.evaluateJavascript(
                          source: "JSON.stringify(speedIntervals);");
                      var temp =
                          await controller.evaluateJavascript(source: "save;");
                      endPoint = temp ?? 0.0;
                      var iosSpeedList = await controller.evaluateJavascript(
                          source: "JSON.stringify(iosSpeedList);");
                      //debugPrint("endPoint: $endPoint");
                      if (prevUrl.toString().contains("watch?v=")) {
                        debugPrint("여기는 보내는 곳");
                        FirebaseDatabase endChange = FirebaseDatabase.instance;
                        await endChange
                            .ref('${widget.randomNumber}') //userId
                            .child(endNow.toString().replaceAll(".", "_"))
                            .set({
                          "URL": prevUrl.toString(),
                          // "Channel": goChannel,
                          // "Duration": duration,
                          "Speed1": speedList.toString(),
                          "Back": endBack,
                          "Forward": endForward,
                          "Dash": endPushSpeed,
                          "EndPoint": endPoint,
                          "Speed2": iosSpeedList.toString(),
                          "Control": saveResult[1].toString()
                        });
                        saveResult = [0, 1, 1, "0"]; //초기ㅗ하 시점 확인하기
                      }
                      debugPrint("여기는 초기화하는곳");
                      controller.evaluateJavascript(source: """
                        previousTime = 0;
                        currentTime = 0;
                        backward = [];
                        forward = [];
                        isDetected = false;
                        speedIntervals = []; 
                        iosSpeedList = [];
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
                            """document.querySelector('.yt-spec-button-shape-next--overlay.yt-spec-button-shape-next--outline').style.borderColor = 'transparent';
                               document.querySelector('.yt-spec-button-shape-next--overlay.yt-spec-button-shape-next--outline').style.color = 'transparent';
                               document.querySelector('.ytp-unmute-box').click();
                               document.querySelector('.yt-spec-button-shape-next--size-l.yt-spec-button-shape-next--icon-button').style.width = '0';
                               document.querySelector('.yt-spec-button-shape-next--overlay.yt-spec-button-shape-next--text').style.color = 'transparent';
                            """);
                    //ui 조정 코드
                    final brightness = Theme.of(context).brightness;
                    if (brightness == Brightness.light) {
                      // 라이트 모드일 때만 실행할 코드
                      controller.evaluateJavascript(source: """
                            document.querySelectorAll('ytm-mobile-topbar-renderer.sticky-player').forEach(function(element) {
                              if (element.getAttribute('ambient-topbar') === 'true') {
                                element.style.backgroundColor = 'white'; 
                              }
                            });
                            document.querySelectorAll('.mobile-topbar-logo.ringo-logo, .logo-in-player.ringo-logo').forEach(function(element) {
                                element.style.color = '#000000';
                            });
                            document.querySelector('.mobile-topbar-header-content.non-search-mode.cbox').style.color = '#000000';
                            document.querySelector('.mobile-topbar-header[data-mode="watch"]').style.backgroundColor = '#ffffff'; 
                            """);
                    }
                  }
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
