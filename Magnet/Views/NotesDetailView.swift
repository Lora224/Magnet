//
//  NotesDetailView.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

//For checking notes details from the main view
import SwiftUI

struct NotesDetailView: View {
    
    // Hex-based colors as properties
    private let magnetBrown   = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    private let magnetPink    = Color(red: 0.945, green: 0.827, blue: 0.808) // #F1D3CE
    private let magnetYellow  = Color(red: 1.000, green: 0.961, blue: 0.855) // #FFF5DA
    private let magnetBlue    = Color(red: 0.820, green: 0.914, blue: 0.965) // #D1E9F6

    

    var body: some View {
        VStack (spacing : 0){
            
            ZStack {
                Rectangle()
                    .fill(magnetYellow)
                    .frame(height: 100)
                ZStack {
                    Image("tribar")
                        .frame(maxWidth: .infinity, alignment: .leading)
  
                }.padding(.leading, 25)
            }

            
            HStack (spacing : 0){
                Rectangle()
                    .fill(Color.white)
                    .frame(maxHeight: 30)


                Rectangle()
                    .fill(Color.white)
                    .frame(maxHeight: 30)

            }
            Image("blueNotePlain")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame( maxWidth: 450)
                
            
            Spacer()
        }
        .ignoresSafeArea(.all, edges: .top)
        
    }
}

#Preview(traits: .landscapeLeft) {
    NotesDetailView()
}


