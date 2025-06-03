import Foundation
import SwiftData

@Model
class Counter {
    var value: Int
    
    init(value: Int = 0) {
        self.value = value
    }
}
