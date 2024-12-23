
//  ContentView : 화면 이동 뷰

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            TabView {
                GroupPurchaseMain()
                    .tabItem {
                        Label("공구", systemImage: "figure.2")
                    }
                GroupSharingMain()
                    .tabItem {
                        Label("나눔", systemImage: "heart.text.clipboard")
                    }
                ChatListMain()
                    .environmentObject(FireStoreManager())
                    .tabItem {
                        Label("채팅", systemImage: "ellipsis.message.fill")
                    }
                MyHomeMain()
                    .tabItem {
                        Label("마이홈", systemImage: "house")
                    }
            }
        }
        .tint(.black)
    }
}

struct School{
    var schoolID: Int
    var schoolName: String
    var schoolEmail: String
}
var school1 = School(schoolID: 1, schoolName: "한양대학교", schoolEmail: "hanyang.ac.kr")
var school2 = School(schoolID: 2, schoolName: "한양대학교(ERICA)", schoolEmail: "hanyang.ac.kr")

struct User{
    var userID: Int
    var userName: String
    var userPhoneNum: String
    var schoolID: Int
    var userSchoolEmail: String
    var profileImageURL: String
    var termsAgreementYn: Character
    var privacyAgreementYn: Character
    var Age14orOverYn: Character
    var createdAt: String
}
var user1 = User(userID: 1, userName: "김경진", userPhoneNum: "01055513826", schoolID: 1, userSchoolEmail: "yyyyj1@hanyang.ac.kr", profileImageURL: "u.r.l.to.pro/file/image", termsAgreementYn: "y", privacyAgreementYn: "y", Age14orOverYn: "y", createdAt: "2024-03-13 12:00")
var user2 = User(userID: 2, userName: "김현경", userPhoneNum: "01094959692", schoolID: 2, userSchoolEmail: "qwer1111@hanyang.ac.kr", profileImageURL: "u.r.l.to.pro/file/image", termsAgreementYn: "y", privacyAgreementYn: "y", Age14orOverYn: "y", createdAt: "2024-07-19 14:59")
var user3 = User(userID: 3, userName: "김소민", userPhoneNum: "01091132227", schoolID: 1, userSchoolEmail: "ksm22@hanyang.ac.kr", profileImageURL: "u.r.l.to.pro/file/image", termsAgreementYn: "y", privacyAgreementYn: "y", Age14orOverYn: "y", createdAt: "2024-10-15 09:12")
var user4 = User(userID: 4, userName: "김무명", userPhoneNum: "01034568901", schoolID: 2, userSchoolEmail: "dsdaasdfs1004@hanyang.ac.kr", profileImageURL: "u.r.l.to.pro/file/image", termsAgreementYn: "y", privacyAgreementYn: "y", Age14orOverYn: "y", createdAt: "2024-09-15 13:01")
var user5 = User(userID: 5, userName: "이아무", userPhoneNum: "01013131313", schoolID: 1, userSchoolEmail: "tncjs01@hanyang.ac.kr", profileImageURL: "u.r.l.to.pro/file/image", termsAgreementYn: "y", privacyAgreementYn: "y", Age14orOverYn: "y", createdAt: "2024-01-15 12:59")
var user6 = User(userID: 6, userName: "송송이", userPhoneNum: "01074543273", schoolID: 2, userSchoolEmail: "abcde@hanyang.ac.kr", profileImageURL: "u.r.l.to.pro/file/image", termsAgreementYn: "y", privacyAgreementYn: "y", Age14orOverYn: "y", createdAt: "2024-11-06 17:30")

struct Postd{
    var postID: Int
    var userID: Int // users의 fk
    var postCategory: String
    var postCategoryType: String
    var title: String
    var postContent: String
    var location: String
    var wantNum = 2
    var postStatus: String
    var created_at: String
    var chatroomImageURL: String
}
var postd1 = Postd(postID: 1, userID: 3, postCategory: "공구", postCategoryType: "식재료", title: "유기농버섯 공구해욤", postContent: "친구 이모가 버섯키우시는데 완전 유기농이에요!! 한 박스 8000원이고 4박스 이상이면 무료배송!", location: "한플", wantNum: 4, postStatus: "거래중", created_at: "2024-11-10 18:00", chatroomImageURL: "chatroomimage/url")
var postd2 = Postd(postID: 2, userID: 2, postCategory: "공구", postCategoryType: "배달", title: "같이 햄버거 먹으실분! 배달비 무료~", postContent: "햄버거 배달 최소금액이 15000원이라서 같이 시키실분 한분 구합니다~ 12시 30까지 연락주세요", location: "잇빗관", wantNum: 2, postStatus: "거래중", created_at: "2024-11-12 12:00", chatroomImageURL: "criurl")
var postd3 = Postd(postID: 3, userID: 1, postCategory: "공구", postCategoryType: "물품", title: "두루마리 휴지 같이 사실분", postContent: "18개짜리 구매하려고 하는데 너무 많아요. 가격은 인당 3000 생각중이에요", location: "무관", wantNum: 3, postStatus: "거래중", created_at: "2024-11-13 16:00", chatroomImageURL: "criurl")
var postd4 = Postd(postID: 4, userID: 4, postCategory: "나눔", postCategoryType: "식재료", title: "감자 나눔합니다.", postContent: "저희집에 강원도에서 감자 농사 짓는데, 이번에 수확이 잘되서 학우분들 중 필요하신 분 나눠드리려고 합니다. ", location: "한플 앞", postStatus: "거래중", created_at: "2023-12-13 12:30", chatroomImageURL: "criurl")
var postd5 = Postd(postID: 5, userID: 5, postCategory: "나눔", postCategoryType: "배달", title: "맘스터치 햄버거 나눔합니다.", postContent: "햄버거 많이 시켰는데 남아서 나눔합니다.", location: "학생회관 앞", wantNum: 5, postStatus: "거래중", created_at: "2024-11-13 15:50", chatroomImageURL: "criurl")
var postd6 = Postd(postID: 6, userID: 6, postCategory: "나눔", postCategoryType: "물품", title: "냄비세트에서 1번 나눔합니다.", postContent: "냄비세트 중에 하나 필요 없어서 나눔 게시물 올립니다.", location: "ftc 3층", wantNum: 5, postStatus: "거래중", created_at: "2024-10-25 19:25", chatroomImageURL: "criurl")

struct PostImaged{
    var imageURL: String
    var postID: Int
}
var postImaged1 = PostImaged(imageURL: "mushroom", postID: 1)
var postImaged2 = PostImaged(imageURL: "hamburger", postID: 2)
var postImaged3 = PostImaged(imageURL: "tissue", postID: 3)
var postImaged4 = PostImaged(imageURL: "potato", postID: 4)
var postImaged5 = PostImaged(imageURL: "hamburger", postID: 5)
var postImaged6 = PostImaged(imageURL: "mushroom2", postID: 1)

struct PostParticipant{
    var postID: Int
    var userID: Int
    var requestStatus: String
    var requestedAt: String
}
var postParticipantd1 = PostParticipant(postID: 1, userID: 2, requestStatus: "대기중", requestedAt: "NOW()")
var postParticipantd2 = PostParticipant(postID: 2, userID: 2, requestStatus: "대기중", requestedAt: "NOW()")
var postParticipantd3 = PostParticipant(postID: 2, userID: 1, requestStatus: "대기중", requestedAt: "NOW()")
var postParticipantd4 = PostParticipant(postID: 3, userID: 3, requestStatus: "대기중", requestedAt: "NOW()")
var postParticipantd5 = PostParticipant(postID: 4, userID: 4, requestStatus: "대기중", requestedAt: "NOW()")
var postParticipantd6 = PostParticipant(postID: 6, userID: 5, requestStatus: "대기중", requestedAt: "NOW()")

struct Commentd{
    var commentID: Int
    var userID: Int
    var postID: Int
    var commentContent: String
    var commentCreatedAt: String
}
var commentd1 = Commentd(commentID: 1, userID: 1, postID: 1, commentContent: "안녕하세요?!", commentCreatedAt: "2024-11-10 18:00")
var commentd2 = Commentd(commentID: 2, userID: 2, postID: 1, commentContent: "안녕하세요.", commentCreatedAt: "2024-11-10 19:00")
var commentd3 = Commentd(commentID: 3, userID: 2, postID: 1, commentContent: "반갑습니다.", commentCreatedAt: "2024-11-10 20:00")
var commentd4 = Commentd(commentID: 4, userID: 1, postID: 1, commentContent: "공구하시죠?", commentCreatedAt: "2024-11-10 21:00")
var commentd5 = Commentd(commentID: 5, userID: 3, postID: 6, commentContent: "안녕하세요~!", commentCreatedAt: "2024-11-10 18:00")
var commentd6 = Commentd(commentID: 6, userID: 2, postID: 6, commentContent: "참여했습니다.", commentCreatedAt: "2024-11-10 19:00")

struct Replyd{
    var replyID: Int
    var userID: Int
    var replyContent: String
    var replyCreatedAt: String
    var commentID: Int
}
var replyd1 = Replyd(replyID: 1, userID: 2, replyContent: "참여하셨나요?", replyCreatedAt: "2024-11-21 19:00", commentID: 1)
var replyd2 = Replyd(replyID: 2, userID: 2, replyContent: "참여하셨나요??", replyCreatedAt: "2024-11-21 19:00", commentID: 6)
var replyd3 = Replyd(replyID: 3, userID: 5, replyContent: "예", replyCreatedAt: "2024-11-21 20:00", commentID: 6)

struct PostLiked{
    var postID: Int
    var userID: Int
}
var postLiked1 = PostLiked(postID: 1, userID: 1)
var postLiked2 = PostLiked(postID: 1, userID: 3)
var postLiked3 = PostLiked(postID: 1, userID: 5)
var postLiked4 = PostLiked(postID: 3, userID: 2)
var postLiked5 = PostLiked(postID: 4, userID: 4)
var postLiked6 = PostLiked(postID: 3, userID: 1)

struct ChatMessaged{
    var messageID: Int
    var postID: Int
    var senderID: Int
    var messageContent: String
    var messageImageURL: String
    var sentAt: String
}
var chatMessaged1 = ChatMessaged(messageID: 1, postID: 1, senderID: 1, messageContent: "다들 안녕하세요.", messageImageURL: "없음", sentAt: "2024-11-21 21:00")
var chatMessaged2 = ChatMessaged(messageID: 2, postID: 1, senderID: 1, messageContent: "공구 계획대로 진행합시다.", messageImageURL: "없음", sentAt: "2024-11-21 22:00")
var chatMessaged3 = ChatMessaged(messageID: 3, postID: 1, senderID: 2, messageContent: "쿨공구 감사합니다.", messageImageURL: "없음", sentAt: "2024-11-21 23:00")
var chatMessaged4 = ChatMessaged(messageID: 4, postID: 1, senderID: 3, messageContent: "^^", messageImageURL: "miurl", sentAt: "2024-11-21 23:30")

#Preview {
    ContentView()
}

