import SwiftUI

struct TopFamilyBar: View {
    private let magnetBrown   = Color(red: 0.294, green: 0.212, blue: 0.129)
    private let magnetYellow  = Color(red: 1.000, green: 0.961, blue: 0.855)

    @State private var isSidebarVisible = false

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(magnetYellow)
                        .frame(height: 90)
                    
                    // Centered Family Title
                    HStack(spacing: 24) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 40))

                        Text("🎉")
                            .font(.system(size: 45))

                        Text("Family 1")
                            .font(.system(size: 45, weight: .bold))
                            .foregroundColor(magnetBrown)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 40))
                    }

                    // Leading Hamburger Menu
                    HStack {
                        Button(action: {
                            withAnimation {
                                isSidebarVisible.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 60, height: 30)
                                .foregroundColor(magnetBrown)
                                .padding(.leading, 20)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }

            // Dim background when sidebar is visible
            if isSidebarVisible {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isSidebarVisible = false
                        }
                    }
            }

            // Sidebar slide-in
            if isSidebarVisible {
                SideBarView()
                    .frame(maxWidth: 280, maxHeight: .infinity)
                    .transition(.move(edge: .leading))
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}


#Preview(traits: .landscapeLeft) {
    TopFamilyBar()
}
