import SwiftUI

struct StickyCanvasView: View {
    @ObservedObject var stickyManager: StickyDisplayManager

    @Binding var canvasOffset: CGSize
    @Binding var zoomScale: CGFloat
    @GestureState private var dragDelta: CGSize = .zero

    var body: some View {
        ZStack {
            ForEach(stickyManager.viewportNotes) { note in
                StickyNoteView(note: note.note, reactions: note.reactions)
                    .rotationEffect(note.rotationAngle)
                    .position(note.position)
            }
        }
        .offset(x: canvasOffset.width + dragDelta.width,
                y: canvasOffset.height + dragDelta.height)
        .scaleEffect(zoomScale)
        .gesture(
            DragGesture()
                .updating($dragDelta) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    canvasOffset.width += value.translation.width
                    canvasOffset.height += value.translation.height
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    zoomScale = min(max(value, 0.8), 2.5)
                }
        )
    }
}

