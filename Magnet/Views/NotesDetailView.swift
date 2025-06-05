import SwiftUI

struct NotesDetailView: View {
    
    // Hex-based colors as properties
    private let lightGray     = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    private let profilePic = ["profile1", "profile2", "profile3"]
    
    var body: some View {
        ZStack {
            // Top Bar
            VStack {
                TopFamilyBar()
                Spacer()
                
                // Magnet Reactions Bar
                ZStack {
                    RoundedRectangle(cornerRadius: 35)
                        .fill(lightGray)
                        .frame(width: 500, height: 80)
                    
                    HStack(spacing: 90) {
                        Image("heartMagnet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                        
                        Image("clapMagnet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                        
                        Image("laughMagnet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                    }
                }
                Spacer()
                Image(systemName: "chevron.compact.up")
                    .font(.system(size: 60))
                    .foregroundColor(Color.magnetBrown)
            }
            .zIndex(3)
            .background {
                VStack(alignment: .center) {
                    // Note Cards with Profile Photos
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 24) {
                            ForEach(0..<3) { index in
                                ZStack(alignment: .top) {
                                    Image("blueNotePlain")
                                        .resizable()
                                        .scaledToFill()
                                        .shadow(color: Color.black.opacity(0.10), radius: 15, x: 10, y: 10)
                                        .frame(height: 700)
                                    Image(profilePic[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .shadow(radius: 6)
                                        .offset(y: 40)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 120)
            }
            
            // Back Arrow at top-left of screen
            VStack {
                HStack {
                    Image(systemName: "arrowshape.backward.fill")
                        .font(.system(size: 50))
                        .padding(.leading, 30)
                        .padding(.top, 100)
                    Spacer()
                }
                .zIndex(0)
                Spacer()
            }
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    NotesDetailView()
}



