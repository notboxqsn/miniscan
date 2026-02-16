import ExpoModulesCore
import Vision
import UIKit

public class DocumentDetectionModule: Module {
  public func definition() -> ModuleDefinition {
    Name("DocumentDetection")

    AsyncFunction("detectDocument") { (base64: String) -> [String: [String: Double]]? in
      guard let data = Data(base64Encoded: base64),
            let image = UIImage(data: data),
            let cgImage = image.cgImage else {
        throw NSError(domain: "DocumentDetection", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Could not decode base64 image"])
      }

      // Map UIImage orientation to CGImagePropertyOrientation
      let cgOrientation: CGImagePropertyOrientation
      switch image.imageOrientation {
      case .up: cgOrientation = .up
      case .down: cgOrientation = .down
      case .left: cgOrientation = .left
      case .right: cgOrientation = .right
      case .upMirrored: cgOrientation = .upMirrored
      case .downMirrored: cgOrientation = .downMirrored
      case .leftMirrored: cgOrientation = .leftMirrored
      case .rightMirrored: cgOrientation = .rightMirrored
      @unknown default: cgOrientation = .up
      }

      return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String: [String: Double]]?, Error>) in
        let request = VNDetectRectanglesRequest { request, error in
          if let error = error {
            continuation.resume(throwing: error)
            return
          }

          guard let observations = request.results as? [VNRectangleObservation],
                let rect = observations.first else {
            continuation.resume(returning: nil)
            return
          }

          // Collect all 4 corners, convert from Vision (bottom-left origin) to screen (top-left origin)
          var points: [(x: Double, y: Double)] = [
            (Double(rect.topLeft.x), Double(1 - rect.topLeft.y)),
            (Double(rect.topRight.x), Double(1 - rect.topRight.y)),
            (Double(rect.bottomRight.x), Double(1 - rect.bottomRight.y)),
            (Double(rect.bottomLeft.x), Double(1 - rect.bottomLeft.y))
          ]

          // Clamp to [0, 1]
          points = points.map { (min(max($0.x, 0), 1), min(max($0.y, 0), 1)) }

          // Order corners by visual position: sort by y to get top pair and bottom pair,
          // then sort each pair by x to get left/right
          points.sort { $0.y < $1.y }
          let topPair = [points[0], points[1]].sorted { $0.x < $1.x }
          let bottomPair = [points[2], points[3]].sorted { $0.x < $1.x }

          let tl = topPair[0]
          let tr = topPair[1]
          let bl = bottomPair[0]
          let br = bottomPair[1]

          NSLog("[DocumentDetection] ordered: tl=(%.4f,%.4f) tr=(%.4f,%.4f) bl=(%.4f,%.4f) br=(%.4f,%.4f)",
                tl.x, tl.y, tr.x, tr.y, bl.x, bl.y, br.x, br.y)

          let corners: [String: [String: Double]] = [
            "tl": ["x": tl.x, "y": tl.y],
            "tr": ["x": tr.x, "y": tr.y],
            "br": ["x": br.x, "y": br.y],
            "bl": ["x": bl.x, "y": bl.y]
          ]

          continuation.resume(returning: corners)
        }

        // Configure for document/receipt detection
        request.minimumAspectRatio = 0.2
        request.maximumAspectRatio = 1.0
        request.minimumSize = 0.1
        request.maximumObservations = 1
        request.minimumConfidence = 0.3

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgOrientation, options: [:])
        do {
          try handler.perform([request])
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
