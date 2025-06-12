import SwiftUI
import SDWebImageSwiftUI

struct ProfileAvatarView: View {
    let avatarURL: URL?
    let editAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.white)
                .frame(width: 150, height: 150)
                .overlay(
                    ZStack {
                        if let avatarURL = avatarURL {
                            WebImage(url: avatarURL)
                                .resizable()
                                .scaledToFill()
                                .transition(.fade(duration: 0.5))
                        } else {
                            Image("avatarPlaceholder")
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .clipShape(Circle())
                    .padding(4)
                )

                .shadow(radius: 6)

            Button(action: editAction) {
                Circle()
                    .fill(Color.magnetBrown)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    )
                    .offset(x: 8, y: 8)
            }
        }
    }
}
