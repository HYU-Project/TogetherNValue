
//  User.swift : Users Table

import Foundation

struct Users {

    let user_idx: Int // 유저 ID
    var userName: String // 유저 이름
    var user_phoneNum: String // 유저 전화번호
    let school_idx: Int // 학교 ID (fk)
    var user_schoolEmail: String // 학교 이메일
    var profile_image_url: String? // 프로필 이미지 URL
    //var terms_agreement_Yn: String // 이용 약관 동의 여부
    //var privacy_agreement_Yn: String // 개인정보 보호 동의 여부
    //var age_14_or_over_Yn: String // 만 14세 이상 동의 여부
    let created_at: String // 가입 일자
    
    // 기본값 설정(default)
    
    
}
