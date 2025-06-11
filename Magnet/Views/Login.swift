import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authManager: AuthManager

    @State private var showUsernameDialog = false
    @State private var showJoinCreate = false

    @State private var isSignUpFlow = false

    var body: some View {
        NavigationStack {
            ZStack {
                LoginContentView(
                    email: $email,
                    password: $password,
                    onSignUp: {
                        authManager.register(email: email, password: password) { success in
                            if success {
                                isSignUpFlow = true
                                withAnimation(.spring()) {
                                    showUsernameDialog = true
                                }
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
                .blur(radius: showUsernameDialog ? 3 : 0)
                .disabled(showUsernameDialog)

                if showUsernameDialog {
                    UsernameSetupView {
                        withAnimation(.spring()) {
                            showUsernameDialog = false
                        }

                        if isSignUpFlow {
                            showJoinCreate = true
                        } else {
                            checkFamilies()
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
                }

                NavigationLink("", isActive: $showJoinCreate) {
                    JoinCreate()
                        .navigationBarBackButtonHidden(true)
                }
            }
            .alert(authManager.alertMessage, isPresented: $authManager.showingAlert) {
                Button("OK", role: .cancel) { }
            }
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
                    withAnimation(.spring()) {
                        showUsernameDialog = true
                    }
                }
                return
            }

            if let name = data["name"] as? String, !name.isEmpty {
                print("✅ User has name: \(name), proceeding to check families")
                DispatchQueue.main.async {
                    checkFamilies()
                }
            } else {
                print("❌ User has no name → show username dialog")
                DispatchQueue.main.async {
                    withAnimation(.spring()) {
                        showUsernameDialog = true
                    }
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
                print("❌ No families field → go to JoinCreate")
                DispatchQueue.main.async {
                    showJoinCreate = true
                }
                return
            }

            if families.isEmpty {
                print("❌ Families empty → go to JoinCreate")
                DispatchQueue.main.async {
                    showJoinCreate = true
                }
            } else {
                print("✅ Families exist → go to MainView")
                DispatchQueue.main.async {
                    // ⭐️ 关键改这里 → 不用 showMainView，直接改 AppState
                    appState.isLoggedIn = true
                }
            }
        }
    }
}
