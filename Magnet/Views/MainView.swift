import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MainView: View {
    @State private var isMenuOpen = false
    @State private var navigationTarget: String?
    @StateObject private var stickyManager = StickyDisplayManager()
    @State private var canvasOffset = CGSize.zero
    @State private var zoomScale: CGFloat = 1.0
    @State private var families: [Family] = []
    @State private var selectedFamilyIndex = 0

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
                    TopFamilyBar(
                        families: $families,
                        selectedIndex: $selectedFamilyIndex
                    )

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
                        let familyIdString:String = families[selectedFamilyIndex].id
                        TextInputView(familyID: familyIdString, userID: userID)
                    } else {
                        Text("⚠️ Please log in first.")
                    }
                case "camera":
                    if let userID = Auth.auth().currentUser?.uid {
                        let familyIdString:String = families[selectedFamilyIndex].id
                        CameraView(userID: userID, familyID: familyIdString)
                    } else {
                        Text("⚠️ Please log in first.")
                    }
                case "mic": VoiceInputView()
                default: EmptyView()
                }
            }
        }
        .onAppear(perform: loadUserFamilies)
        .onChange(of: selectedFamilyIndex) { _ in
            loadNotesForCurrentFamily()
        }


    }
    private func loadUserFamilies() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("families")
          .whereField("memberIDs", arrayContains: uid)
          .getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }
            self.families = docs.compactMap { doc in
                let data = doc.data()
                return Family(
                    id:          doc.documentID,
                    name:        data["name"]       as? String  ?? "<No Name>",
                    inviteURL:   data["inviteURL"]  as? String  ?? "",
                    memberIDs:   data["memberIDs"]  as? [String] ?? [],
                    red:         data["red"]        as? Double  ?? 1.0,
                    green:       data["green"]      as? Double  ?? 1.0,
                    blue:        data["blue"]       as? Double  ?? 1.0,
                    profilePic:  data["profilePic"] as? Data
                )
            }
            // start at the first family
            self.selectedFamilyIndex = 0
            loadNotesForCurrentFamily()
        }
    }

    private func loadNotesForCurrentFamily() {
        guard families.indices.contains(selectedFamilyIndex) else { return }
        let family = families[selectedFamilyIndex]
        stickyManager.loadStickyNotes(
            for: family.id,
            memberIDs: family.memberIDs,
            canvasSize: UIScreen.main.bounds.size
        )
    }

    
}

#Preview {
    MainView()
}

