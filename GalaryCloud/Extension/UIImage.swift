//
//  UIImage.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 02.12.2025.
//

import UIKit
import CoreGraphics

extension UIImage {
    func changeSize(newWidth:CGFloat, from:CGSize? = nil, origin:CGPoint = .zero) -> UIImage {
        let widthPercent = newWidth / (from?.width ?? self.size.width)
        let proportionalSize: CGSize = .init(width: newWidth, height: widthPercent * (from?.height ?? self.size.height))
#if !os(watchOS)
        let renderer = UIGraphicsImageRenderer(size: proportionalSize)
        let newImage = renderer.image { _ in
            self.draw(in: CGRect(origin: origin, size: proportionalSize))
        }
        return newImage
#else
        return self
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        
//        guard let context = CGContext(
//            data: nil,
//            width: Int(proportionalSize.width),
//            height: Int(proportionalSize.height),
//            bitsPerComponent: 8,
//            bytesPerRow: 0,
//            space: colorSpace,
//            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
//        ) else {
//            return .init()
//        }
//        
//        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
//        context.fill(CGRect(origin: .zero, size: size))
//        
//        if let image = context.makeImage() {
//            return .init(cgImage: image)
//        } else {
//            return .init()
//
//        }
#endif
    }
}
