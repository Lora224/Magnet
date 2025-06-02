import SwiftUI
struct CameraView: View {
    var body: some View {
        ZStack {
            Image("cameraPlaceholder")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
        VStack {
            HStack {
                Image(systemName: "arrowshape.backward.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding()
                    .foregroundColor(Color.white)
                Spacer()
            }
            Spacer()
            }
        .padding(.top, 20)
        .padding(.horizontal, 16)
            
        VStack(spacing: 80) {
            Image(systemName: "photo")
                .resizable()
                .frame(width: 50, height: 40)
                .foregroundColor(Color.white)
            Circle()
                .strokeBorder(Color.white, lineWidth: 4)
                .background(Circle().fill(Color.white.opacity(0.2)))
                .frame(width: 90, height: 90)
            Image(systemName: "arrow.trianglehead.2.clockwise")
                .resizable()
                .frame(width: 50, height: 60)
                .foregroundColor(Color.white)
        }
        .padding(16)
        .padding([.top, .bottom], 230)
        .background(Color.black.opacity(0.7))
        .cornerRadius(15)
        .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}


#Preview{
    CameraView()
}
