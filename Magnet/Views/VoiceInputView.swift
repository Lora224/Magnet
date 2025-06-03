//
//  VoiceInputView.swift
//  Magnet
//

import SwiftUI
import Combine

struct VoiceInputView: View {
    // 1. Track elapsed seconds
    @State private var secondsElapsed: Int = 0
    
    // 2. Create a Timer publisher that fires every 1 second
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen grid background
                GridPatternBackground()
                
                VStack {
                    // Top-left “x” button
                    HStack {
                        CircleActionButton(
                            systemImage: "xmark",
                            backgroundColor: Color.red
                        )
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Center area: “Recording…” + timer
                    VStack(spacing: 8) {
                        Text("Recording...")
                            .font(.system(size: 35, weight: .semibold))
                            .foregroundColor(.black.opacity(0.7))
                        
                        // Format secondsElapsed into “MM:SS”
                        Text(formattedTime)
                            .font(.system(size: 100, weight: .medium, design: .monospaced))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    // Center exactly
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
                    
                    Spacer()
                }
            }
            .ignoresSafeArea()
            // 3. Subscribe to the timer; increment each second
            .onReceive(timer) { _ in
                secondsElapsed += 1
            }
        }
    }
    
    // Computed property to convert secondsElapsed → “MM:SS”
    private var formattedTime: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: – CircleActionButton

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

// MARK: – GridPatternBackground

struct GridBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.93, blue: 0.87)
            
            Canvas { context, size in
                let gridSpacing: CGFloat = 48
                
                context.stroke(
                    Path { path in
                        for x in stride(from: 0, through: size.width, by: gridSpacing) {
                            path.move(to: .init(x: x, y: 0))
                            path.addLine(to: .init(x: x, y: size.height))
                        }
                        for y in stride(from: 0, through: size.height, by: gridSpacing) {
                            path.move(to: .init(x: 0, y: y))
                            path.addLine(to: .init(x: size.width, y: y))
                        }
                    },
                    with: .color(Color.black.opacity(0.2)),
                    lineWidth: 0.5
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    VoiceInputView()
}
