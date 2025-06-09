import SwiftUI

struct StickyCanvasView: View {
    @ObservedObject var stickyManager: StickyDisplayManager
    
    @Binding var canvasOffset: CGSize
    @Binding var zoomScale: CGFloat
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            ForEach(stickyManager.displayedNotes) { positioned in
                StickyNoteView(note: positioned.note, reactions: positioned.reactions)
                    .rotationEffect(positioned.rotationAngle)
                    .position(positioned.position)
                    .transition(.opacity)
            }
        }
        .offset(x: canvasOffset.width + dragOffset.width,
                y: canvasOffset.height + dragOffset.height)
        .scaleEffect(zoomScale)
        .drawingGroup()
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    zoomScale = min(max(value, 0.8), 2.5)
                }
        )
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    canvasOffset.width += value.translation.width
                    canvasOffset.height += value.translation.height
                }
        )
    }
}
