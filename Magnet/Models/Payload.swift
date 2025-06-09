import SwiftData
import Foundation
/*for image/video type, text is the caption*/
/*for voice type, text is the voice to text content*/
/*for text type, text is the content*/
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

