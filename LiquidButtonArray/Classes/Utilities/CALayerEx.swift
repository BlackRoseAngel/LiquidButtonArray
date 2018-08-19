//
//  CALayerEx.swift
//  LiquidButtonArray
//
//  Created by Brett Chapin on 8/18/18.
//

import Foundation
import UIKit

extension CALayer {
    
    /**
     Adds a shadow to the current layer.
     */
    func addShadow() {
        self.shadowColor = UIColor.black.cgColor
        self.shadowRadius = 2.0
        self.shadowOpacity = 0.3
        self.shadowOffset = CGSize(width: 2, height: 2)
        self.masksToBounds = false
    }
    
    /**
     Removes current layer's shadow.
    */
    func removeShadow() {
        self.shadowRadius = 0.0
        self.shadowColor = UIColor.clear.cgColor
    }
    
}
