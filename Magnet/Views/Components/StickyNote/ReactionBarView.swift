import SwiftUI

struct ReactionBarView: View {
    @Binding var selected: ReactionType?
    var onReact: (ReactionType) -> Void

    var body: some View {
        HStack(spacing: 24) {
            ForEach(ReactionType.allCases, id: \.self) { reaction in
                Button {
                    selected = reaction
                    onReact(reaction)
                } label: {
                    Image(reaction.ImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(
                                    selected == reaction
                                        ? Color.accentColor.opacity(0.3)
                                        : Color.clear
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.15))
        )
    }
}
