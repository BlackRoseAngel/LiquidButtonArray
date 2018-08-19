//
//  BaseCircleView.swift
//  LiquidButtonArray
//
//  Created by Brett Chapin on 8/18/18.
//

import Foundation
import UIKit

public class BaseCircleView: UIView {
    
    // MARK: Layer Properties
    let animationLayer = CAShapeLayer()
    let circleLayer = CAShapeLayer()
    let bezierLayer = CAShapeLayer()
    var liquidLayer = CAShapeLayer()
    
    // MARK: View Properties
    var view = UIView()
    private var imageView = UIImageView()
    var hasImage: Bool = false
    
    // MARK: Appearance Properties
    public var internalRadiusRatio: CGFloat = 0.8 {
        didSet {
            if (internalRadiusRatio < 0) || (internalRadiusRatio > 1) {
                internalRadiusRatio = oldValue
            }
        }
    }
    
    var invertedInternalRadiusRatio: CGFloat {
        return 1 - internalRadiusRatio
    }
    
    public var radius: CGFloat {
        didSet {
            setup()
        }
    }
    
    override public var center: CGPoint {
        didSet {
            setup()
        }
    }
    
    var localCenter: CGPoint {
        get {
            return view.center
        }
    }
    
    public var color: UIColor = .blue {
        didSet {
            setup()
        }
    }
    
    var imageAlpha: CGFloat = 0 {
        didSet {
            if (imageAlpha < 0) || (imageAlpha > 1) {
                imageAlpha = oldValue
            } else {
                imageView.alpha = imageAlpha
            }
        }
    }
    
    public var enableShadow: Bool = true {
        didSet {
            if enableShadow {
                circleLayer.addShadow()
            } else {
                circleLayer.removeShadow()
            }
        }
    }
    
    // MARK: Liquidable Properties
    var movementRatio: CGFloat {
        get {
            return radius * 2
        }
    }
    private var splitPoint: CGFloat = 0.8
    
    // MARK: Initialization Methods
    init() {
        self.radius = 0
        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear
        setup()
        view.layer.addSublayer(circleLayer)
        view.isOpaque = false
        view.isUserInteractionEnabled = false
        addSubview(view)
    }
    
    init(center: CGPoint, radius: CGFloat, color: UIColor = .red) {
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        self.radius = radius
        self.color = color
        super.init(frame: frame)
        self.backgroundColor = .clear
        setup()
        view.layer.addSublayer(animationLayer)
        view.layer.addSublayer(circleLayer)
        view.isOpaque = false
        view.isUserInteractionEnabled = false
        addSubview(view)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Failed to initialize coder")
    }
    
    public override func draw(_ rect: CGRect) {
        drawCircle()
    }
    
    // MARK: Setup Methods
    func setup() {
        self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        let viewFrame = CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)
        view.frame = viewFrame
        drawCircle()
    }
    
    func setup(_ image: UIImage) {
        imageView.image = image
        imageView.isUserInteractionEnabled = false
        imageView.alpha = 0
        view.addSubview(imageView)
        hasImage = true
        setup()
        resizeSubviews()
    }
    
    func setup(withBezier path: UIBezierPath) {
        bezierLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        bezierLayer.lineCap = kCALineCapRound
        bezierLayer.strokeColor = UIColor.white.cgColor
        bezierLayer.lineWidth = radius * 0.13
        bezierLayer.path = path.cgPath
        
        view.layer.addSublayer(bezierLayer)
        setup()
    }
    
    private func setup(_ view: UIView) {
        view.isUserInteractionEnabled = false
        view.addSubview(view)
        resizeSubviews()
    }
    
    func resizeSubviews() {
        let size = CGSize(width: frame.width * internalRadiusRatio, height: frame.height * internalRadiusRatio)
        let modifier = invertedInternalRadiusRatio / 2
        let point = CGPoint(x: frame.width * modifier, y: frame.height * modifier)
        imageView.frame = CGRect(origin: point, size: size)
    }
    
    private func drawCircle() {
        let bezierPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: radius * 2, height: radius * 2)))
        circleLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        circleLayer.lineWidth = 3.0
        circleLayer.fillColor = self.color.cgColor
        circleLayer.path = bezierPath.cgPath
        circleLayer.masksToBounds = true
        
        animationLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        animationLayer.path = bezierPath.cgPath
        animationLayer.lineWidth = 3.0
        animationLayer.fillColor = UIColor.white.cgColor
        
        if enableShadow {
            circleLayer.addShadow()
        }
    }
    
    // MARK: Touch Interaction Methods
    func tapped(duration: TimeInterval, _ completion: @escaping ()->Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            self.animationLayer.transform = CATransform3DMakeScale(1, 1, 1)
            self.animationLayer.opacity = 1
            
            CATransaction.commit()
            completion()
        }
        animationLayer.transform = CATransform3DMakeScale(1.5, 1.5, 1)
        animationLayer.opacity = 0
        
        CATransaction.commit()
        
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return super.hitTest(point, with: event)
        }
        
        guard isUserInteractionEnabled, !isHidden, alpha > 0 else {
            return nil
        }
        
        for subview in self.subviews.reversed() {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        
        return nil
    }
    
    // MARK: Convenience Methods
    func addCell(_ cell: LiquidCell) {
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.center = CGPoint(x: radius, y: radius)
        cell.radius = self.radius
        addSubview(cell)
    }
    
    override public func addSubview(_ view: UIView) {
        insertSubview(view, belowSubview: self.view)
    }
    
    // MARK: Liquidable Methods
    private func isConnected(movingBaseCircle view: BaseCircleView) -> Bool {
        let distance = view.center.distance(localCenter)
        return distance < view.radius + radius
    }
    
    private func viewKissingPoints(movingBaseCircle view: BaseCircleView) -> (movingView: CGPoint, view: CGPoint) {
        let viewBottom = CGPoint.pointOnCircumference(origin: view.center, radius: view.radius, radian: CGMath.degToRad(90))
        let selfTop = CGPoint.pointOnCircumference(origin: localCenter, radius: radius, radian: CGMath.degToRad(270))
        return (viewBottom, selfTop)
    }
    
    private func distanceRatio(movingBaseCircle view: BaseCircleView) -> CGFloat {
        let (viewBottom, selfTop) = viewKissingPoints(movingBaseCircle: view)
        let distance = viewBottom.distance(selfTop)
        return distance / (movementRatio - radius - view.radius)
    }
    
    private func constructLayer(path: UIBezierPath) -> CAShapeLayer {
        let pathBounds = path.cgPath.boundingBox
        
        let shape = CAShapeLayer()
        shape.fillColor = self.color.cgColor
        shape.path = path.cgPath
        shape.frame = CGRect(x: 0, y: 0, width: pathBounds.width, height: pathBounds.height)
        
        return shape
    }
    
    func drawLiquidLayer(movingBaseCircle view: BaseCircleView) {
        clearLiquidLayer()
        
        if let paths = generatePath(movingBaseCircle: view) {
            let layers = paths.map(self.constructLayer)
            layers.forEach(liquidLayer.addSublayer(_:))
        }
        
        layer.addSublayer(liquidLayer)
        
    }
    
    func clearLiquidLayer() {
        liquidLayer.removeFromSuperlayer()
        liquidLayer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        liquidLayer = CAShapeLayer()
    }
    
    private func generatePath(movingBaseCircle view: BaseCircleView) -> [UIBezierPath]? {
        if !isConnected(movingBaseCircle: view) {
            let ratio = distanceRatio(movingBaseCircle: view)
            switch ratio {
            case 0..<splitPoint:
                if let path = connectedPath(movingBaseCircle: view, ratio: ratio) {
                    return [path]
                }
                return nil
            case splitPoint...1:
                let path = splitPath(movingBaseCircle: view, ratio: ratio)
                return path
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func connectedPath(movingBaseCircle view: BaseCircleView, ratio: CGFloat) -> UIBezierPath? {
        let (viewBottom, selfTop) = viewKissingPoints(movingBaseCircle: view)
        let midPoint = viewBottom.mid(selfTop)
        let inverseRatio = 0.8 - ratio
        
        return withBezier({ (path) in
            path.move(to: CGPoint.pointOnCircumference(origin: view.center, radius: view.radius, radian: CGMath.degToRad(135)))
            path.addArc(withCenter: view.center, radius: view.radius, startAngle: CGMath.degToRad(135), endAngle: CGMath.degToRad(45), clockwise: false)
            let controlPoint = midPoint.plusX(view.radius * inverseRatio)
            path.addQuadCurve(to: CGPoint.pointOnCircumference(origin: localCenter, radius: radius, radian: CGMath.degToRad(315)), controlPoint: controlPoint)
            path.addArc(withCenter: localCenter, radius: radius, startAngle: CGMath.degToRad(315), endAngle: CGMath.degToRad(225), clockwise: false)
            let controlPoint2 = midPoint.minusX(view.radius * inverseRatio)
            path.addQuadCurve(to: CGPoint.pointOnCircumference(origin: view.center, radius: view.radius, radian: CGMath.degToRad(135)), controlPoint: controlPoint2)
        })
    }
    
    private func splitPath(movingBaseCircle view: BaseCircleView, ratio: CGFloat) -> [UIBezierPath] {
        let (viewBottom, selfTop) = viewKissingPoints(movingBaseCircle: view)
        let distance = viewBottom.distance(selfTop)
        let reductionCorrection = distance * ((0.8 - ratio) * -5)
        
        let viewPart = withBezier { (path) in
            let startPoint = CGPoint.pointOnCircumference(origin: view.center, radius: view.radius, radian: CGMath.degToRad(135))
            let controlPoint = selfTop.minusY(reductionCorrection)
            path.move(to: startPoint)
            path.addArc(withCenter: view.center, radius: view.radius, startAngle: CGMath.degToRad(135), endAngle: CGMath.degToRad(45), clockwise: false)
            path.addQuadCurve(to: startPoint, controlPoint: controlPoint)
        }
        
        let selfPart = withBezier { (path) in
            let startPoint = CGPoint.pointOnCircumference(origin: localCenter, radius: radius, radian: CGMath.degToRad(315))
            let controlPoint = viewBottom.plusY(reductionCorrection)
            path.move(to: startPoint)
            path.addArc(withCenter: localCenter, radius: radius, startAngle: CGMath.degToRad(315), endAngle: CGMath.degToRad(225), clockwise: false)
            path.addQuadCurve(to: startPoint, controlPoint: controlPoint)
        }
        
        return [viewPart, selfPart]
    }
    
}
