//
//  StickyNoteView.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

//could be divded further
import SwiftUI

/// A reusable “sticky note” component that draws a sticky‐paper background (with a little “tape” at the top)
/// and overlays any content (text, image, icon, etc.) inside.
///
/// Usage examples:
/// ```swift
/// // 1) A simple text note:
/// StickyNoteView(backgroundColor: Color(red: 209/255, green: 233/255, blue: 246/255)) {
///     Text("We went out for lunch today.\nWe really wished you were here as well.")
///         .font(.body)
///         .foregroundColor(.black)
///         .multilineTextAlignment(.leading)
/// }
///
/// // 2) A photo note:
/// StickyNoteView(backgroundColor: Color(red: 241/255, green: 211/255, blue: 206/255)) {
///     Image("familySnapshot")
///         .resizable()
///         .scaledToFill()
///         .clipped()
/// }
///
/// // 3) A handwritten‐style message with a play icon:
/// StickyNoteView(backgroundColor: Color(red: 255/255, green: 245/255, blue: 218/255)) {
///     VStack(spacing: 8) {
///         HStack {
///             Image(systemName: "play.circle.fill")
///                 .resizable()
///                 .frame(width: 28, height: 28)
///                 .foregroundColor(Color(red: 75/255, green: 54/255, blue: 33/255))
///             Text("Hey Ma! I just finished my class.\nReally miss you. I love you!")
///                 .font(.body)
///                 .foregroundColor(.black)
///         }
///     }
/// }
/// ```
struct StickyNoteView<Content: View>: View {
    /// The color of the sticky paper itself (e.g. pastel pink, yellow, blue).
    let backgroundColor: Color
    
    /// The actual content to show inside the sticky note. Could be text, an image, an icon, etc.
    let content: () -> Content
    
    /// Optional width/height of the paper. If nil, a default square of 120×120 is used.
    var size: CGSize = CGSize(width: 120, height: 120)
    
    /// Height of the “tape” strip at the top:
    private let tapeHeight: CGFloat = 16
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1) The sticky‐paper rectangle
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(backgroundColor)
                .frame(width: size.width, height: size.height)
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 4)
            
            // 2) The “tape” at the top center
            Rectangle()
                .fill(Color.white.opacity(0.8))
                .frame(width: size.width * 0.5, height: tapeHeight)
                .cornerRadius(4)
                .rotationEffect(.degrees(-5))
                .offset(y: -tapeHeight/2)
            
            // 3) The user‐provided content, inset from each edge
            content()
                .padding(8)
                .frame(width: size.width, height: size.height)
        }
        // Extend the full height to accommodate the taped area if needed
        .frame(width: size.width, height: size.height + tapeHeight/2)
    }
}


struct VoiceNoteSticky: View {
    // MARK: – Colors (adjust to taste)
    private let magnetBlue = Color(red: 209.0/255.0, green: 233.0/255.0, blue: 246.0/255.0) // #D1E9F6
    private let magnetBrown = Color(red: 75.0/255.0,  green: 54.0/255.0,  blue: 33.0/255.0)  // #4B3621
    
    // Simulated playback progress (0…1)
    @State private var playbackProgress: Double = 0.0
    // Whether the audio is “playing”
    @State private var isPlaying = false
    
    var body: some View {
        StickyNoteView(backgroundColor: magnetBlue, size: CGSize(width: 140, height: 140)) {
            VStack(alignment: .leading, spacing: 8) {
                // 1) Transcribed text at the top
                Text("Hey Ma! I just\nfinished my class.\nReally miss you. I\nlove you!")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.black)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // 2) Play button + progress bar at the bottom
                HStack(spacing: 8) {
                    // Play / Pause button
                    Button(action: {
                        isPlaying.toggle()
                        // In a real app, you’d start/stop audio playback here.
                        // For the demo, we’ll just animate the progress bar:
                        if isPlaying {
                            withAnimation(.linear(duration: 5.0)) {
                                playbackProgress = 1.0
                            }
                        } else {
                            withAnimation {
                                playbackProgress = 0.0
                            }
                        }
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(magnetBrown)
                    }
                    
                    // Progress bar (custom styled)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            // 1) Track
                            Capsule()
                                .fill(Color.white.opacity(0.6))
                                .frame(height: 4)
                            
                            // 2) Filled portion (brown)
                            Capsule()
                                .fill(magnetBrown)
                                .frame(width: geo.size.width * CGFloat(playbackProgress), height: 4)
                        }
                    }
                    .frame(height: 20) // only the progress bar’s height matters here
                }
                .padding(.bottom, 8)
            }
            .padding(8)
        }
    }
}




// MARK: – Example Preview
struct StickyNoteView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            // Example 1: Plain text on a pastel‐blue sticky
            VoiceNoteSticky()
                .padding()
                .previewLayout(.sizeThatFits)
            
            // Example 2: Photo inside a pastel‐pink sticky
            StickyNoteView(backgroundColor: Color(red: 241/255, green: 211/255, blue: 206/255)) {
                Image("avatarPlaceholder")
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
            
            // Example 3: A mini music message on a pastel‐yellow sticky
            StickyNoteView(backgroundColor: Color(red: 255/255, green: 245/255, blue: 218/255)) {
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Text("Hey Ma! I just finished my class.\nReally miss you. I love you!")
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
