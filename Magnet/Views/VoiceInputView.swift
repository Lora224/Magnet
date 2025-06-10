import SwiftUI
import Combine

struct VoiceInputView: View {
    
    @Environment(\.dismiss) private var dismiss   

    @State private var secondsElapsed: Int = 0
    @State private var isRecording: Bool = false
    @State private var isPulsing: Bool = false
    @State private var hasRecording: Bool = false
    

    // Playback state
    @State private var recordingDuration: Int = 0
    @State private var playbackPosition: Double = 0
    @State private var isPlaying: Bool = false

    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                GridPatternBackground()
                    .ignoresSafeArea()

                Button(action: {
                    dismiss()
                }) {
                    CircleExitButton(
                        systemImage: "xmark",
                        backgroundColor: .red
                    )
                }
                .padding(.leading, 20)
                .padding(.top, 20)

                ZStack {
                    Text(isRecording ? "Recording…" : (hasRecording ? "Recorded" : "Paused"))
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.7))

                    Text(formattedTime)
                        .font(.system(size: 120, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.black.opacity(0.8))

                    if hasRecording {
                        VStack(spacing: 4) {
                            Slider(
                                value: $playbackPosition,
                                in: 0...Double(recordingDuration),
                                step: 1
                            )
                            .frame(width: geometry.size.width * 0.6)
                            .disabled(isPlaying) // disable slider drag during playback

                            Text(formattedPlaybackTime)
                                .font(.system(size: 20, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 3.5
                )

                // Big record/stop button
                if !hasRecording {
                    Button(action: toggleRecording) {
                        Circle()
                            .fill(isRecording ? Color.gray : Color.magnetBrown)
                            .frame(width: 200, height: 200)
                            .shadow(radius: 8)
                            .scaleEffect(isRecording && isPulsing ? 1.2 : 1.0)
                            .animation(
                                isRecording && isPulsing
                                    ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                                    : .default,
                                value: isPulsing
                            )
                            .overlay(
                                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 100))
                                    .foregroundColor(.white)
                            )
                    }
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.8
                    )
                }

                // Play / Replay / Confirm buttons
                if !isRecording && hasRecording {
                    HStack(spacing: 100) {
                        // Play/pause toggle
                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.blue)
                        }

                        // Replay (reset)
                        Button(action: resetRecording) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 100))
                                .foregroundColor(.orange)
                        }

                        // Confirm
                        Button(action: confirmRecording) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 100))
                                .foregroundColor(.green)
                        }
                    }
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.8
                    )
                }
            }
            .onReceive(timer) { _ in
                if isRecording {
                    secondsElapsed += 1
                } else if isPlaying {
                    // Advance playback position
                    playbackPosition += 1
                    if Int(playbackPosition) >= recordingDuration {
                        playbackPosition = Double(recordingDuration)
                        isPlaying = false
                    }
                }
            }
        }
    }

    private var formattedTime: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var formattedPlaybackTime: String {
        let pos = Int(playbackPosition)
        let minutes = pos / 60
        let seconds = pos % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Simulated Recording Logic

    private func toggleRecording() {
        if isRecording {
            // Stop recording
            isRecording = false
            isPulsing = false
            hasRecording = true
            recordingDuration = secondsElapsed
            playbackPosition = 0
        } else {
            // Start recording
            isRecording = true
            isPulsing = true
            if hasRecording {
                secondsElapsed = 0
                hasRecording = false
            }
        }
    }

    private func resetRecording() {
        hasRecording = false
        secondsElapsed = 0
        isPlaying = false
        playbackPosition = 0
        recordingDuration = 0
    }

    // Toggle play/pause, start from slider position
    private func togglePlayback() {
        if isPlaying {
            isPlaying = false
        } else {
            if Int(playbackPosition) >= recordingDuration {
                playbackPosition = 0
            }
            isPlaying = true
        }
    }

    private func confirmRecording() {
        print("✅ Confirmed recording of length \(formattedTime)")
    }
}

#Preview {
    VoiceInputView()
}
