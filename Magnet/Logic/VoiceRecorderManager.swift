import Foundation
import AVFoundation

class VoiceRecorderManager: NSObject, AVAudioRecorderDelegate {
    private var recorder: AVAudioRecorder?
    private(set) var audioFilename: URL?

    func startRecording() {
        let filename = UUID().uuidString + ".m4a"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            recorder = try AVAudioRecorder(url: path, settings: settings)
            recorder?.delegate = self
            recorder?.record()

            audioFilename = path
        } catch {
            print("❌ Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        recorder?.stop()
        recorder = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("⚠️ Failed to deactivate session: \(error.localizedDescription)")
        }

        completion(audioFilename)
    }

    func deleteRecording() {
        if let url = audioFilename {
            try? FileManager.default.removeItem(at: url)
            audioFilename = nil
        }
    }
}

