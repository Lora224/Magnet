//
//  test.swift
//  Magnet
//
//  Created by Yutong Li on 3/6/2025.
//


import SwiftUI
import FirebaseFirestore

struct FirestoreNameView: View {
    @State private var testname: String = "..."

    var body: some View {
        Text(testname)
            .font(.title)
            .onAppear {
                Firestore.firestore().collection("test1").getDocuments { snapshot, error in
                    if let doc = snapshot?.documents.first,
                       let value = doc["testname"] as? String {
                        testname = value
                    }
                }
            }
    }
}

#Preview {
    FirestoreNameView()
}
