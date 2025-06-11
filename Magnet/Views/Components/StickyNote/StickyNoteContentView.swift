import SwiftUI
import AVFoundation
import AVKit

/// Controls whether the note renders as a small thumbnail (in the main canvas) or full-screen detail.
enum StickyNoteContentMode {
    case thumbnail
    case detail
}

/// Renders a sticky note’s content (text, drawing, image/video, or audio) in either thumbnail or detail mode.
struct StickyNoteContentView: View {
    let note: StickyNote
    var mode: StickyNoteContentMode = .thumbnail

    @State private var audioPlayer: AVPlayer?
    @State private var showVideoPreview = false
    @State private var isAudioPlaying = false

    var body: some View {
        switch mode {
        case .thumbnail:
            ZStack {
                contentView()
            }
            .frame(width: 220, height: 220)
            .background(
                backgroundImage()
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 220)
                    .shadow(color: .black.opacity(0.15), radius: 6)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(Rectangle())

        case .detail:
            ZStack {
                // Background restricted by vertical padding (between top bar & reaction bar)
                backgroundImage()
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black.opacity(0.15), radius: 8)

                // Text/drawing/video/audio directly on note background
                contentView()
                    .padding(24)
            }
            .padding(.vertical, 40)  // adjust to sit between top family bar & reaction bar
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// Core content, agnostic of size mode, with no extra borders/shadows.
    @ViewBuilder
    private func contentView() -> some View {
        switch note.type {
        case .text:
            Text(note.text ?? "")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

        case .drawing:
            if let urlStr = note.payloadURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.red)
                    default:
                        ProgressView()
                    }
                }
            }

        case .image, .video:
            let rotationAngle = Double.random(in: -5...5)
            
            VStack(spacing: 0) {
                ZStack {
                    // Background: whole Polaroid
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)

                    VStack(spacing: 0) {
                        // Image with top & side margins
                        if let url = URL(string: note.payloadURL ?? "") {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let img):
                                    img
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                case .failure:
                                    Image(systemName: "exclamationmark.triangle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.red)
                                        .frame(height: 170)
                                default:
                                    ProgressView()
                                        .frame(height: 120)
                                }
                            }
                            .padding(.top, 6)
                            .padding(.horizontal, 6)
                        }

                        // Caption space — thick bottom border
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 30)
                            .overlay(
                                Text(note.text?.isEmpty == false ? note.text! : "")
                                    .font(.caption2)
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .padding(.horizontal, 4),
                                alignment: .top
                            )
                    }
                }
                .aspectRatio(4/3, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(2)


        case .audio:
            VStack(spacing: 12) {
                Text(note.text ?? "[Voice Note]")
                    .font(.body)
                    .foregroundColor(.black)
                    .padding(8)  // padding only, no border
                Button {
                    if let urlStr = note.payloadURL,
                       let url = URL(string: urlStr) {
                        audioPlayer = AVPlayer(url: url)
                        audioPlayer?.play()
                        isAudioPlaying = true
                    }
                } label: {
                    Image(systemName: isAudioPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
            }
            .padding()
        }
    }

    /// Returns the raw Image for the note’s background.
    private func backgroundImage() -> Image {
        let backgrounds = ["pinkNote", "whiteNote1", "whiteNote2", "yellowNote", "blueNoteLines", "blueNotePlain"]
        let index = abs(note.id.hashValue) % backgrounds.count
        return Image(backgrounds[index])
    }
}
