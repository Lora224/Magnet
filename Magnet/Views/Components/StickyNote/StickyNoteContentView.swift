//
//  StickyNoteContentView.swift
//  Magnet
//
//  Created by Muze Lyu on 11/6/2025.
//

// MARK: - StickyNoteContentView
import SwiftUI
import AVFoundation
import AVKit

/// Extracted content renderer from `StickyNoteView.noteContentView()`
struct StickyNoteContentView: View {
    let note: StickyNote
    @State private var audioPlayer: AVPlayer?
    @State private var showVideoPreview = false
    @State private var isAudioPlaying = false

    var body: some View {
        contentView()
    }

    @ViewBuilder
    private func contentView() -> some View {
        switch note.type {
        case .text:
            Text(note.text ?? "")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding()
                .background(backgroundForNote())
                .cornerRadius(16)
                .shadow(radius: 6)

        case .drawing:
            if let urlStr = note.payloadURL, let url = URL(string: urlStr) {
                VStack(spacing: 8) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(maxWidth: 200, maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure:
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.red)
                        default:
                            ProgressView()
                        }
                    }
                    if let text = note.text, !text.isEmpty {
                        Text(shorten(text))
                            .font(.footnote)
                            .foregroundColor(.black)
                            .lineLimit(1)
                    }
                }
                .padding()
                .background(backgroundForNote())
                .cornerRadius(16)
                .shadow(radius: 6)
            }

        case .image, .video:
            let rotationAngle = Double.random(in: -5...5)
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)

                    VStack(spacing: 0) {
                        if let url = URL(string: note.payloadURL ?? "") {
                            // Image or video thumbnail
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let img):
                                    img
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxHeight: 300)
                                        .clipped()
                                case .failure:
                                    Image(systemName: "exclamationmark.triangle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.red)
                                        .frame(maxHeight: 300)
                                default:
                                    ProgressView()
                                        .frame(maxHeight: 300)
                                }
                            }
                            .onTapGesture {
                                if note.type == .video {
                                    showVideoPreview.toggle()
                                }
                            }
                        }

                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 40)
                            .overlay(
                                Text(note.text?.isEmpty == false ? shorten(note.text!) : "")
                                    .font(.caption)
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .padding(.horizontal, 8),
                                alignment: .top
                            )
                    }
                }
                .aspectRatio(4/3, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .rotationEffect(.degrees(rotationAngle))
                .padding(4)
                .background(Color.clear)

                if showVideoPreview, note.type == .video,
                   let urlStr = note.payloadURL,
                   let url = URL(string: urlStr)
                {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 300)
                }
            }

        case .audio:
            VStack(spacing: 12) {
                Text(note.text ?? "[Voice Note]")
                    .font(.body)
                    .foregroundColor(.black)
                    .padding(8)
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
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(backgroundForNote())
            .cornerRadius(16)
            .shadow(radius: 6)
        }
    }

    private func shorten(_ text: String) -> String {
        if text.count <= 60 { return text }
        return String(text.prefix(57)) + "..."
    }

    @ViewBuilder
    private func backgroundForNote() -> some View {
        let backgrounds = ["pinkNote", "whiteNote1", "whiteNote2", "yellowNote", "blueNoteLines", "blueNotePlain"]
        let index = abs(note.id.hashValue) % backgrounds.count
        Image(backgrounds[index])
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}
