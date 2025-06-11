//
//  StickyCanvasContainer.swift
//  Magnet
//
//  Created by Muze Lyu on 11/6/2025.
//
import SwiftUI

struct StickyCanvasContainer: View {
  @EnvironmentObject var stickyManager: StickyDisplayManager
  @Binding var families: [Family]
  @Binding var selectedFamilyIndex: Int
  @State private var canvasOffset = CGSize.zero
  @State private var zoomScale: CGFloat = 1

  var body: some View {
    GeometryReader { geo in
      StickyCanvasView(
        stickyManager: stickyManager,
        canvasOffset: $canvasOffset,
        zoomScale: $zoomScale,
        families: $families,
        selectedFamilyIndex: $selectedFamilyIndex
      )
      .onAppear {
        // First load
          guard families.indices.contains(selectedFamilyIndex) else {
              print("⚠️ StickyCanvasContainer.onAppear: no families yet (count=\(families.count)), skipping load.")
              return
          }

        let family = families[selectedFamilyIndex]
        stickyManager.loadStickyNotes(
          for: family.id,
          memberIDs: family.memberIDs,
          canvasSize: geo.size
        )
      }
      .onChange(of: selectedFamilyIndex) { newIndex in
          guard families.indices.contains(newIndex) else { return }
        let family = families[newIndex]
        stickyManager.loadStickyNotes(
          for: family.id,
          memberIDs: family.memberIDs,
          canvasSize: geo.size
        )
      }
    }
  }
}
