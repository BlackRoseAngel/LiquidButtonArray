//
//  CGRectEx.swift
//  LiquidButtonArray
//
//  Created by Brett Chapin on 8/18/18.
//

import Foundation
import UIKit

extension CGRect {

    var rightBottom: CGPoint {
        get {
            return CGPoint(x: origin.x + width, y: origin.y + height)
        }
    }
    
    var center: CGPoint {
        get {
            return origin.plus(rightBottom).mul(0.5)
        }
    }
    
}
