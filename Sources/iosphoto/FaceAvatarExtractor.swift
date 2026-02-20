import UIKit
import Vision
import ImageIO

enum FaceAvatarExtractor {
    static func extractAvatar(from image: UIImage) async -> UIImage? {
        guard let cgImage = image.cgImage else { return centerSquare(from: image) }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNDetectFaceRectanglesRequest()
                let orientation = cgImageOrientation(from: image.imageOrientation)
                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

                do {
                    try handler.perform([request])
                    guard
                        let faces = request.results as? [VNFaceObservation],
                        let largestFace = faces.max(by: { area(of: $0.boundingBox) < area(of: $1.boundingBox) })
                    else {
                        continuation.resume(returning: centerSquare(from: image))
                        return
                    }

                    let imageRect = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
                    let faceRect = convertToImageRect(largestFace.boundingBox, imageSize: imageRect.size)
                    let expanded = faceRect.insetBy(dx: -faceRect.width * 0.35, dy: -faceRect.height * 0.5)
                    let squareRect = squareCropRect(from: expanded, within: imageRect).integral

                    guard
                        squareRect.width > 0,
                        squareRect.height > 0,
                        let cropped = cgImage.cropping(to: squareRect)
                    else {
                        continuation.resume(returning: centerSquare(from: image))
                        return
                    }

                    continuation.resume(
                        returning: UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
                    )
                } catch {
                    continuation.resume(returning: centerSquare(from: image))
                }
            }
        }
    }

    static func centerSquare(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let side = min(width, height)
        let x = (width - side) / 2
        let y = (height - side) / 2
        let rect = CGRect(x: x, y: y, width: side, height: side).integral

        guard let cropped = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }

    private static func area(of rect: CGRect) -> CGFloat {
        rect.width * rect.height
    }

    private static func convertToImageRect(_ normalized: CGRect, imageSize: CGSize) -> CGRect {
        // Vision uses bottom-left origin; UIKit image coordinates are top-left.
        let x = normalized.origin.x * imageSize.width
        let y = (1 - normalized.origin.y - normalized.height) * imageSize.height
        let w = normalized.width * imageSize.width
        let h = normalized.height * imageSize.height
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private static func squareCropRect(from rect: CGRect, within imageRect: CGRect) -> CGRect {
        let side = max(rect.width, rect.height)
        var square = CGRect(
            x: rect.midX - side / 2,
            y: rect.midY - side / 2,
            width: side,
            height: side
        )

        if square.minX < imageRect.minX {
            square.origin.x = imageRect.minX
        }
        if square.minY < imageRect.minY {
            square.origin.y = imageRect.minY
        }
        if square.maxX > imageRect.maxX {
            square.origin.x = imageRect.maxX - square.width
        }
        if square.maxY > imageRect.maxY {
            square.origin.y = imageRect.maxY - square.height
        }

        // If the square is still larger than image bounds, clamp to center square in image.
        if square.width > imageRect.width || square.height > imageRect.height {
            let side2 = min(imageRect.width, imageRect.height)
            square = CGRect(
                x: imageRect.midX - side2 / 2,
                y: imageRect.midY - side2 / 2,
                width: side2,
                height: side2
            )
        }

        return square
    }

    private static func cgImageOrientation(from orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
