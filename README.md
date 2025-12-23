# calendar-term-project


---

# 개인 캘린더 앱 (Web & Mobile)

---

## 1. 프로젝트 개요

본 프로젝트는 Web(Vue)과 Mobile(Flutter)을 이용한 개인 일정 관리 캘린더 애플리케이션이다.
Google 로그인을 통해 사용자 인증을 수행하고, Firebase Firestore를 이용하여 일정 데이터를 저장한다.

Web과 Mobile 환경이 동일한 Firebase 데이터베이스를 공유하여
한쪽에서 추가한 일정이 다른 환경에서도 즉시 확인되도록 구현하였다.

---

## 2. 프로젝트 구성

### Github Repository

본 저장소에는 다음 항목이 포함되어 있다.

* WebApp 소스코드 (Vue 3 + Vite)
* Mobile App 소스코드 (Flutter)
* Firebase Authentication 및 Firestore 연동 코드
* README (프로젝트 소개, 실행 방법, 기능 설명)

---

## 3. 주요 기능

* Google 로그인 기반 사용자 인증
* 일정 생성(Create), 조회(Read), 수정(Update), 삭제(Delete)
* 월간 캘린더 UI를 통한 날짜 선택 및 일정 확인 (Web)
* 오늘 일정 조회 및 날짜 선택을 통한 일정 추가 (Mobile)
* Firebase Firestore를 이용한 Web ↔ Mobile 데이터 연동

---

## 4. 실행 방법 (상세)

본 프로젝트는 WebApp과 Mobile App이 각각 독립적으로 실행되며,
동일한 Firebase 프로젝트를 사용하여 데이터가 연동된다.

---

### 4-1. 사전 준비 사항

다음 환경이 사전에 설치되어 있어야 한다.

* Node.js (v18 이상 권장)
* npm
* Flutter SDK
* Firebase 프로젝트 및 설정 완료

---

### 4-2. Firebase 설정

Firebase 콘솔에서 다음 서비스를 활성화한다.

* Firebase Authentication

  * 로그인 방식: Google 로그인 활성화
* Cloud Firestore

  * 테스트 모드 또는 사용자 인증 기반 규칙 설정

Firebase 프로젝트 생성 후,
Web과 Mobile 각각에 대해 Firebase 설정 파일을 생성한다.

* Web: `firebase.js` 또는 `firebase.ts`
* Mobile: `firebase_options.dart`

(본 레포지토리에는 Firebase 연동 코드가 포함되어 있다.)

---

### 4-3. WebApp 실행 방법

1. WebApp 디렉토리로 이동한다.

```bash
cd web
```

2. 의존성 패키지를 설치한다.

```bash
npm install
```

3. 개발 서버를 실행한다.

```bash
npm run dev
```

4. 터미널에 출력된 로컬 서버 주소로 브라우저에서 접속한다.

```text
예: http://localhost:5173
```

5. Google 로그인 후 캘린더 화면에서 일정 추가 및 조회를 수행한다.

---

### 4-4. Mobile App 실행 방법

1. Mobile App 디렉토리로 이동한다.

```bash
cd mobile
```

2. Flutter 패키지를 설치한다.

```bash
flutter pub get
```

3. 실행할 디바이스를 확인한다.

```bash
flutter devices
```

4. Flutter 앱을 실행한다.

```bash
flutter run
```

* Flutter Web 또는
* 모바일 에뮬레이터 / 실제 디바이스에서 실행 가능

5. Google 로그인 후 오늘 일정 화면에서 일정 확인 및 추가를 수행한다.

---

### 4-5. 실행 확인 방법

아래 흐름을 통해 정상 동작을 확인할 수 있다.

1. WebApp에서 Google 로그인
2. 일정 추가
3. Mobile App 로그인
4. 동일한 일정이 Mobile App에 표시되는지 확인
5. Mobile App에서 일정 추가
6. WebApp 새로고침 후 일정이 표시되는지 확인

---

### 4-6. 테스트 계정 안내

* Google 로그인 방식을 사용하므로 별도의 테스트 계정 정보는 필요하지 않다.
* 개인 Google 계정으로 로그인하여 테스트 가능하다.


---

## 5. 시연 영상 안내 (2~5분)

시연 영상에는 다음 내용이 포함되어 있다.

* WebApp 실행 화면
* Mobile App 실행 화면
* Google 로그인 과정
* 일정 생성, 조회, 수정, 삭제 흐름
* Web에서 추가한 일정이 Mobile에 반영되는 모습
* Mobile에서 추가한 일정이 Web에 반영되는 모습

---

## 6. Firebase 연동 구조

* Authentication: Google 로그인 사용
* Firestore 구조

```text
users
 └── {uid}
      └── events
           └── {eventId}
                ├── title
                ├── date (YYYY-MM-DD)
                ├── startTime
                ├── endTime
                └── createdAt
```

Web과 Mobile 모두 동일한 Firestore 구조를 사용한다.

---

## 7. 실행 가이드

### 설치 방법

* Node.js 및 npm 설치
* Flutter SDK 설치
* Firebase 프로젝트 생성 및 설정

### 실행 방법

* Web: `npm run dev`
* Mobile: `flutter run`

### 테스트 계정

* Google 로그인 방식 사용
* 별도의 테스트 계정 정보 입력은 필요하지 않음

---

## 8. 프로젝트 정리

Web과 Mobile의 역할을 분리하여 설계하였으며,
Firebase를 통해 일정 데이터를 실시간으로 연동하는 개인 캘린더 앱을 구현하였다.
기본 기능 구현과 함께 사용자 경험을 고려한 간단한 UI 정리를 완료하였다.


---

