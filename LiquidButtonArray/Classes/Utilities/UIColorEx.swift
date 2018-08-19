//
//  UIColorEx.swift
//  LiquidButtonArray
//
//  Created by Brett Chapin on 8/18/18.
//

import Foundation
import UIKit

extension UIColor {
    
    var redC: CGFloat {
        get {
            let components = self.cgColor.components
            return components![0]
        }
    }
    
    var greenC: CGFloat {
        get {
            let components = self.cgColor.components
            return components![1]
        }
    }
    
    var blueC: CGFloat {
        get {
            let components = self.cgColor.components
            return components![2]
        }
    }
    
    var alpha: CGFloat {
        get {
            return self.cgColor.alpha
        }
    }
    
    func alpha(_ alpha: CGFloat) -> UIColor {
        return UIColor(red: self.redC, green: self.greenC, blue: self.blueC, alpha: alpha)
    }
    
    func white(_ scale: CGFloat) -> UIColor {
        return UIColor(
            red: self.redC + (1.0 - self.redC) * scale,
            green: self.greenC + (1.0 - self.greenC) * scale,
            blue: self.blueC + (1.0 - self.blueC) * scale,
            alpha: 1.0
        )
    }
    
}
