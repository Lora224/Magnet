import UIKit

extension UIImage {
    /// Returns a new UIImage that ignores any orientation metadata,
    /// rendering the raw pixel data “as‐is” (orientation .up).
    /// In other words, if the original image had an orientation tag,
    /// this strips it out without applying any rotation transforms.
    func withoutApplyingOrientation() -> UIImage {
        // If there's no underlying CGImage, just return self.
        guard let cg = self.cgImage else {
            return self
        }
        // Create a brand‐new UIImage from the raw CGImage, forcing orientation to .up
        return UIImage(
            cgImage: cg,
            scale: self.scale,
            orientation: .up
        )
    }
}
