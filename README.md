# 같이N가치
### 🏫 한양대학교 졸업 프로젝트 with A.drop
## About Project
> 대학생을 대상으로 한 거래 커뮤니티 앱을 개발하여 대학 내의 다양한 자원과 정보를 효율적으로 교환하고, 이를 통해 사용자의 편의성을 극대화하는 플랫폼입니다.
## 🚀 Tech Stack
### Frontend
- **Language:** Swift 6.0.2
- **Framework:** SwiftUI
  
### Backend (Firebase)
- **Authentication:** FirebaseAuth
- **Database:** Firebase Firestore (NoSQL)
- **Storage:** Firebase Storage

## 프로젝트 구조
<pre>
TogetherNValue/
├── TogetherNValue.xcodeproj                # Xcode 프로젝트 파일
├── App/
│   ├── TogetherNValueApp.swift             # SwiftUI 진입점
│   ├── ContentView.swift                   # 메인 콘텐츠 뷰
│   ├── ImagePicker.swift                   # 단일 이미지 선택기
│   ├── MultiImagePicker.swift              # 다중 이미지 선택기
│   └── AppRegisterToLogin/
│       ├── FirstAppLoadingView.swift       # 앱 첫 로딩 화면
│       ├── RootView.swift                  # 루트 뷰 관리
│       ├── UserLoginView.swift             # 사용자 로그인 뷰
│       ├── UserRegisterView.swift          # 사용자 회원가입 뷰
│       └── SelectedSchoolView.swift        # 학교 선택 뷰
├── Posts/
│   ├── PostModel/                          # 게시글 데이터 모델
│   ├── PostView/                           # 게시글 관련 뷰
│   └── PostService/                        # 게시글 서비스 로직
├── Users/
│   ├── UserModel/                          # 사용자 데이터 모델
│   ├── UserView/                           # 사용자 관련 뷰
│   ├── UserService/                        # 사용자 서비스 로직
│   └── UserManager/
│       └── UserManager.swift               # 사용자 관리 로직
├── Settings/
│   ├── FAQListView.swift                   # FAQ 리스트 뷰
│   └── PolicyView.swift                    # 정책 관련 뷰
├── Resources/                              # 리소스 관리 (Assets)
│   └── Assets.xcassets                     # 앱 아이콘 및 이미지 에셋
├── Firebase/
│   └── GoogleService-Info.plist            # Firebase 설정 파일
└── README.md                               # 프로젝트 설명서
</pre>

## 프로젝트 화면
## 팀원

- 김소민 [![GitHub](https://img.shields.io/badge/GitHub-black?style=flat-square&logo=github)](https://github.com/thals304)
- 김현경 [![GitHub](https://img.shields.io/badge/GitHub-black?style=flat-square&logo=github)](https://github.com/hkkim2021)

## Setting
## 구현
> ⚠️ GoogleService-Info.plist에 API 키가 있으므로 repository에 업로드 하지 않음
