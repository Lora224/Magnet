import SwiftUI
import FirebaseFirestore
import FirebaseAuth




struct MainView: View {
    @State private var isMenuOpen = false
    @State private var navigationTarget: String?
    @StateObject private var stickyManager = StickyDisplayManager()
    @State private var canvasOffset = CGSize.zero
    @GestureState private var dragOffset = CGSize.zero
    @State private var zoomScale: CGFloat = 1.0

//replace with real source
    let currentFamilyID = "gmfQH98GinBcb26abjnY"
    let currentFamilyMemberIDs = ["S6KEzK9eSHaSQACvUH9nm83MbGi1"]



    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("MainBack")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.2)
                
                // Notes
                ZStack {
                    ZStack {
                        ForEach(stickyManager.displayedNotes) { positioned in
                            StickyNoteView(note: positioned.note, reactions: positioned.reactions)
                                .rotationEffect(positioned.rotationAngle)
                                .position(positioned.position)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: positioned.id)
                        }
                    }
                    .offset(x: canvasOffset.width + dragOffset.width,
                            y: canvasOffset.height + dragOffset.height)
                    .scaleEffect(zoomScale)
                    .gesture(
                           MagnificationGesture()
                               .onChanged { value in
                                   zoomScale = min(max(value, 0.8), 2.5) // clamp zoom
                               }
                       )
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                canvasOffset.width += value.translation.width
                                canvasOffset.height += value.translation.height
                            }
                    )
                }



                VStack(spacing: 0) {
                    TopFamilyBar()

                    // Debug DB buttons
                    HStack(spacing: 12) {
                        Spacer()

//                        NavigationLink(destination: FamilyManagerView()) {
//                            Text("Family DB")
//                                .font(.caption)
//                                .padding(8)
//                                .background(Color.gray.opacity(0.2))
//                                .foregroundColor(.blue)
//                                .cornerRadius(8)
//                        }
//
//                        NavigationLink(destination: UserManagerView()) {
//                            Text("User DB")
//                                .font(.caption)
//                                .padding(8)
//                                .background(Color.gray.opacity(0.2))
//                                .foregroundColor(.green)
//                                .cornerRadius(8)
//                        }
                        //Debug Sticky Note test view
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

                // Floating Action Button and Radial Menu
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
                                    .overlay(Text("T")
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

                // Navigation trigger (always present)
                NavigationLink(value: navigationTarget, label: { EmptyView() })
            }

            .navigationDestination(item: $navigationTarget) { target in
                switch target {
                case "text":
                    if let userID = Auth.auth().currentUser?.uid {
                        TextInputView(familyID: "gmfQH98GinBcb26abjnY", userID: userID)
                    } else {
                        Text("⚠️ Please log in first.")
                    }
                case "camera": CameraView()
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
