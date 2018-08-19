//
//  LiquidCell.swift
//  LiquidButtonArray
//
//  Created by Brett Chapin on 8/18/18.
//

import Foundation
import UIKit

typealias Index = Int

public class LiquidCell: BaseCircleView {
    
    var parentButton: LiquidButtonArray!
    private var displayLink: CADisplayLink?
    
    var openingDuration: TimeInterval {
        get {
            return parentButton.openingDuration
        }
    }
    var closingKeyDuration: TimeInterval {
        get {
            return parentButton.closingKeyDuration
        }
    }
    private var keyDuration: TimeInterval = 0
    
    var index: Index {
        get {
            if let index = parentButton?.cellArray.index(of: self) {
                return index
            }
            return 0
        }
    }
    
    override var movementRatio: CGFloat {
        get {
            if let ratio = parentButton.dataSource?.distanceRatio(parentButton!) {
                let distance = (radius * 2) + (radius * 2 * ratio)
                return distance
            }
            return 0
        }
    }
    
    override public var frame: CGRect {
        didSet {
            super.resizeSubviews()
        }
    }
    
    init(center: CGPoint, radius: CGFloat, color: UIColor, icon: UIImage) {
        super.init(center: center, radius: radius, color: color)
        setup(icon)
    }
    
    public init(icon: UIImage) {
        super.init()
        setup(icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        self.view.bounds = bounds
    }
    
    override func addCell(_ cell: LiquidCell) {
        super.addCell(cell)
        cell.parentButton = parentButton
        parentButton?.cellArray.append(cell)
    }
    
    func openNextCell(at index: Index) {
        if let cell = parentButton?.dataSource?.cellForIndex(parentButton!, cellAt: index), index < (parentButton?.dataSource?.numberOfCells(parentButton!))! {
            addCell(cell)
            
            
            displayLink = CADisplayLink(target: self, selector: #selector(didDisplayRefresh(_:)))
            displayLink?.add(to: .current, forMode: .commonModes)
        } else {
            parentButton.isOpening = false
        }
    }
    
    func close() {
        displayLink = CADisplayLink(target: self, selector: #selector(didDisplayRefresh(_:)))
        displayLink?.add(to: .current, forMode: .commonModes)
    }
    
    private func stop() {
        displayLink?.invalidate()
        keyDuration = 0
        clearLiquidLayer()
    }
    
    func move(distance: CGPoint) {
        center = center.plus(distance)
    }
    
    private func push(distance: CGFloat) {
        if let distancePoint = parentButton?.animationDirection.differencePoint(distance) {
            parentButton?.cellArray[index + 1].move(distance: distancePoint)
        }
    }
    
    private func pull(distance: CGFloat) {
        if let distancePoint = parentButton?.animationDirection.reversePoint(distance) {
            parentButton.cellArray[index].move(distance: distancePoint)
        }
    }
    
    @objc func didDisplayRefresh(_ sender: CADisplayLink) {
        keyDuration += sender.duration
        
        if (parentButton?.isOpening)! {
            let cellDistance = parentButton.cellArray[index + 1].center.distance(localCenter)
            let movementRate = movementRatio / CGFloat(openingDuration / sender.duration)
            push(distance: movementRate)
            drawLiquidLayer(movingBaseCircle: parentButton.cellArray[index + 1])
            
            if cellDistance + movementRate >= movementRatio {
                stop()
                parentButton.cellArray[index + 1].imageAlpha = 1.0
                parentButton?.cellArray[index + 1].openNextCell(at: index + 2)
            }
        } else {
            var cellDistance: CGFloat = 0
            let movementRate = movementRatio / CGFloat(closingKeyDuration / sender.duration)
            pull(distance: movementRate)
            
            if index > 0 {
                cellDistance = parentButton.cellArray[index - 1].localCenter.distance(center)
                if cellDistance - movementRate <= 0 {
                    stop()
                    parentButton.cellArray[index - 1].close()
                    parentButton.cellArray.remove(at: index)
                    self.removeFromSuperview()
                }
            } else {
                cellDistance = parentButton.localCenter.distance(center)
                if cellDistance - movementRate <= 0 {
                    stop()
                    parentButton.cellArray.remove(at: index)
                    self.removeFromSuperview()
                }
            }
        }
    }
    
}
