//
//  CalendarView.swift
//  Magnet
//
//  Created by Muze Lyu on 30/5/2025.
//

//
import SwiftUI

struct CalendarView: View {
    private let magnetBrown   = Color(red: 0.294, green: 0.212, blue: 0.129) // #4B3621
    private let magnetPink    = Color(red: 0.945, green: 0.827, blue: 0.808) // #F1D3CE
    private let magnetYellow  = Color(red: 1.000, green: 0.961, blue: 0.855) // #FFF5DA
    private let magnetBlue    = Color(red: 0.820, green: 0.914, blue: 0.965) // #D1E9F6

    var body: some View {
        VStack {
            HStack {
                
                
                // Wrap the text and rectangle together
                ZStack {
                    Rectangle()
                        .fill(magnetYellow)
                        .frame(height: 100)
                    HStack {
                        Image(systemName: "line.horizontal.3")
                            .frame(alignment: .topLeading)
                            
                        
                        Image(systemName: "chevron.left")
                        
                        
                        Text("🎉")
                            .font(.system(size: 40))

                        
                        
                        
                        Text("Family 1")
                            .font(.headline)
                            .foregroundColor(magnetBrown)
                            .textCase(.uppercase)
                        
                        Image(systemName: "chevron.right")
                    }
                    
                }

                
                .frame(maxHeight: .infinity, alignment: .top) // this line helps when inside a parent with defined height

            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}



#Preview(traits: .landscapeLeft) {
    CalendarView()
}
