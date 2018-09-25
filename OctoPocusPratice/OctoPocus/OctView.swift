//
//  OctView.swift
//  OctoPocusPratice
//
//  Created by urjhams on 8/27/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit


class OctView: UIImageView {
    // MARK: Constants
    
    static let activeTime = 0.1
    static let defualtTouchPressure = 0.8
    static let defaultBrushSize: CGFloat = 10.0
    static let defaultOpacity: CGFloat = 1.0
    static let listColors = [
        UIColor(red: 186.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0),
        UIColor(red: 27.0/255, green: 149.0/255, blue: 27.0/255, alpha: 1.0),
        UIColor(red: 24.0/255, green: 14.0/255, blue: 197.0/255, alpha: 1.0),
        UIColor(red: 153/255, green: 51/255, blue: 255/255, alpha: 1),
        UIColor(red: 0, green: 255/255, blue: 128/255, alpha: 1)
    ]
    static let listGestures = ["Cut", "Copy", "Paste","Down","Clear"]
    
    // MARK: Properties
    public var gestureHandler: (_ index: Int) -> () = {_ in
        print(index)
    }
    var brushSize: CGFloat = defaultBrushSize
    var colors: [UIColor] = listColors
    var dollar:Dollar?
    public var names: [String] = listGestures
    var timer = Timer()
    var time = 0.0
    
    var lastPoint = CGPoint.zero // Last point touched
    var lastPointForce = CGPoint.zero // First point touched with force
    
    var userPathForce = [CGPoint]() // Touch path with force
    var forceTouch = false
    
    // MARK: Constructors
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Methods
    
    func touchesBegan(_ touches: Set<UITouch>) {
        if let touch = touches.first { // If touches just began
            lastPoint = touch.location(in: self)
            dollar = Dollar(left: lastPoint.isLeftSideOf(frame: self.frame))
        }
    }
    
    func touchesMoved(_ touches: Set<UITouch>) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            if (!forceTouch) {
                userPathForce.removeAll()
                dollar!.clear()
                forceTouch = true
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                } else {
                    // Fallback on earlier versions
                }
            }
            dollar!.addPoint(x: Int(currentPoint.x), y: Int(currentPoint.y))
            if (lastPointForce == CGPoint.zero){
                lastPointForce = currentPoint
            }
            
            if (dollar!.points.count > 1){
                self.image = nil
                for view in self.subviews{
                    view.removeFromSuperview()
                }
                let results = dollar!.predict()
                if (results.count > 0) {
                    for i in 0...results.count-1{
                        let res = results[i]
                        let curColor = colors[res.index]
                        let points = dollar!.recognizer.RawTemplates[res.index]
                        drawPoints(points, text: names[res.index], color:curColor, strokeSize: self.brushSize*CGFloat(res.score)*CGFloat(res.score))
                    }
                }
            }
            userPathForce.append(currentPoint)
            lastPoint = currentPoint
        }
    }
    func touchesEnded(_ touches: Set<UITouch>) {
        self.image = nil
        for view in self.subviews{
            view.removeFromSuperview()
        }
        dollar!.recognize()
        let res = dollar!.result
        if (res.score as Double > 0.8) {
            self.gestureHandler(res.index)
        } else {
            
        }
        userPathForce.removeAll()
        dollar!.clear()
        lastPoint = CGPoint.zero
        lastPointForce = CGPoint.zero
    }
    func drawPoints(_ points: [CGPoint], text: String, color: UIColor, strokeSize: CGFloat){
        UIGraphicsBeginImageContext(self.frame.size)
        self.image?.draw(in: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        let context = UIGraphicsGetCurrentContext()
        let deltaX = points[0].x - lastPointForce.x
        let deltaY = points[0].y - lastPointForce.y
        var length = 0.0
        if (userPathForce.count > 1){
            for i in 1...userPathForce.count-1{
                length += Utils.Distance(p1: userPathForce[i-1], p2: userPathForce[i])
            }
        }
        
        var l = 0.0
        var t = 1
        while (l < length && t<points.count-1){
            l += Utils.Distance(p1: points[t], p2: points[t+1])
            context?.move(to: CGPoint(x: points[t-1].x-deltaX, y: points[t-1].y-deltaY))
            context?.addLine(to: CGPoint(x: points[t].x-deltaX, y: points[t].y-deltaY))
            t += 1
        }
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(strokeSize)
        let newc = color.darker()
        context?.setStrokeColor((newc?.cgColor)!)
        
        context?.strokePath()
        
        for i in t...points.count-1{
            context?.move(to: CGPoint(x: points[i-1].x-deltaX, y: points[i-1].y-deltaY))
            context?.addLine(to: CGPoint(x: points[i].x-deltaX, y: points[i].y-deltaY))
        }
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(strokeSize)
        context?.setStrokeColor(color.cgColor)
        context?.strokePath()
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let last = points.last!
        let label = UILabel(frame:CGRect(origin: CGPoint(x: last.x-deltaX-25,y :last.y-deltaY-10), size: CGSize(width: 50, height: 20)))
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.layer.borderWidth = 2.0
        label.layer.backgroundColor = UIColor.white.cgColor
        label.layer.cornerRadius = 5.0
        label.layer.borderColor = color.cgColor
        label.textColor = color
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
    }
    
    @objc public func runTimedCode() {
        if (forceTouch) {
            time += 0.01
        } else {
            time = 0.0
        }
    }
}

extension UIColor {
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

extension CGPoint {
    func isLeftSideOf(frame: CGRect) -> Bool {
        return self.x < CGFloat(frame.width / 2)
    }
}
