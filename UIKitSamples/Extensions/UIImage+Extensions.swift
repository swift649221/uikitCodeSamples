//
//  UISwipeAction+Extensions.swift
//  AirBill
//
//  Created by Andrey on 12.07.2022.
//

import UIKit

extension UIImage {
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func addLabelToImage(label: UILabel) -> UIImage? {
        let tempView = UIStackView(frame: CGRect(x: 0, y: 0, width: 68, height: 52))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tempView.frame.width, height: 50))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 3
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .medium)
        imageView.image = self.withConfiguration(largeConfig)
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
    
    func createThumbnail() -> UIImage {
        
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 200] as CFDictionary
        
        guard let imageData = self.jpegData(compressionQuality: 1),
              let imageSource = CGImageSourceCreateWithData(imageData as NSData, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options)
        else {
            return UIImage()
        }
        
        return UIImage(cgImage: image)
    }
    
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
         var width: CGFloat
         var height: CGFloat
         var newImage: UIImage

         let size = self.size
         let aspectRatio =  size.width/size.height

         switch contentMode {
             case .scaleAspectFit:
                 if aspectRatio > 1 {                            // Landscape image
                     width = dimension
                     height = dimension / aspectRatio
                 } else {                                        // Portrait image
                     height = dimension
                     width = dimension * aspectRatio
                 }

         default:
             fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
         }

         if #available(iOS 10.0, *) {
             let renderFormat = UIGraphicsImageRendererFormat.default()
             renderFormat.opaque = opaque
             let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
             newImage = renderer.image {
                 (context) in
                 self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
             }
         } else {
             UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
                 self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
                 newImage = UIGraphicsGetImageFromCurrentImageContext()!
             UIGraphicsEndImageContext()
         }

         return newImage
     }
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
    func rotateFixImage() -> UIImage {
        if (self.imageOrientation == UIImage.Orientation.up ) {
            return self
        }
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy ?? UIImage()
    }
    
    func setOrientation(_ orientation: Orientation) -> UIImage {
        if let cgImage = self.cgImage {
            return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            context.cgContext.concatenate(CGAffineTransform(scaleX: -1, y: 1))
            self.draw(at: CGPoint(x: -size.width, y: 0))
        }
    }
    
}
