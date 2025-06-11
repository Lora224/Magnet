import SwiftUI
import FirebaseCore
import SwiftData
import Firebase
import FirebaseAppCheck
import FirebaseAuth
import FirebaseStorage


class AppDelegate: NSObject, UIApplicationDelegate {
//    override init() {
//        // ✅ 🔒 Register Debug provider FIRST
//        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
//        super.init()
//    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        print("✅ FirebaseApp configured successfully in AppDelegate")
        return true
    }
}

class AppState: ObservableObject {
    // @Published var isLoggedIn = false
}


@main
struct MagnetApp: App {
    @StateObject var authManager = AuthManager()
    @StateObject private var stickyManager = StickyDisplayManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("✅ FirebaseApp configured in MagnetApp.init()")
        }
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isUserLoggedIn {
                MainView()
                    .environmentObject(authManager)
                    .environmentObject(stickyManager)
            } else {
                Login()
                    .environmentObject(authManager)
                    .environmentObject(stickyManager)
            }
        }
    }
}

