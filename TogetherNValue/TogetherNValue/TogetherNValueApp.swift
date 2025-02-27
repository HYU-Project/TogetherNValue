import SwiftUI
import FirebaseCore

// Firebase 초기화를 위한 AppDelegate 정의
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TogetherNValueApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userManager = UserManager()
    var body: some Scene {
        WindowGroup {
            FirstPageView()
                .environmentObject(UserManager())
        }
    }
}
