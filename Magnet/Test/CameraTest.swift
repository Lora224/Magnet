//
//  CameraTest.swift
//  Magnet
//
//  Created by Muze Lyu on 5/6/2025.
//

import SwiftUI
import UIKit
import AVFoundation


/// A SwiftUI “wrapper” that presents your existing CameraTestViewController.
struct CameraTestView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraTestViewController {
        return CameraTestViewController()
    }
    func updateUIViewController(_ uiViewController: CameraTestViewController, context: Context) {
        // No dynamic updates needed for now.
    }
}


