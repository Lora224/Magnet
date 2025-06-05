//
//  RectangleButton.swift
//  Magnet
//
//  Created by Muze Lyu on 5/6/2025.
//

import SwiftUI
struct RectangleButton: View {
    let systemImage: String
    let color: Color
    let size: CGFloat

    init(systemImage: String, color: Color, size: CGFloat = 40) {
        self.systemImage = systemImage
        self.color = color
        self.size = size
    }

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size, weight: .bold))
            .foregroundColor(color)
    }
}
