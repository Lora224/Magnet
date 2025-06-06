//
//  Login.swift
//  Magnet
//
//  Created by Emily Zhang on 6/6/2025.
//

import SwiftUI

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject private var authManager = AuthManager()

    private let magnetBrown = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    
    var body: some View {
        ZStack {
            Image("loginBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.white.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("Welcome to Magnet!")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(magnetBrown)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("A shared fridge to show your loved ones you care")
                        .font(.system(size: 25))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 110/255, green: 110/255, blue: 110/255))
                }

                Group {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)

                    SecureField("Password", text: $password)
                        .submitLabel(.done)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                }
                .frame(maxWidth: 400)

                HStack {
                    Button("Sign Up") {
                        authManager.register(email: email, password: password)

                    }
                    Spacer()

                    Button("Log In") {
                        authManager.login(email: email, password: password)
                    }

                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: 400)
            }
            .tint(magnetBrown)
            .font(.system(size: 30, weight: .bold))
            .padding(60)
            .background(Color.white.opacity(0.85))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .alert(authManager.alertMessage, isPresented: $authManager.showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

#Preview {
    Login()
}
