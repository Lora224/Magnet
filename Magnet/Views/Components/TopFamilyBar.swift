import SwiftUI

struct TopFamilyBar: View {
    @Binding var families: [Family]
    @Binding var selectedIndex: Int
    @State private var isSidebarVisible = false

    // Dynamic background based on selected family's RGB color
    private var backgroundColor: Color {
        guard families.indices.contains(selectedIndex) else {
            // fallback color
            return Color(red: 1.000, green: 0.961, blue: 0.855)
        }
        let f = families[selectedIndex]
        return Color(red: f.red, green: f.green, blue: f.blue)
    }

    private let magnetBrown = Color(red: 0.294, green: 0.212, blue: 0.129)

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ZStack {
                    // Use dynamic family color
                    Rectangle()
                        .fill(backgroundColor)
                        .frame(height: 90)
                        .shadow(color: .gray.opacity(0.1), radius: 10, x: 0, y: 4)

                    // Original layout preserved
                    HStack(spacing: 24) {
                        // Sidebar toggle
                        Button {
                            withAnimation { isSidebarVisible.toggle() }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 60, height: 30)
                                .foregroundColor(magnetBrown)
                                .padding(.leading, 20)
                        }

                        Spacer()

                        // Previous family button
                        Button {
                            if selectedIndex > 0 { selectedIndex -= 1 }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 40))
                                .foregroundColor(magnetBrown)
                        }

                        // Family picker menu
                        Menu {
                            ForEach(families) { family in
                                Button(family.name) {
                                    if let idx = families.firstIndex(where: { $0.id == family.id }) {
                                        selectedIndex = idx
                                    }
                                }
                            }
                        } label: {
                            Text(families.indices.contains(selectedIndex)
                                 ? families[selectedIndex].name
                                 : "–")
                                .font(.system(size: 45, weight: .bold))
                                .foregroundColor(magnetBrown)
                        }

                        // Next family button
                        Button {
                            if selectedIndex < families.count - 1 { selectedIndex += 1 }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 40))
                                .foregroundColor(magnetBrown)
                        }

                        Spacer()
                    }
                    .frame(height: 90)
                }
            }

            // Sidebar overlay
            if isSidebarVisible {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture { withAnimation { isSidebarVisible = false } }

                SideBarView()
                    .frame(maxWidth: 280, maxHeight: .infinity)
                    .transition(.move(edge: .leading))
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Preview
#if DEBUG
struct TopFamilyBar_Previews: PreviewProvider {
    static let sample = [
        Family(id: "1", name: "A", inviteURL: "", memberIDs: [], red: 0.8, green: 0.4, blue: 0.2, profilePic: nil),
        Family(id: "2", name: "B", inviteURL: "", memberIDs: [], red: 0.2, green: 0.6, blue: 0.8, profilePic: nil)
    ]
    static var previews: some View {
        TopFamilyBar(families: .constant(sample), selectedIndex: .constant(0))
            .previewLayout(.sizeThatFits)
    }
}
#endif
