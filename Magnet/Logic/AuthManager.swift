import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

class AuthManager: ObservableObject {
    @Published var alertMessage = ""
    @Published var showingAlert = false
    @Published var currentUserID: String? = nil
    @Published var isUserLoggedIn: Bool = false
    
    @Published var shouldForceLoginAfterFlow: Bool = false
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.isUserLoggedIn = (user != nil && (self?.shouldForceLoginAfterFlow ?? false))
                self?.currentUserID = user?.uid
                print("🔥 Auth state changed → isUserLoggedIn = \(self?.isUserLoggedIn ?? false), shouldForceLoginAfterFlow = \(self?.shouldForceLoginAfterFlow ?? false)")
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Register
    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.alertMessage = "Registration error: \(error.localizedDescription)"
                self.showingAlert = true
                completion(false)
                return
            }
            
            guard let uid = result?.user.uid else {
                self.alertMessage = "Could not read user UID."
                self.showingAlert = true
                completion(false)
                return
            }
            
            self.currentUserID = uid
            
            let userData: [String: Any] = [
                "uid": uid,
                "email": email,
                "createdAt": Timestamp(date: Date())
            ]
            
            Firestore.firestore().collection("users").document(uid).setData(userData) { err in
                if let err = err {
                    self.alertMessage = "Firestore error: \(err.localizedDescription)"
                    self.showingAlert = true
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.alertMessage = "Login error: \(error.localizedDescription)"
                self.showingAlert = true
                completion(false)
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                self.alertMessage = "Could not read user UID after login."
                self.showingAlert = true
                completion(false)
                return
            }
            
            self.currentUserID = uid
            
            let updateData = ["lastLogin": Timestamp(date: Date())]
            
            Firestore.firestore().collection("users").document(uid).updateData(updateData) { err in
                if let err = err {
                    self.alertMessage = "Firestore update failed: \(err.localizedDescription)"
                    self.showingAlert = true
                    completion(false)
                } else {
                    self.shouldForceLoginAfterFlow = true
                    completion(true)
                }
            }
        }
    }

    // MARK: - Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            print("✅ User signed out.")
            self.shouldForceLoginAfterFlow = false
        } catch {
            print("❌ Failed to logout: \(error.localizedDescription)")
        }
    }
}

