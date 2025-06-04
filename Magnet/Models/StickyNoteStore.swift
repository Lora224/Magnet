//
//  StickyNoteStore.swift
//  Magnet
//
//  Created by Siddharth Wani on 4/6/2025.
//


//import Foundation
//import Combine
//
//class StickyNoteStore: ObservableObject {
//    @Published var notes: [StickyNote] = [
//        StickyNote(
//            sender: "Alice",
//            mediaType: .text,
//            text: "Happy Birthday, Grandma!",
//            imageURL: nil,
//            voiceURL: nil,
//            videoURL: nil,
//            noteType: .birthday,
//            date: Date()
//        ),
//        StickyNote(
//            sender: "Bob",
//            mediaType: .image,
//            text: nil,
//            imageURL: "file:///Users/yourname/Documents/Magnet/photos/kyoto_trip.jpg",
//            voiceURL: nil,
//            videoURL: nil,
//            noteType: .travel,
//            date: Date().addingTimeInterval(-86400 * 15)
//        ),
//        StickyNote(
//            sender: "Carol",
//            mediaType: .voice,
//            text: nil,
//            imageURL: nil,
//            voiceURL: "file:///Users/yourname/Documents/Magnet/voice/doctor_reminder.m4a",
//            videoURL: nil,
//            noteType: .reminder,
//            date: Date().addingTimeInterval(-86400 * 30)
//        ),
//        StickyNote(
//            sender: "David",
//            mediaType: .video,
//            text: nil,
//            imageURL: nil,
//            voiceURL: nil,
//            videoURL: "file:///Users/yourname/Documents/Magnet/videos/family_event.mov",
//            noteType: .event,
//            date: Date().addingTimeInterval(-86400 * 60)
//        ),
//        StickyNote(
//            sender: "Eve",
//            mediaType: .text,
//            text: "Meeting at 3PM – don't forget!",
//            imageURL: nil,
//            voiceURL: nil,
//            videoURL: nil,
//            noteType: .custom,
//            date: Date().addingTimeInterval(-86400 * 5)
//        )
//    ]
//}
