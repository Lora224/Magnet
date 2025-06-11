//
//  ReactionBarView.swift
//  Magnet
//
//  Created by Muze Lyu on 11/6/2025.
//

import SwiftUI

// MARK: - ReactionBarView
struct ReactionBarView: View {
    @Binding var selected: ReactionType?
    var onReact: (ReactionType) -> Void

    var body: some View {
        HStack(spacing: 20) {
            ForEach(ReactionType.allCases, id: \.self) { reaction in
                Button(action: {
                    selected = reaction
                    onReact(reaction)
                }) {
                    Image(reaction.ImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(8)
                        .background(
                            Circle()
                                .stroke(selected == reaction ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
