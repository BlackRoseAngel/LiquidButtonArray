//
//  CGPointEx.swift
//  LiquidButtonArray
//
//  Created by Brett Chapin on 8/18/18.
//

import Foundation
import UIKit

extension CGPoint {
    /**
     Adds a point value to the current point.
     
     - Parameters:
        - point: The point to add.
     
     - Returns:
     returnValue: The added value of self and point.
     
     */
    func plus(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
    /**
     Adds a CGFloat value to the X of the current point.
     
     - Parameters:
        - dx: The CGFloat value to add.
     
     - Returns:
     returnValue: A new point with the added float value to the X of self.
     
     */
    func plusX(_ dx: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y)
    }
    /**
     Adds a CGFloat value to the Y of the current point.
     
     - Parameters:
        - dy: The CGFloat value to add.
     
     - Returns:
     returnValue: A new point with the added float value to the Y of self.
     
     */
    func plusY(_ dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y + dy)
    }
    /**
     Subtracts a point value from the current point.
     
     - Parameters:
        - point: The point to subtract.
     
     - Returns:
     returnValue: The subtracted value of self and point.
     
     */
    func minus(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x - point.x, y: self.y - point.y)
    }
    /**
     Subtracts a CGFloat value from the X of the current point.
     
     - Parameters:
        - dx: The CGFloat value to subtract.
     
     - Returns:
     returnValue: A new point with the subtracted float value from the X of self.
     
     */
    func minusX(_ dx: CGFloat) -> CGPoint {
        return CGPoint(x: self.x - dx, y: self.y)
    }
    /**
     Subtracts a CGFloat value from the Y of the current point.
     
     - Parameters:
        - dy: The CGFloat value to subtract.
     
     - Returns:
     returnValue: A new point with the subtracted float value from the Y of self.
     
     */
    func minusY(_ dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y - dy)
    }
    /**
     Multiplies two point values.
     
     - Parameters:
        - rhs: The point to multiply self by.
     
     - Returns:
     returnValue: A new point that is the product of rhs and self.
     */
    func mul(_ rhs: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * rhs, y: self.y * rhs)
    }
    /**
     Calculates the distance between to points.
     
     - Parameters:
        - rhs: The point to calculate the distance to.
     
     - Returns:
     returnValue: The distance in points between rhs and self, represented as a CGFloat.
    */
    func distance(_ rhs: CGPoint) -> CGFloat {
        let point = rhs.minus(self)
        return point.length()
    }
    
    private func length() -> CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
    private func split(_ point: CGPoint, ratio: CGFloat) -> CGPoint {
        return self.mul(ratio).plus(point.mul(1.0 - ratio))
    }
    /**
     The point in the middle between two given points.
     
     - Parameters:
        - point: The point to calculate the middle point between.
     
     - Returns:
     returnValue: The middle point of point and self.
     */
    func mid(_ point: CGPoint) -> CGPoint {
        return split(point, ratio: 0.5)
    }
    /**
     Calculates the point on a given circle based upon the radian.
     
     - Parameters:
         - origin: The center point of the circle.
         - radius: The radius of the given circle.
         - radian: The radian of the point you want to find.
     
     - Returns:
     returnValue: The point on a circle's circumference given a specific radian.
     */
    static func pointOnCircumference(origin: CGPoint, radius: CGFloat, radian: CGFloat) -> CGPoint {
        let x = origin.x + radius * cos(radian)
        let y = origin.y + radius * sin(radian)
        return CGPoint(x: x, y: y)
    }
    /**
     Calculates the radian of a point on a circle.
     - Note:
     This method can be used to find the radian of two points regardless of whether it is a circle or not.
     
     - Parameters:
         - point: The given point on a circle's circumference to calculate the radian.
         - origin: The center point of the circle.
     
     - Returns:
     returnValue: The radian between two points.
     */
    static func radianFromGiven(point: CGPoint, origin: CGPoint) -> CGFloat {
        let radian = atan2(point.y - origin.y, point.x - origin.x)
        return radian
    }
}
