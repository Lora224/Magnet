import SwiftUI

struct FamilyCard: View {
    let family: Family
    let textColor: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(Color(
                    red: family.red,
                    green: family.green,
                    blue: family.blue))
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 4)

            Text("\(family.name)")
                .font(.headline)
                .foregroundColor(textColor)
                .padding(8)
        }
    }
}

