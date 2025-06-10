import SwiftUI

struct CircleExitButton: View {
    let systemImage: String
    let backgroundColor: Color
    let size: CGFloat

    init(systemImage: String, backgroundColor: Color, size: CGFloat = 80) {
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)

            Image(systemName: systemImage)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ZStack(alignment: .topLeading) {
        // Make the ZStack fill the entire preview area
        Color.clear
        CircleExitButton(
            systemImage: "xmark",
            backgroundColor: .red
        )
        .padding(20) // move it in from the very corner if desired
    }
    .ignoresSafeArea()
}
