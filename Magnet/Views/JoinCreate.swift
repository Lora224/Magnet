import SwiftUI

struct JoinCreate: View {
    @State private var familyName = ""
    @State private var backgroundColor = Color(red: 0.82, green: 0.914, blue: 0.965)
    @State private var showLinkField = false
    @State private var linkURL: String = ""
    @StateObject private var famManager = Sid()

    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    ZStack {
                        GridPatternBackground()
                            .ignoresSafeArea()

                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white.opacity(0.88))
                            .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.6)
                            .shadow(color: Color.black.opacity(0.2), radius: 15)
                            .overlay(
                                JoinCreateContentView(
                                    geo: geo,
                                    familyName: $familyName,
                                    backgroundColor: $backgroundColor,
                                    showLinkField: $showLinkField,
                                    linkURL: $linkURL,
                                    famManager: famManager,
                                    authManager: authManager
                                )
                            )
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

