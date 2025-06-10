import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MainView: View {
    @State private var isMenuOpen = false
    @State private var navigationTarget: String?
    @StateObject private var stickyManager = StickyDisplayManager()
    @State private var canvasOffset = CGSize.zero
    @State private var zoomScale: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Image("MainBack")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.2)

                // Sticky Notes Canvas
                StickyCanvasView(
                    stickyManager: stickyManager,
                    canvasOffset: $canvasOffset,
                    zoomScale: $zoomScale
                )

                // Top Bar + Debug button
                VStack(spacing: 0) {
                    TopFamilyBar()

                    HStack(spacing: 12) {
                        Spacer()
                        NavigationLink(destination: StickyNoteTestView()) {
                            Text("StickyNote")
                                .font(.caption)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                        .padding(.trailing, 12)
                    }
                    .padding(.top, 6)
                    Spacer()
                }

                // Floating Action Button + Radial Menu
                VStack {
                    Spacer()
                    ZStack {
                        Group {
                            // Text Input
                            Button {
                                navigationTarget = "text"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isMenuOpen = false
                                }
                            } label: {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Text("T")
                                            .font(.system(size: 30))
                                            .bold()
                                            .foregroundColor(.black)
                                    )
                            }
                            .offset(y: isMenuOpen ? -120 : 0)
                            .opacity(isMenuOpen ? 1 : 0)

                            // Camera Input
                            Button {
                                navigationTarget = "camera"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isMenuOpen = false
                                }
                            } label: {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.black)
                                    )
                            }
                            .offset(x: isMenuOpen ? -100 : 0, y: isMenuOpen ? -40 : 0)
                            .opacity(isMenuOpen ? 1 : 0)

                            // Voice Input
                            Button {
                                navigationTarget = "mic"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isMenuOpen = false
                                }
                            } label: {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "mic.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.black)
                                    )
                            }
                            .offset(x: isMenuOpen ? 100 : 0, y: isMenuOpen ? -40 : 0)
                            .opacity(isMenuOpen ? 1 : 0)
                        }
                        .animation(.spring(), value: isMenuOpen)

                        // Plus / X Button
                        Button {
                            withAnimation(.spring()) {
                                isMenuOpen.toggle()
                            }
                        } label: {
                            Circle()
                                .fill(Color.magnetBrown)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: isMenuOpen ? "xmark" : "plus")
                                        .font(.system(size: 30))
                                        .bold()
                                        .foregroundColor(.white)
                                )
                                .shadow(radius: 6)
                        }
                    }
                    .frame(height: 70)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)

                // Navigation trigger
                NavigationLink(value: navigationTarget, label: { EmptyView() })
            }
            // 👇 Add here ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        do {
                            try Auth.auth().signOut()
                            // Dismiss back to Login → because we use fullScreenCover
                            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                        } catch {
                            print("Failed to logout: \(error.localizedDescription)")
                        }
                    }
                }
            }
            // 👆 Add end ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
            .navigationDestination(item: $navigationTarget) { target in
                switch target {
                case "text":
                    if let userID = Auth.auth().currentUser?.uid {
                        TextInputView(familyID: "544CF263-E10E-4884-9E60-DFE60B295FDB", userID: userID)
                    } else {
                        Text("⚠️ Please log in first.")
                    }
                case "camera":
                    if let userID = Auth.auth().currentUser?.uid {
                        CameraView(userID: userID, familyID: "gmfQH98GinBcb26abjnY")
                    } else {
                        Text("⚠️ Please log in first.")
                    }
                case "mic": VoiceInputView()
                default: EmptyView()
                }
            }
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                let userID = user.uid
                print("👤 Current user: \(userID)")

                Firestore.firestore().collection("users").document(userID).getDocument { snapshot, error in
                    if let error = error {
                        print("❌ Failed to fetch user document:", error)
                        return
                    }

                    guard let data = snapshot?.data(),
                          let families = data["families"] as? [String],
                          let familyID = families.first else {
                        print("❌ No families found for user")
                        return
                    }

                    print("🏠 Using family ID:", familyID)

                    Firestore.firestore().collection("families").document(familyID).getDocument { famSnap, _ in
                        guard let memberIDs = famSnap?.data()?["memberIDs"] as? [String] else {
                            print("❌ No memberIDs in family document")
                            return
                        }
                        print("📂 Raw family data:", famSnap?.data() ?? "nil")
                        print("👨‍👩‍👧‍👦 Family members:", memberIDs)

                        let screenSize = UIScreen.main.bounds.size
                        stickyManager.loadStickyNotes(
                            for: familyID,
                            memberIDs: memberIDs,
                            canvasSize: screenSize
                        )
                    }
                }
            } else {
                print("❌ No user is logged in")
            }
        }
    }
}

#Preview {
    MainView()
}

