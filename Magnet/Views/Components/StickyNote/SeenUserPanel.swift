import SwiftUI


struct SeenUsersPanel: View {
    var users: [UserPublic]
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 12) {
            // drag‐handle
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)

            Text("Seen by")
                .font(.headline)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(users) { user in
                        HStack(spacing: 12) {
                            AsyncImage(url: user.avatarURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let img):
                                    img
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                            Text(user.name)
                                .font(.body)

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(maxHeight: 300)

            Button("Close") {
                isPresented = false
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
