import SwiftUI

struct MyHomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 16) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                    Text("김무명")
                        .font(.title)
                        .bold()
                    
                    Text("한양대학교 서울캠")
                        .font(.subheadline)
                    
                    Text("컴퓨터소프트웨어학과")
                        .font(.subheadline)
                    
                    Button(action: {
                    }) {
                        Text("프로필 수정")
                            .font(.callout)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 30)
                
                Divider()
                
                HStack {
                    Text("매너 온도")
                        .font(.headline)
                    Spacer()
                    Text("40.5 도")
                        .font(.headline)
                }
                .padding()
                
                Divider()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("나의 거래")
                        .font(.headline)
                        .padding(.leading)
                    
                    HStack {
                        Image(systemName: "heart")
                        Text("관심 목록")
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "pencil")
                        Text("내가 작성한 게시글")
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "hand.raised")
                        Text("참여한 거래")
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                
                Divider()

                VStack(alignment: .leading, spacing: 15) {
                    Text("기타")
                        .font(.headline)
                        .padding(.leading)

                    NavigationLink(destination: PolicyView()) {
                        HStack {
                            Text("이용약관 (개인 정보 처리 방침)")
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    NavigationLink(destination: FAQListView()){
                        HStack {
                            Text("자주하는 질문 FAQ")
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    
                    NavigationLink(destination: AccountInfoView()) {
                        HStack {
                            Text("계정 정보")
                            Spacer()
                            Text("카카오 (가입일: 2024.9.7)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                    }) {
                        VStack {
                            Image(systemName: "wrench.fill")
                            Text("공구")
                        }
                    }
                    Spacer()
                    Button(action: {
                    }) {
                        VStack {
                            Image(systemName: "gift.fill")
                            Text("나눔")
                        }
                    }
                    Spacer()
                    Button(action: {
                    }) {
                        VStack {
                            Image(systemName: "message.fill")
                            Text("채팅")
                        }
                    }
                    Spacer()
                    Button(action: {
                    }) {
                        VStack {
                            Image(systemName: "house.fill")
                            Text("마이홈")
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            }
            .navigationTitle("마이홈")
        }
    }
}

struct MyHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MyHomeView()
    }
}


struct ContentView: View {
    var body: some View {
        MyHomeView()  // 위에서 작성한 MyHomeView 호출
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
