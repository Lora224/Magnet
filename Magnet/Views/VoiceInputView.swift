import SwiftUI
import Combine

struct VoiceInputView: View {
    @State private var secondsElapsed: Int = 0
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // 1. Full‐screen grid background
                GridPatternBackground()
                
                // 2. Top‐left “X” button, inset by 20 points
                CircleExitButton(
                    systemImage: "xmark",
                    backgroundColor: .red
                )
                .padding(.leading, 20)
                .padding(.top, 20)
                
                // 3. Center area: “Recording…” + timer
                VStack(spacing: 8) {
                    Text("Recording...")
                        .font(.system(size: 35, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.7))
                    
                    Text(formattedTime)
                        .font(.system(size: 100, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.black.opacity(0.8))
                }
                // Center horizontally and vertically
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
            }
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                secondsElapsed += 1
            }
        }
    }

    private var formattedTime: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VoiceInputView()
}
