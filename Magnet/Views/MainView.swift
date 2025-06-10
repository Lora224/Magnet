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
         
            .navigationBarBackButtonHidden(true)
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
                        CameraView(userID: userID, familyID: "544CF263-E10E-4884-9E60-DFE60B295FDB")
                    } else {
                        Text("⚠️ Please log in first.")
                    }
                case "mic": VoiceInputView()
                default: EmptyView()
                }
            }
        }
        // MainView.swift  — add inside body
        .onAppear {
            // MARK: - Life-cycle entry
            debugPrint("💡 MainView.onAppear @", Date())

            // 1️⃣  Current user
            guard let user = Auth.auth().currentUser else {
                debugPrint("❌ No authenticated user — UI will stay empty")
                return
            }
            let userID = user.uid
            debugPrint("👤 Auth user UID:", userID)

            // 2️⃣  User document
            let usersRef = Firestore.firestore()
                .collection("users")
                .document(userID)
            debugPrint("🔎 Fetching user document:", usersRef.path)

            usersRef.getDocument { [weak stickyManager] userSnap, userErr in
                if let userErr = userErr {
                    debugPrint("🔥 User doc fetch failed:", userErr.localizedDescription)
                    return
                }
                guard let userData = userSnap?.data() else {
                    debugPrint("⚠️ User snapshot is nil / empty")
                    return
                }
                debugPrint("✅ User data:", userData)

                guard let families = userData["families"] as? [String],
                      !families.isEmpty else {
                    debugPrint("🚫 Key 'families' missing or empty in user doc")
                    return
                }
                let familyID = families.first!
                debugPrint("🏠 Primary familyID resolved:", familyID)

                // 3️⃣  Family document
                let familyRef = Firestore.firestore()
                    .collection("families")
                    .document(familyID)
                debugPrint("🔎 Fetching family document:", familyRef.path)

                familyRef.getDocument { famSnap, famErr in
                    if let famErr = famErr {
                        debugPrint("🔥 Family doc fetch failed:", famErr.localizedDescription)
                        return
                    }
                    guard let famData = famSnap?.data() else {
                        debugPrint("⚠️ Family snapshot nil / empty for", familyID)
                        return
                    }
                    debugPrint("✅ Family data:", famData)

                    guard let memberIDs = famData["memberIDs"] as? [String],
                          !memberIDs.isEmpty else {
                        debugPrint("🚫 'memberIDs' missing / empty – keys present:", famData.keys)
                        return
                    }
                    debugPrint("👨‍👩‍👧‍👦 MemberIDs:", memberIDs)

                    // 4️⃣  Load sticky notes (MAIN thread!)
                    DispatchQueue.main.async {
                        debugPrint("📥 Calling loadStickyNotes for", familyID)
                        stickyManager?.loadStickyNotes(
                            for: familyID,
                            memberIDs: memberIDs,
                            canvasSize: UIScreen.main.bounds.size
                        )
                    }
                }
            }
        }


    }
}

#Preview {
    MainView()
}

