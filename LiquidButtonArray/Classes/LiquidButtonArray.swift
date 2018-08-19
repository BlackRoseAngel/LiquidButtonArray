//
//  LiquidButtonArray.swift
//  LiquidButtonArray
//
//  Created by Brett Chapin on 8/18/18.
//

import Foundation
import QuartzCore
import UIKit

// MARK: - LiquidButtonArrayDatasource
@objc public protocol LiquidButtonArrayDatasource {
    /**
     The number of cells for the given LiquidButtonArray.
     
     - Parameters:
         - liquidButtonArray: The affected LiquidButtonArray.
     */
    func numberOfCells(_ liquidButtonArray: LiquidButtonArray) -> Int
    /**
     A cell for a given index in a LiquidButtonArray.
     
     - Parameters:
        - liquidButtonArray: The affected LiquidButtonArray.
        - index: The index of the cell you are creating.
     */
    func cellForIndex(_ liquidButtonArray: LiquidButtonArray, cellAt index: Int) -> LiquidCell
    /**
     This function helps in the calculation of how far the cells are spaced from the LiquidButtonArray and each other.
     
     - Note:
     Each cell is a distance away from the sender by the diameter of the sender, taking into consideration the ratio.
     
     - Parameters:
        - liquidButtonArray: The affected LiquidButtonArray.
     */
    func distanceRatio(_ liquidButtonArray: LiquidButtonArray) -> CGFloat
}

// MARK: - LiquidButtonArrayDelegate
@objc public protocol LiquidButtonArrayDelegate {
    /**
     The action to be performed by a cell at a given index owned by a given LiquidButtonArray.
     
     - Parameters:
         - liquidButtonArray: The affected LiquidButtonArray.
         - index: The index of the given cell being selected.
    */
    @objc optional func liquidButtonArray(_ liquidButtonArray: LiquidButtonArray, didSelectCellAt index: Int)
    /**
     The action performed when the LiquidButtonArray is about to open.
     
     - Parameters:
         - liquidButtonArray: The affected LiquidButtonArray.
     */
    @objc optional func liquidButtonArrayWillOpen(_ liquidButtonArray: LiquidButtonArray)
    /**
     The action performed when the LiquidButtonArray is about to close.
     
     - Parameters:
         - liquidButtonArray: The affected LiquidButtonArray.
     */
    @objc optional func liquidButtonArrayWillClose(_ liquidButtonArray: LiquidButtonArray)
}

// MARK: - LiquidButtonArrayAnimateDirection
public enum LiquidButtonArrayAnimateDirection: Int {
    case up
    case right
    case down
    case left
    
    func differencePoint(_ distance: CGFloat) -> CGPoint {
        switch self {
        case .up:
            return CGPoint(x: 0, y: -distance)
        case .right:
            return CGPoint(x: distance, y: 0)
        case .down:
            return CGPoint(x: 0, y: distance)
        case .left:
            return CGPoint(x: -distance, y: 0)
        }
    }
    
    func reversePoint(_ distance: CGFloat) -> CGPoint {
        switch self {
        case .up:
            return CGPoint(x: 0, y: distance)
        case .right:
            return CGPoint(x: -distance, y: 0)
        case .down:
            return CGPoint(x: 0, y: -distance)
        case .left:
            return CGPoint(x: distance, y: 0)
        }
    }
}

// MARK: - LiquidButtonArray
public class LiquidButtonArray: BaseCircleView {
    
    // MARK: Animation Related Properties
    public var openingDuration: TimeInterval = 0.5
    public var closingDuration: TimeInterval = 0.2
    var closingKeyDuration: TimeInterval {
        get {
            return closingDuration / Double((dataSource?.numberOfCells(self))! + 1)
        }
    }
    private var keyDuration: TimeInterval = 0
    override var movementRatio: CGFloat {
        get {
            if let ratio = dataSource?.distanceRatio(self) {
                let distance = (radius + (radius * internalRadiusRatio)) + (radius * 2 * ratio)
                return distance
            }
            return 0
        }
    }
    
    public var animationDirection: LiquidButtonArrayAnimateDirection = .up
    var displayLink: CADisplayLink?
    
    var isOpen: Bool = false
    var isOpening: Bool = false
    public var rotationDegrees: CGFloat = 45.0
    public var cellSizeRatio: CGFloat = 0.8
    
    var cellArray: [LiquidCell] = []
    
    weak public var delegate: LiquidButtonArrayDelegate?
    weak public var dataSource: LiquidButtonArrayDatasource?
    
    // MARK: Initialization Methods
    public init(center: CGPoint, radius: CGFloat, image: UIImage? = nil) {
        super.init(center: center, radius: radius, color: .blue)
        if let img = image {
            setup(img)
        } else {
            setup(withBezier: createPlusLayer(self.frame))
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createPlusLayer(_ frame: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width * internalRadiusRatio, y: frame.height * 0.5))
        path.addLine(to: CGPoint(x: frame.width * invertedInternalRadiusRatio, y: frame.height * 0.5))
        path.move(to: CGPoint(x: frame.width * 0.5, y: frame.height * internalRadiusRatio))
        path.addLine(to: CGPoint(x: frame.width * 0.5, y: frame.height * invertedInternalRadiusRatio))
        
        return path
    }
    
    override func addCell(_ cell: LiquidCell) {
        super.addCell(cell)
        cell.radius = self.radius * cellSizeRatio
        cell.parentButton = self
        cellArray.append(cell)
    }
    
    func open() {
        delegate?.liquidButtonArrayWillOpen?(self)
        if !hasImage {
            rotateLayer(45)
        }
        
        if let cell = dataSource?.cellForIndex(self, cellAt: 0) {
            addCell(cell)
        }
        
        isOpening = true
        
        displayLink = CADisplayLink(target: self, selector: #selector(didDisplayRefresh(_:)))
        displayLink?.add(to: .current, forMode: .commonModes)
        
        isOpen = true
    }
    
    private func close() {
        delegate?.liquidButtonArrayWillClose?(self)
        if !hasImage {
            rotateLayer()
        }
        
        if let lastCell = cellArray.last {
            lastCell.close()
        }
        
        isOpen = false
    }
    
    private func stop() {
        displayLink?.invalidate()
        keyDuration = 0
        clearLiquidLayer()
    }
    
    private func rotateLayer(_ degrees: CGFloat = 0) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(openingDuration) //Not using openingKeyDuration
        super.bezierLayer.transform = CATransform3DMakeRotation(CGMath.degToRad(degrees), 0, 0, 1)
        CATransaction.commit()
    }
    
    private func tapped() {
        if isOpen {
            close()
        } else {
            super.tapped(duration: 0.3) {
                self.open()
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self),
            let view = hitTest(point, with: event) as? LiquidCell,
            let index = cellArray.index(of: view){
            delegate?.liquidButtonArray?(self, didSelectCellAt: index)
        }
        
        tapped()
    }
    
    private func push(distance: CGFloat) {
        let distancePoint = animationDirection.differencePoint(distance)
        cellArray[0].move(distance: distancePoint)
    }
    
    @objc func didDisplayRefresh(_ sender: CADisplayLink) {
        keyDuration += sender.duration
        let cellDistance = cellArray[0].center.distance(localCenter)
        
        if isOpening {
            let movementRate = movementRatio / CGFloat(openingDuration / sender.duration) // Not using openingKeyDuration
            push(distance: movementRate)
            drawLiquidLayer(movingBaseCircle: cellArray[0])
            
            if cellDistance + movementRate >= movementRatio {
                stop()
                cellArray[0].imageAlpha = 1.0
                cellArray[0].openNextCell(at: 1)
            }
        }
    }
    
}
