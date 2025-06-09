import SwiftUI
import AVFoundation


struct StickyNoteView: View {
    let note: StickyNote
    let reactions: [ReactionType]

    @State private var isPresentingDetail = false
    @State private var caption: String = ""
    @State private var thumbnail: UIImage? = nil
    @State private var showVideoPreview = false
    @State private var isAudioPlaying = false
    @State private var audioPlayer: AVPlayer?

    private let magnetColors: [Color] = [.magnetPink, .magnetYellow, .magnetBlue]

    var body: some View {
        ZStack {
            noteContentView()
                .frame(width: 150, height: 150)
                .background(
                    backgroundForNote()
                        .frame(width: 150, height: 150)
                        .clipped()
                )

                .cornerRadius(16)
                .shadow(radius: 6)
                .scaleEffect(showVideoPreview ? 1.3 : 1.0)
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
                    .frame(width: 28, height: 28)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .offset(offset(for: index, total: reactions.count))
            }

            NavigationLink("", destination: NotesDetailView(note: note), isActive: $isPresentingDetail)
                .opacity(0)
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

        case .image, .video:
            if let urlStr = note.payloadURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        PolaroidPhotoView(image: UIImage.image, caption: $caption, maxWidth: 150, maxHeight: 150)
                    default:
                        ProgressView()
                    }
                }
            }

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
        case .text, .audio:
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
