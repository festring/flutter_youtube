# 📽 자동 배속 조정 YouTube 앱 (for Android & IOS)

### ✏️ 앱 소개
플러터의 라이브러리인 **InAppWebView** 를 활용하여 웹기반 앱을 제작하며, 
참여자가 최대한 유튜브 앱과 **유사한 시청 경험**을 할 수 있도록 설계했다. <br>
각 참여자는 구글 **로그인이 가능**하여 평소 시청하는 영상들을 쉽게 볼 수 있으며, 
로그인 정보 등의 **개인정보는 수집하지 않는다**. <br> 

### ✏️ 배속 조정 기능
해당 앱은 아래 두가지 방법을 통해 배속을 조정할 수 있다.
- 서버와 통신하여 영상을 분석한 뒤 자동 배속 조정
- 미리 설정된 시간에 자동으로 배속을 조정
  
 
### ✏️ 활용 계획
유튜브 환경에서 사용자 별로 자동 배속을 실행하고,<br>
배속 조정을 인지하는 **`하한선 (민감도)`** 과 배속 조정을 거부하는 **`상한선 (선호도)`** 을 분석하고자 한다. <br>
(2024.12.13)

<br>

---
<br><br>

# 📋 필요 환경


App

- **Dart 설치**
- **Flutter 설치**
- **Firebase 프로젝트 생성**
    
    

Server

- **Python 설치**
- **PyTorch 설치**
    
    

<br>

---
<br><br>

# 🔑 핵심 파일 소개


> 사용하면서 중요하게 다뤄야 할 파일들

<br>

## 📁 android 폴더

> 아래 3개의 파일에 안드로이드 빌드 관련 핵심 설정들이 담겨 있습니다.<br>
이외에도 빌드에 문제가 발생하면, 문제가 되는 파일을 직접 찾아야합니다.



- **`build.gradle`**
    
    프로젝트 전반의 빌드 설정을 담고 있는 파일로, Gradle 버전, 플러그인, 전역 의존성 등을 정의합니다.
    
- **`app/build.gradle`**
    
    앱 모듈의 빌드 설정 파일로, 안드로이드 SDK 버전, 의존성 라이브러리, 빌드 타입(디버그, 릴리스 등) 등을 정의합니다. <br>실제 APK 생성에 중요한 역할을 합니다.
    
- **`app/src/main/AndroidManifest.xml`**
    
    앱의 메타데이터를 정의하는 파일로, 앱 이름, 아이콘, 권한 설정, 액티비티 정의 등이 포함되어 있습니다. 

<br>
<br>

## 📁 assets 폴더

> JavaScript 파일과 앱 아이콘 등의 원본파일이 담겨있습니다.<br>
JS 코드가 유튜브 내에서 환경을 제어하고 동작을 관리합니다.<br>
유튜브 웹의 업데이트에 따라 작동이 되지 않을 수 있습니다.

<br>

 **✅ 핵심 기능 ✅**
<br>
- **`check.js`**
    
    배속 조정 등 웹 **동작을 감지**하고 배열에 **기록**하는 기능을 담습니다.<br>
    해당 기능은 코드가 복잡하여, 세부 내용은 주석에 상세하게 담았습니다.


- **`control.js`**
    
    서버에 설정된 시간 타점 기록을 기반으로 배속을 조정해주는 기능을 담고있습니다.<br>
    해당 기능은 코드가 복잡하여, 세부 내용은 주석에 상세하게 담았습니다.
   


 
- **`adblock.js`**
    
    유튜브 내의 광고를 스킵하는 기능을 담았습니다.<br>
    광고 시간을 넘기는 것 이외에도 skip 버튼을 자동으로 클릭합니다. 

 <br>    
<br>

 **⚠️ 안쓰는 기능 ⚠️**
 
- **`dash.js`**

    유튜브 매커니즘 상 “꾹 눌러 2배속”을 진행하고 취소하면 무조건 1배속으로 설정됩니다.  
따라서 배속을 바꾼 상태로 “꾹 눌러 2배속” 취소 시 원래 설정했던 배속으로 바꿔줍니다.  
    (예시: 1.25배속 시청하다가 ⇒ 꾹눌러 2배속 하고 ⇒ 취소하면 ⇒ 1.25 배속으로 원상 복구) 


- **`main.js`**
        
    필요없는데 없으면 괜히 불안해서 못지우고 있습니다. 하하 


- **`splash.png`**
    
    앱 아이콘 원본 이미지 입니다.

<br>    
<br>


## 📁 ios 폴더

> 아래 2개의 파일에 IOS 빌드 관련 핵심 설정들이 담겨 있습니다.<br>
이외에도 빌드에 문제가 발생하면, 문제가 되는 파일을 직접 찾아야합니다..



- **`Runner/Info.plist`**
    
    iOS 앱의 구성 파일로, 앱 이름, 번들 식별자, 권한 설정, 환경설정 등이 정의되어 있습니다.<br>
  iOS에서 앱이 어떻게 동작하는지를 제어합니다.

- **`Podfile`**
    
    CocoaPods 의존성 관리를 위한 파일로, iOS 앱에서 사용하는 외부 라이브러리나 플러그인을 정의합니다.<br>
  `pod install` 명령어를 통해 이 파일을 기반으로 의존성을 설치합니다.
    
<br>
<br>


## 📁 lib 폴더

> 플러터 앱을 구성하는 다트 파일들이 담겨있습니다.

 **✅ 핵심 기능 ✅**

- **`main.dart`**
  
    
    Flutter 앱의 전체 구조, 라우팅, 위젯 트리의 시작점 등 모든 것들이 파일에 정의됩니다.<br>
    자세한 설명은 코드에 주석처리를 해두었습니다.
    
- **`firebase_options.dart`**
    
    Firebase 서비스를 사용하는 앱에서 Firebase 초기화를 위한 설정이 저장된 파일입니다. <br>
  Firebase 콘솔에서 다운로드한 설정 정보를 포함하며, 앱에서 Firebase 기능을 활성화합니다.

    
<br>
<br>

## 📁 server 폴더

> 우분투 서버 상에 작동될 파이썬 파일입니다. <br>
영상을 분석하거나 미리 설정된 배속을 반환합니다. <br>

<br>

 **✅ 핵심 기능 ✅**
<br>
- **`server.py`**
    
    아래  **[ Python 서버 구동 및 연결 ]** 에서 해당 코드의 상세한 작동 방법을 서술합니다.



      
<br>
<br>


## 그 외

- **`pubspec.yaml`**
    
    Flutter 및 Dart 프로젝트의 **구성 정보와 의존성을 관리하는 핵심 파일**입니다.<br>
    `flutter pub get` 등의 명령어로 해당 파일을 실행하여 의존성을 유지합니다.
  
<br>

---
<br><br>

# 🛠️ Flutter 개발 환경 구축


1. 아래 명령어를 실행하여 플러터 설치 상태 확인
    
    ```bash
    flutter doctor
    ```
    
2. 프로젝트를 저장할 디렉토리로 이동
    
    ```bash
    cd <저장할 디렉토리>
    ```
    
3. Git 명령어를 사용해 리포지토리를 클론
    
    ```bash
    git clone <https://github.com/festring/flutter_youtube.git>
    ```
    
4. 클론된 디렉토리로 이동(2번과 동일한 디렉토리)
    
    ```bash
    cd <클론된 디렉토리>
    ```
    
5. 프로젝트 디렉토리에서 아래 명령어를 실행하여`pubspec.yaml`에 정의된 모든 패키지를 로컬에 다운로드
    
    ```bash
    flutter pub get
    ```
    

<br>

---
<br><br>

# 🔥 Firebase 연결


> 현재는 @**hch2454@khu.ac.kr**의 firebase realtime database에 연결되어있습니다.<br>
자신의 firebase 프로젝트에 연결하고 확인해보세요.
>

<br>

[Firebase console](https://console.firebase.google.com/) 접속 > 프로젝트 만들기 > 앱 추가 > Flutter 선택하여 지침대로 수행

참조: [공식 문서](https://firebase.google.com/docs/flutter/setup?hl=ko&authuser=0&_gl=1*1c21sld*_ga*MTY5MzMyODgzNy4xNzMwODkxMjQ2*_ga_CW55HF8NVT*MTczNDAxMjAxMC4xMS4xLjE3MzQwMTIwMjkuNDEuMC4w&platform=android)

<br>

---
<br><br>

# 🚀 앱 빌드 방법


- **안드로이드**
    
    `./bulid/app/outputs/flutter-apk`  경로에 apk-realse.apk 가 생성됨
    
    ```jsx
    flutter build apk --release --target-platform=android-arm64
    ```
    
- **IOS**
    
    [참조링크 1](https://sodevly.github.io/react-native-upload-app-on-testflight/#debugrelease%EB%AA%A8%EB%93%9C-%EC%84%A0%ED%83%9D) 
    
    [참조링크 2](https://flutter.kgoon.net/ios/apple-testflight)
    
    [참조링크 3](https://velog.io/@knh4300/TestFlight-%EC%97%90-%EB%B0%B0%ED%8F%AC%ED%95%98%EA%B8%B0)
    
- IOS 오류 시 참조했던 링크들
    
    [Provisioning Profile 등록 및 오류 처리](https://dchkang83.tistory.com/144)
    
    [[Flutter] failed to launch ios simulator](https://dianakang.tistory.com/30)
    
    [cocoapod .modulemap file not found](https://stackoverflow.com/questions/55675694/how-to-fix-cocoapod-modulemap-file-not-found)
    
    [file not found because of Firebase](https://stackoverflow.com/questions/66500800/db-version-edit-h-file-not-found-because-of-firebase)
    
    [error: use of undeclared identifier 'port](https://github.com/Baseflow/flutter-permission-handler/issues/443)
    
    ~~빌드는 오류 안 날때까지 해결하는 수 밖ㅇ… 21세기 인디언 기우제~~
    
<br>

---
<br><br>

# 🌟 Python 서버 구동 및 연결


> 현재는 기존의 hch2454@ 서버에 연결해서 진행.(서버 키는 법은 보안상 직접 전달)<br>
추후 서버 배정 받으면 그때 본인의 서버에 수정하시면 됩니다.

<br>

### 서버 작동

```jsx
gunicorn -w 10 -b 0.0.0.0:5000 server:app
```

- 여기서 -w 뒤에 숫자가 워커 수
- gnicorn의 서버의 여유 처리 공간은 워커수와 스레드 수로 결정
- 스레드를 늘려도 되긴하는데, 그냥 여유롭게 워커만 10개로 설정
- 이론상 70개 까지는 무리 없지만, 굳이 그럴 필요는 없을 것.

<br>

### 배속 조정 코드

- 해당 코드를 서버 상에서 수정하여 배속 조정

`1(고정값),[[영상시간, 설정배속],[..],[..] ],(영상 ID)]`

```jsx
//[1(고정값),[[영상시간, 설정배속],[..],[..] ],(영상 ID)]
// 항상 시작 속도가 1배속임을 생각해야한다
// 영상 자체에 배속이 들어간건 무시. 기본보다 빨라졌냐 아니냐를 판단하시길 

predefined_lists = [
[1,[[10, 1.1],[13, 1.15],[20, 1.2],[25, 1.25],[40, 1.3]],"q0YCVSxbcVg"],
[1,[[5, 1.05],[10, 1.08],[20, 1.12],[30, 1.15],[35, 1.2],[50, 1.3]],"FrjdXP6WeWw"],
[1,[[5, 1.01],[8, 1.02],[12, 1.05],[30, 1.1],[35, 1.2],[40, 1.25]],"dsAMzn6v5o8"],
...
]
```

- 여기서 맨 앞에 `[1,[...` 이 있는 이유
    - 초기 배속 조정 방법과 구분하려고 남겨둠.
    나중에 거슬리면 코드 수정하시면 되지만 고칠 거 많으실테니 적응하시는거 추천.
    - 원래는 
    [0]번 방법: 일정한 시간 간격 마다 배속 조정, 
    [1]번 방법: 지정된 위치에서 배속
        
        적당하게 섞어 쓰려했는데, 상황상 1번 방법만 쓰게 됨
        
<br>

### 서버 상 에서 코드 수정 법

```jsx
nano ~/서버_디렉토리/server.py
```

- 저장: Ctrl + O → Enter
- 종료: Ctrl + X
