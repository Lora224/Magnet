import SwiftUI

struct FamilyGroupView: View {
    @State var familyName: String
    let familyEmoji: String
    @State var backgroundColor: Color
    
    // Using placeholder avatars; replace "avatarPlaceholder" with real asset names.
    private let leftMembers: [String] = ["Margaret", "Anna", "George", "Amanda"]
    private let rightMembers: [String] = ["Margaret 2", "Anna 2", "George 2", "Amanda 2"]
    
    // MARK: – Custom colors
    private let magnetBrown  = Color(red: 0.294, green: 0.212, blue: 0.129)  // #4B3621
    private let magnetYellow = Color(red: 1.000, green: 0.961, blue: 0.855)  // #FFF5DA
    
    var body: some View {
        ZStack {
            // Background: ignore safe area only on bottom
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: – Top bar (hamburger on left, calendar on right)
                
                HStack {
                    // Hamburger menu icon (kept at default size)
                    NavigationLink(destination: SideBarView()) {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .frame(width: 65, height: 35)
                            .foregroundColor(magnetBrown)
                            .padding(.leading, 25)
                    }
                    Spacer()
                    
//                    // Calendar icon (sized 50×50)
//                    NavigationLink(destination: CalendarView()) {
//                        Image(systemName: "calendar")
//                            .resizable()
//                            .frame(width: 50, height: 50)
//                            .foregroundColor(magnetBrown)
//                            .padding(.trailing, 16)
//                    }
                }
                // Respect iPad’s top safe area
                .padding(.top, 20)
                .background(backgroundColor)

                
                // MARK: – Emoji avatar + back arrow
                ZStack {
                    // Centered emoji inside a white circle (emoji at size 64)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 150, height: 150)
                        .overlay(
                            Text(familyEmoji)
                                .font(.system(size: 75))
                        )
                        .shadow(radius: 4)
                    
                    // Edit pencil overlay (50×50 circle + pencil icon)
                    Button(action:{/*back button action*/}){
                        Circle()
                            .fill(magnetBrown)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "pencil")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            )
                    }
                        
                            .offset(x: 50, y: 50)
                    
                    // Back arrow (sized 50×50)
                        HStack {
                            NavigationLink(destination: MainView()) {
                                Image(systemName: "arrowshape.backward.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 50)
                                    .foregroundColor(magnetBrown)
                                    .padding(.leading, 16)
                            }
                            Spacer()
                        
                        .frame(height: 120) // match emoji circle height
                    }
                }
                .padding(.top, 8)
                
                // MARK: – Family name
                HStack(spacing: 16) {
                    TextField("Enter family name", text: $familyName)
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.0)
                                )
                        )
                        .frame(width: 240)

                    ColorPicker("", selection: $backgroundColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 64, height: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1.0)
                        )
                }
                .padding(.top, 24)
                .padding(.horizontal, 40)


                
                // MARK: – Members list (two columns)
                ScrollView {
                    HStack(alignment: . top, spacing: 48) {
                        // Left column
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(leftMembers, id: \.self) { member in
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 75, height: 75)
                                        .overlay(
                                            Image("avatarPlaceholder") // replace with actual member image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 56, height: 56)
                                                .clipShape(Circle())
                                        )
                                        .shadow(radius: 2)
                                    
                                    Text(member)
                                        .font(.headline)
                                        .foregroundColor(magnetBrown)
                                }
                            }
                        }
                        
                        // Right column
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(rightMembers, id: \.self) { member in
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 75, height: 75)
                                        .overlay(
                                            Image("avatarPlaceholder") // replace with actual member image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 56, height: 56)
                                                .clipShape(Circle())
                                        )
                                        .shadow(radius: 2)
                                    
                                    Text(member)
                                        .font(.headline)
                                        .foregroundColor(magnetBrown)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, 24)
                
                Spacer()
                
                // MARK: – Invite button
                Button(action: { /* no action, layout only */ }) {
                    HStack(spacing: 12) {
                        Image(systemName: "link")
                            .font(.system(size: 30, weight: .regular))
                            .frame(width: 50, height: 35)
                        Text("Invite")
                            .font(.title3).bold()
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 32)
                    .background(magnetBrown)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                .padding(.bottom, 32)
                .padding(.top, 24)
            }
        }
    }
}

// MARK: – Preview
#Preview{
    FamilyGroupView(
        familyName: "Family 1",
        familyEmoji: "😍",
        backgroundColor: Color(red: 1.000, green: 0.961, blue: 0.855)
    )
}
