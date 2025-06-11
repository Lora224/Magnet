import SwiftUI
import Combine
import FirebaseAuth
import AVFoundation
import Speech

struct VoiceInputView: View {
    var familyID: String
    var userID: String

    @Environment(\.dismiss) private var dismiss

    @State private var secondsElapsed: Int = 0
    @State private var isRecording: Bool = false
    @State private var isPulsing: Bool = false
    @State private var hasRecording: Bool = false
    
    @State private var transcriptText: String = "Live transcription will appear here..."
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @State private var audioURL: URL? = nil

    @State private var recordingDuration: Int = 0
    @State private var playbackPosition: Double = 0
    @State private var isPlaying: Bool = false
    
    @StateObject private var playerManager = VoicePlayerManager()
    private var recorderManager = VoiceRecorderManager()
    
    init(familyID: String, userID: String) {
        self.familyID = familyID
        self.userID = userID
    }

    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                GridPatternBackground().ignoresSafeArea()

                Button(action: { dismiss() }) {
                    CircleExitButton(systemImage: "xmark", backgroundColor: .red)
                }.padding(.leading, 20).padding(.top, 20)

                VStack(spacing: 30) {
                    
                    ScrollView {
                        Text(transcriptText)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                            .padding()
                    }
                    .frame(maxHeight: 150)
                    .animation(.easeInOut, value: transcriptText)

                    Text(isRecording ? "Recording…" : (hasRecording ? "Recorded" : "Paused"))
                        .font(.title2)

                    Text(formattedTime)
                        .font(.system(size: 60, design: .monospaced))

                    if hasRecording {
                        HStack(spacing: 40) {
                            Button(action: togglePlayback) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 40))
                            }
                            Button(action: resetRecording) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 40))
                            }
                            Button(action: confirmRecording) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 40))
                            }
                        }
                    } else {
                        Button(action: toggleRecording) {
                            Circle()
                                .fill(isRecording ? Color.gray : Color.magnetBrown)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 8)
                                .scaleEffect(isRecording && isPulsing ? 1.2 : 1.0)
                                .animation(
                                    isRecording ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                                    value: isPulsing
                                )
                                .overlay(
                                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onReceive(timer) { _ in
                    if isRecording { secondsElapsed += 1 }
                    if isPlaying {
                        playbackPosition += 1
                        if Int(playbackPosition) >= recordingDuration {
                            playbackPosition = Double(recordingDuration)
                            isPlaying = false
                        }
                    }
                }
                .onChange(of: playerManager.isPlaying) { newValue in
                    isPlaying = newValue
                }
            }
        }
        .onAppear {
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized: print("✅ Speech recognition authorized")
                case .denied: print("❌ Speech recognition denied")
                case .restricted: print("⚠️ Speech recognition restricted")
                case .notDetermined: print("❓ Speech recognition not determined")
                @unknown default: break
                }
            }
        }
    }

    private var formattedTime: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func toggleRecording() {
        if isRecording {
            stopTranscription()
            recorderManager.stopRecording { url in
                self.audioURL = url
                self.hasRecording = url != nil
                self.recordingDuration = self.secondsElapsed
                self.playbackPosition = 0
                self.isRecording = false
                self.isPulsing = false
            }
        } else {
            startTranscription()
            secondsElapsed = 0
            isRecording = true
            isPulsing = true
            recorderManager.startRecording()
        }
    }
    
    private func startTranscription() {
        transcriptText = ""
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            print("❌ Failed to create request")
            return
        }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                transcriptText = result.bestTranscription.formattedString
            }
            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    private func stopTranscription() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        transcriptText += "\n\nFinalized."
    }

    private func togglePlayback() {
        guard let url = audioURL else { return }
        if isPlaying {
            playerManager.pause()
        } else {
            playerManager.play(url: url)
        }
    }

    private func resetRecording() {
        recorderManager.deleteRecording()
        audioURL = nil
        hasRecording = false
        secondsElapsed = 0
    }

    private func confirmRecording() {
        guard let audioURL = audioURL else { return }
        StickyNoteService.saveVoiceNote(
            audioURL: audioURL,
            senderID: userID,
            familyID: familyID,
            transcription: transcriptText
        ) { error in
            if let error = error {
                print("❌ Failed to upload voice note: \(error.localizedDescription)")
            } else {
                print("✅ Voice note saved")
                dismiss()
            }
        }
    }
}
