# 같이N가치
### 🏫 한양대학교 졸업 프로젝트 with A.drop (회사 연계 프로젝트)
## About Project
> 대학생을 대상으로 한 거래(공구/나눔) 커뮤니티 앱을 개발하여 <br>
> 대학 내의 다양한 자원과 정보를 효율적으로 교환하고, 이를 통해 사용자의 편의성을 극대화하는 플랫폼입니다.
## 🚀 Tech Stack
### Frontend
- **Language:** Swift
- **Framework:** SwiftUI
  
### Backend (Firebase)
- **Authentication:** FirebaseAuth
- **Database:** Firebase Firestore (NoSQL)
- **Storage:** Firebase Storage

## 프로젝트 구조
<pre>
TogetherNValue/
├── TogetherNValue.xcodeproj                # Xcode 프로젝트 파일
├── TogetherNValue/
│   ├── TogetherNValueApp.swift             # SwiftUI 진입점
│   ├── ContentView.swift                   # 메인 콘텐츠 뷰
│
│   ├── Components/                         # 재사용 가능한 UI 컴포넌트
│   │   ├── ImagePicker.swift               # 단일 이미지 선택기
│   │   └── MultiImagePicker.swift          # 다중 이미지 선택기
│
│   ├── Features/                           # 주요 기능 모듈 통합
│   │   ├── AppRegisterToLogin/             # 로그인/회원가입 관련 뷰
│   │   │   ├── FirstAppLoadingView.swift   # 앱 첫 로딩 화면
│   │   │   ├── RootView.swift              # 루트 뷰 관리
│   │   │   ├── UserLoginView.swift         # 사용자 로그인 뷰
│   │   │   ├── UserRegisterView.swift      # 사용자 회원가입 뷰
│   │   │   └── SelectedSchoolView.swift    # 학교 선택 뷰
│   │   ├── Posts/                          # 게시글 관리
│   │   │   ├── PostModel/                  # 게시글 데이터 모델
│   │   │   ├── PostView/                   # 게시글 관련 뷰
│   │   │   └── PostService/                # 게시글 서비스 로직
│   │   ├── Users/                          # 사용자 관리
│   │   │   ├── UserModel/                  # 사용자 데이터 모델
│   │   │   ├── UserView/                   # 사용자 관련 뷰
│   │   │   └── UserService/                # 사용자 서비스 로직
│   │   ├── UserManager/                    # 사용자 관리 로직
│   │   │   └── UserManager.swift
│   │   └── Settings/                       # 앱 설정
│   │       ├── FAQListView.swift           # FAQ 리스트 뷰
│   │       ├── PrivacyPolicyView.swift     # 개인정보 처리방침 관련 뷰
│   │       └── TermsOfServiceView.swift    # 이용약관 관련 뷰
│   
│   ├── Resources/                          # 앱 리소스 관리
│   │   └── Assets.xcassets                 # 앱 아이콘 및 이미지 에셋
│   
│   └── Firebase/                           # Firebase 설정 파일
│       └── GoogleService-Info.plist
└── README.md                               # 프로젝트 설명서
</pre>

> ⚠️ **주의:** `GoogleService-Info.plist`에는 Firebase API 키와 중요한 설정 정보가 포함되어 있습니다.  
> 절대 GitHub 또는 공개된 리포지토리에 업로드하지 마세요. `.gitignore`에 추가하여 관리합니다.

## 프로젝트 화면 구현
![프로젝트 화면](https://github.com/user-attachments/assets/9866eef3-7c12-4ee5-adf0-0917c60114a4)


## 팀원

- 김소민 [![GitHub](https://img.shields.io/badge/GitHub-black?style=flat-square&logo=github)](https://github.com/thals304)
- 김현경 [![GitHub](https://img.shields.io/badge/GitHub-black?style=flat-square&logo=github)](https://github.com/hkkim2021)

## Setting
**환경 요구사항**
Xcode (16.x 최신 버전 추천)
Swift
Firebase SDK (Firebase Auth, Firebase Firestore, Firebase Storage)

**Firebase 설정**
1. Firebase 프로젝트 생성
   - Firebase 콘솔에서 새로운 프로젝트를 생성
     
2. iOS 앱 등록
   - Firebase 콘솔에서 iOS 앱 추가 클릭
   - 프로젝트에 맞는 Bundle ID 입력
   - GoogleService-Info.plist 파일을 다운로드하여 Xcode 프로젝트에 추가
     - 애플리케이션 설정에서 GoogleService-Info.plist 추가
        ```swift
        import Firebase
        @main
        struct YourApp: App {
            init() {
                FirebaseApp.configure()
            }
          var body: some Scene {
                WindowGroup {
                    ContentView()
                }
            }
        }


3. Swift Package Manager 사용 시:
  - Xcode에서 File → Swift Packages → Add Package Dependency 클릭
  - Firebase GitHub 레포지토리 URL: https://github.com/firebase/firebase-ios-sdk
  - 원하는 Firebase 모듈 선택 (예: Firebase/Auth, Firebase/Firestore 등)
