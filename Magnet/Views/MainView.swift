import SwiftUI

struct MainView: View {
    @State private var isMenuOpen = false
    @State private var navigationTarget: String?
   
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("MainBack")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.2)


                VStack(spacing: 0) {
                    TopFamilyBar()

                    // Debug DB buttons
                    HStack(spacing: 12) {
                        Spacer()

                        NavigationLink(destination: FamilyManagerView()) {
                            Text("Family DB")
                                .font(.caption)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }

                        NavigationLink(destination: UserManagerView()) {
                            Text("User DB")
                                .font(.caption)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                        .padding(.trailing, 12)
                    }
                    .padding(.top, 6)

                    Spacer()
                }

                // Notes
                ZStack {
                    NavigationLink(destination: NotesDetailView()
                            .navigationBarBackButtonHidden(true)
                    ) {
                        Image("blueNoteLines")
                            .resizable()
                            .frame(width: 250, height: 250)
                            .position(x: 450, y: 230)
                            .rotationEffect(.degrees(-8))
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: NotesDetailView()) {
                        Image("pinkNote")
                            .resizable()
                            .frame(width: 250, height: 250)
                            .position(x: 500, y: 520)
                            .rotationEffect(.degrees(8))
                    }
                    .buttonStyle(PlainButtonStyle())

                    NavigationLink(destination: NotesDetailView()) {
                        Image("yellowNote")
                            .resizable()
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(6))
                            .position(x: 770, y: 420)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                case "text": TextInputView()
                case "camera": CameraView()
                case "mic": VoiceInputView()
                default: EmptyView()
                }
            }
        }
    }
}


#Preview {
    MainView()
}
