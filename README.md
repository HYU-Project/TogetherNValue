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
TogetherNValue/
├── TogetherNValue.xcodeproj          # Xcode 프로젝트 파일
├── App/
│   └── TogetherNValueApp.swift       # SwiftUI의 진입점
│   └── ContentView.swift
│   └── ImagePicker.swift
│   └── MultiImagePicker.swift
│   └── AppRegisterToLogin/                            
│        └── FirstAppLoadingView.swift
│        └── RootView.swift
│        └── UserLoginView.swift
│        └── UserRegisterView.swift
│        └── SelectedSchoolView.swift
│   └── Posts/                           
│        └── PostModel/
│        └── PostView/
|        └── PostService/
│   └── Users/                            
│        └── UserModel/
│        └── UserView/
|        └── UserService/
│   └── UserManager/                           
│        └── UserManger.swift
│   └── Settings/                            
│        └── FAQListView.swift
│        └── PolicyView.swift
├── Resources/                         # Assets
│   ├── Assets.xcassets
├── Firebase/                         
│   └── GoogleService-Info.plist       # Firebase 설정 파일
└── README.md                          # 프로젝트 설명서

## 프로젝트 화면
## 팀원

- 김소민 [![GitHub](https://img.shields.io/badge/GitHub-black?style=flat-square&logo=github)](https://github.com/thals304)
- 김현경 [![GitHub](https://img.shields.io/badge/GitHub-black?style=flat-square&logo=github)](https://github.com/hkkim2021)

## Setting
## 구현
> ⚠️ GoogleService-Info.plist에 API 키가 있으므로 repository에 업로드 하지 않음
