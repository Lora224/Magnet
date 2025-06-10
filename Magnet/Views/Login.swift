import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject private var authManager = AuthManager()

    @State private var fullScreenView: FullScreenPage? = nil
    @State private var isSignUpFlow = false

    var body: some View {
        ZStack {
            LoginContentView(
                email: $email,
                password: $password,
                onSignUp: {
                    authManager.register(email: email, password: password) { success in
                        if success {
                            isSignUpFlow = true
                            fullScreenView = .usernameSetup
                        }
                    }
                },
                onLogIn: {
                    authManager.login(email: email, password: password) { success in
                        if success {
                            isSignUpFlow = false
                            checkUserProfile()
                        }
                    }
                }
            )
        }
        .fullScreenCover(item: $fullScreenView, onDismiss: {
            if fullScreenView == .usernameSetup {
                if isSignUpFlow {
                    fullScreenView = .joinCreate
                } else {
                    checkFamilies()
                }
            }
        }) { page in
            switch page {
            case .joinCreate:
                JoinCreate()
            case .mainView:
                MainView()
            case .usernameSetup:
                UsernameSetupView()
            }
        }
        .alert(authManager.alertMessage, isPresented: $authManager.showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    private func checkUserProfile() {
        guard let userID = authManager.currentUserID else {
            print("❌ No user ID after login")
            return
        }

        Firestore.firestore().collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch user document:", error)
                return
            }

            guard let data = snapshot?.data() else {
                print("❌ No user document found")
                DispatchQueue.main.async {
                    fullScreenView = .usernameSetup
                }
                return
            }

            if let name = data["name"] as? String, !name.isEmpty {
                print("✅ User has name: \(name), proceeding to check families")
                DispatchQueue.main.async {
                    checkFamilies()
                }
            } else {
                print("❌ User has no name → navigating to UsernameSetupView")
                DispatchQueue.main.async {
                    fullScreenView = .usernameSetup
                }
            }
        }
    }

    private func checkFamilies() {
        guard let userID = authManager.currentUserID else {
            print("❌ No user ID after login")
            return
        }

        Firestore.firestore().collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch user document:", error)
                return
            }

            guard let data = snapshot?.data(),
                  let families = data["families"] as? [String] else {
                print("❌ No families field → navigating to JoinCreate")
                DispatchQueue.main.async {
                    fullScreenView = .joinCreate
                }
                return
            }

            if families.isEmpty {
                print("❌ Families empty → navigating to JoinCreate")
                DispatchQueue.main.async {
                    fullScreenView = .joinCreate
                }
            } else {
                print("✅ Families exist → navigating to MainView")
                DispatchQueue.main.async {
                    fullScreenView = .mainView
                }
            }
        }
    }
}

enum FullScreenPage: Identifiable {
    case joinCreate
    case mainView
    case usernameSetup

    var id: String {
        switch self {
        case .joinCreate: return "joinCreate"
        case .mainView: return "mainView"
        case .usernameSetup: return "usernameSetup"
        }
    }
}

