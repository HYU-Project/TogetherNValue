
//  EmailConfig.swift

import Foundation
import SwiftSMTP

// 이메일 설정을 관리하는 구조체
struct CConfig {
    var master_email: String
    var master_pwd: String
    var email_title: String

    init() {
        master_email = "thevalueoftogetherness@gmail.com"
        master_pwd = "together1111"
        email_title = "[같이의 가치] 본인 학교 이메일 인증"
    }
}

// SMTP 설정
let email = CConfig().master_email
let pwd = CConfig().master_pwd
let title = CConfig().email_title
let smtp = SMTP(hostname: "smtp.gmail.com", email: email, password: pwd, port: 587, tlsMode: .requireTLS)

// 이메일 전송 함수
func sendVerificationEmail(userEmail: String, certiCode: String) {
    let mail_from = Mail.User(name: "[같이의 가치] 학교 이메일 인증", email: email)
    let mail_to = Mail.User(name: "[같이의 가치] 학교 이메일 인증", email: userEmail)
    
    let content = "[같이의 가치] E-MAIL VERIFICATION \n" + "Certification Number: [ " + certiCode + " ] \n App에서 입력해주세요."
    let mail = Mail(from: mail_from, to: [mail_to], subject: title, text: content)
    
    smtp.send(mail) { (error) in
        if let error = error {
            print("메일 전송 실패: \(error)")
        } else {
            print("메일 전송 성공")
        }
    }
}

// 이메일 인증 코드 생성 함수
func createEmailCode() -> String {
    let codeChar = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var certiCode: String = ""
    for _ in 0..<6 {
        let randNum = Int.random(in: 0..<codeChar.count)
        certiCode += codeChar[randNum]
    }
    return certiCode
}

// 인증 코드 검증 함수
func verifyCode(inputCode: String, sentCode: String) -> Bool {
    if inputCode == sentCode {
        print("이메일 인증 성공!")
        return true
    } else {
        print("인증 코드가 틀렸습니다.")
        return false
    }
}

func main(){
    // 사용자 이메일 입력
    var user_email: String = "testuser@example.com" // 테스트용 이메일

    // 인증 코드 생성
    let certiCode = createEmailCode()

    // 이메일 전송
    sendVerificationEmail(userEmail: user_email, certiCode: certiCode)
}


