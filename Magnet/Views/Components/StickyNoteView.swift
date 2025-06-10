import SwiftUI
import AVFoundation
import UIKit
import FirebaseAuth
import Firebase

struct StickyNoteView: View {
    let note: StickyNote
    let reactions: [ReactionType]

    @State private var isPresentingDetail = false
    @State private var caption: String = ""
    @State private var thumbnail: UIImage? = nil
    @State private var showVideoPreview = false
    @State private var isAudioPlaying = false
    @State private var audioPlayer: AVPlayer?
    private var isUnseenByMe: Bool {
        guard
            let me = Auth.auth().currentUser?.uid,
            let seenDict = note.seen as? [String: Bool]
        else { return true }          // treat as unseen if anything’s missing
        return !(seenDict[me] ?? false)
    }
    private let magnetColors: [Color] = [.magnetPink, .magnetYellow, .magnetBlue]

    func shorten(_ text: String) -> String {
        if text.count <= 60 {
            return text
        } else {
            return String(text.prefix(57)) + "..."
        }
    }

    var body: some View {
        ZStack {
            noteContentView()
                .frame(width: 170, height: 170)
                .background(
                    backgroundForNote()
                        .frame(width: 170, height: 170)
                )
                .cornerRadius(16)
                .shadow(radius: 6)
                .scaleEffect(showVideoPreview ? 1.3 : 1.0)
                .animation(nil, value: showVideoPreview)
                .onTapGesture {
                    isPresentingDetail = true
                }
                .onLongPressGesture {
                    if note.type == .video {
                        showVideoPreview.toggle()
                        if let urlStr = note.payloadURL, let url = URL(string: urlStr) {
                            audioPlayer = AVPlayer(url: url)
                            audioPlayer?.play()
                        }
                    }
                }

            ForEach(Array(reactions.enumerated()), id: \.offset) { index, reaction in
                reactionIcon(for: reaction)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .offset(offset(for: index, total: reactions.count))
            }
            if isUnseenByMe {
                Image("exclamation")                 // name in Assets
                    .resizable()
                    .frame(width: 40, height: 40)
                    // place it right after the last reaction, same circular layout
                    .offset(offset(for: reactions.count,
                                   total: reactions.count + 1))
            }
            

        }
        .onTapGesture {
            isPresentingDetail = true
            markSeen()
        }
       // ⬇️  Put the destination on the SAME view that flips the Boolean
        .navigationDestination(isPresented: $isPresentingDetail) {
           NotesDetailView(note: note)
       }
    

}
    private func markSeen() {
        guard
            let me = Auth.auth().currentUser?.uid
        else { return }

        Firestore.firestore()
            .collection("StickyNotes")
            .document(note.id.uuidString)       // ← convert UUID → String
            .setData(["seen.\(me)" : true],     // nested field “seen.<uid>” = true
                     merge: true)
    }

    @ViewBuilder
    func noteContentView() -> some View {
        switch note.type {
        case .text:
            Text(note.text ?? "")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding()

        case .drawing:
            if let urlStr = note.payloadURL, let url = URL(string: urlStr) {
                VStack(spacing: 4) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure(_):
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.red)
                        default:
                            SwiftUISpinner()
                        }
                    }

                    if let text = note.text, !text.isEmpty {
                        Text(shorten(text))
                            .font(.footnote)
                            .foregroundColor(.black)
                            .lineLimit(1)
                    }
                }
            }

        case .image, .video:
            VStack(spacing: 8) {
                if let urlStr = note.payloadURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 220, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure(_):
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
                            .font(.caption)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                    }
                    
                    
                }
            }
            .padding(12)                       // inner padding
            .padding(.bottom, 20)              // extra bottom for caption area
            .background(Color.white)           // white polaroid
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.2),
                    radius: 4, x: 0, y: 2)
            .rotationEffect(.degrees(Double.random(in: -5...5)))
            .padding(4)                        // space between note and magnet
            .frame(width: 400, height: 300)

        case .audio:
            VStack {
                Text(note.text ?? "[Voice Preview]")
                    .font(.body)
                    .foregroundColor(.black)
                    .padding(4)
                Button {
                    if let urlStr = note.payloadURL, let url = URL(string: urlStr) {
                        audioPlayer = AVPlayer(url: url)
                        audioPlayer?.play()
                        isAudioPlaying = true
                    }
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.black)
                }
            }
        }
    }

    func backgroundForNote() -> some View {
        let backgrounds = ["pinkNote", "whiteNote1", "whiteNote2", "yellowNote", "blueNoteLines", "blueNotePlain"]
        let index = abs(note.id.hashValue) % backgrounds.count

        switch note.type {
        case .text, .audio, .drawing:
            return AnyView(
                Image(backgrounds[index])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
        case .image, .video:
            return AnyView(Color.clear)
        }
    }

    func reactionIcon(for type: ReactionType) -> Image {
        switch type {
        case .smile: return Image("laughMagnet")
        case .liked: return Image("heartMagnet")
        case .clap: return Image("clapMagnet")
        }
    }

    func offset(for index: Int, total: Int) -> CGSize {
        let angle = Double(index) / Double(total) * 2 * .pi
        let radius: CGFloat = 80
        return CGSize(
            width: CGFloat(cos(angle)) * radius,
            height: CGFloat(sin(angle)) * radius
        )
    }
}

