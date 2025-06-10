import SwiftUI

struct CircleExitButton: View {
    let size: CGFloat
    let action: () -> Void

    private let systemImage = "xmark"
    private let backgroundColor = Color.red

    init(size: CGFloat = 80, action: @escaping () -> Void) {
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
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
}

#Preview(traits: .landscapeLeft) {
    ZStack(alignment: .topLeading) {
        Color.clear
        CircleExitButton {
            print("Exit button tapped (Preview)")
        }
        .padding(.leading, 16)
    }
}
