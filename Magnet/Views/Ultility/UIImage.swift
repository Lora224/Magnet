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
    func resized(maxSide: CGFloat = 1024) -> UIImage {
      let scaleRatio = min(1, maxSide / max(size.width, size.height))
      guard scaleRatio < 1 else { return self }
      let newSize = CGSize(width: size.width * scaleRatio,
                           height: size.height * scaleRatio)
      UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
      draw(in: CGRect(origin: .zero, size: newSize))
      let result = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return result ?? self
    }
}
