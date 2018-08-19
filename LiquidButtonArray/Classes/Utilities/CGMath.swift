//
//  CGMath.swift
//  LiquidButtonArray
//
//  Created by Brett Chapin on 8/18/18.
//

import Foundation
import UIKit

/**
 A simple function that aids in the creation of UIBezierPath.
 
 - Parameters:
    - f: A UIBezierPath in a closure that can be modified as needed.
 
 - Returns:
 returnValue: A UIBezierPath that has been created and closed.
 */
func withBezier(_ f: (UIBezierPath) -> ()) -> UIBezierPath {
    let bezierPath = UIBezierPath()
    f(bezierPath)
    bezierPath.close()
    return bezierPath
}

class CGMath {
    /**
     Converts a radian value to degrees.
     
     - Parameters:
        - rad: The radian value to convert.
     
     - Returns:
     returnValue: Degrees
     */
    static func radToDeg(_ rad: CGFloat) -> CGFloat {
        return rad * 180 / CGFloat.pi
    }
    /**
     Converts a degree value into radians.
     
     - Parameters:
        - deg: The degree value to convert.
     
     - Returns:
     returnValue: Radians
     */
    static func degToRad(_ deg: CGFloat) -> CGFloat {
        return deg * CGFloat.pi / 180
    }
    
}
