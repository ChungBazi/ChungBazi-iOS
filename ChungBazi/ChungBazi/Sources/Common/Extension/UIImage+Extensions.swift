//
//  UIImage+Extensions.swift
//  ChungBazi
//
//  Created by 신호연 on 1/28/25.
//

import UIKit

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func applyBlurEffect() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(10.0, forKey: kCIInputRadiusKey)
            
        guard let outputImage = blurFilter?.outputImage else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
