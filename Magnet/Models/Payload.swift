import SwiftData
import Foundation

@Model
final class Payload: Identifiable {
    var id: UUID
    var text: String?
    var url: String?

    init(
        id: UUID = .init(),
        text: String? = nil,
        url: String? = nil
    ) {
        self.id = id
        self.text = text
        self.url = url
    }
}

