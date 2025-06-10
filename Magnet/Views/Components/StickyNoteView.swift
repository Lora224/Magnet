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
        guard let me = Auth.auth().currentUser?.uid else { return false }
       // 1️⃣ if *I* sent it, never show “!”
       if note.senderID == me { return false }

       // 2️⃣ pull the ReactionType? map (empty if missing)
       let seenDict = note.seen as? [String:ReactionType?] ?? [:]
       // 3️⃣ if my UID is a key, it’s seen
       return !seenDict.keys.contains(me)
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
                .frame(width: 220, height: 220)
                .background(
                    backgroundForNote()
                        .frame(width: 220, height: 220)
                )
                .cornerRadius(16)
                .shadow(radius: 6)
                .scaleEffect(showVideoPreview ? 1.3 : 1.0)
                .animation(nil, value: showVideoPreview)
                 .contentShape(Rectangle())
                .onTapGesture {
                        markSeen()
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

       // ⬇️  Put the destination on the SAME view that flips the Boolean
        .navigationDestination(isPresented: $isPresentingDetail) {
           NotesDetailView(note: note)
       }
    

}
    private func markSeen() {
        guard let me = Auth.auth().currentUser?.uid else { return }
        let seenKey = "seen.\(me)"

        Firestore.firestore()
          .collection("StickyNotes")
          .document(note.id.uuidString)
          .updateData([
            // NSNull() tells Firestore “this map key’s value is null”
            seenKey: NSNull()
          ]) { error in
            if let error = error {
              print("❌ markSeen failed:", error)
            } else {
              print("✅ marked \(me) in seen map")
            }
          }
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
                                        .frame(height: 120)
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
                                Text(note.text?.isEmpty == false ? shorten(note.text!) : "")
                                    .font(.caption2)
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .padding(.horizontal, 4),
                                alignment: .top
                            )
                    }
                }
                .aspectRatio(4/3, contentMode: .fit)
               .frame(maxWidth: 200)   // <-- fit the 4:3 Polaroid inside your 170px tile
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .rotationEffect(.degrees(rotationAngle))
            }
            .padding(2)


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

