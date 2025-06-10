import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UsernameSetupView: View {
    @State private var username = ""
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    @Environment(\.dismiss) var dismiss

    private let magnetBrown = Color(red: 0.294, green: 0.212, blue: 0.129)

    var body: some View {
        ZStack {
            Image("loginBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.white.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Please enter your username. Don't worry, you can change it later.")
                    .font(.system(size: 25, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(magnetBrown)
                    .padding()

                HStack {
                    TextField("Username", text: $username)
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .frame(maxWidth: 300)

                    Button(action: {
                        saveUsername()
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(width: 24, height: 24)
                        } else {
                            Text("Confirm")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(username.isEmpty || isLoading ? Color.gray : magnetBrown)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(username.isEmpty || isLoading)
                }
                .frame(maxWidth: 400)
            }
            .padding()
            .background(Color.white.opacity(0.85))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func saveUsername() {
        guard let userID = Auth.auth().currentUser?.uid else {
            showError(message: "Unable to get current user ID.")
            return
        }

        isLoading = true

        Firestore.firestore().collection("users").document(userID).setData([
            "name": username
        ], merge: true) { error in
            isLoading = false

            if let error = error {
                showError(message: "Failed to save username: \(error.localizedDescription)")
            } else {
                print("✅ Username saved successfully.")
                dismiss()
            }
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}
