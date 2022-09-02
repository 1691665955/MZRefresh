//
//  UIImage+MZRefresh.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/15.
//

import Foundation
import UIKit

extension UIImage {
    func color(atPoint point: CGPoint) -> UIColor {
        let imageWidth = self.size.width
        let imageHeight = self.size.width
        if !CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight).contains(point) {
            return .clear
        }
        
        let provider = self.cgImage?.dataProvider
        let providerData = provider?.data
        let data = CFDataGetBytePtr(providerData)
        
        let x = Int(trunc(point.x))
        let y = Int(trunc(point.y))
        
        let numberOfComponents = 4
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents
        
        let r = CGFloat(data![pixelData]) / 255.0
        let g = CGFloat(data![pixelData + 1]) / 255.0
        let b = CGFloat(data![pixelData + 2]) / 255.0
        let a = CGFloat(data![pixelData + 3]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
