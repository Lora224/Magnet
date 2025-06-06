import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    TopFamilyBar()
                    
                    // 🧪 Debug buttons for database testing
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


                ZStack {
                    NavigationLink(destination: NotesDetailView()) {
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

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: CameraView()) {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 28)
                                .padding(12)
                                .foregroundColor(.magnetBrown) // or whatever color
                        }
                    
                        Button(action: {
                            print("Add tapped")
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(Color.magnetBrown)
                                .shadow(radius: 6)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
