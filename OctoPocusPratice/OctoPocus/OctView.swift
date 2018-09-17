//
//  OctView.swift
//  OctoPocusPratice
//
//  Created by urjhams on 8/27/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit

class OctView: UIImageView {
    
    fileprivate static let TRAINNING_MODE_ACTIVATE_TIME = 0.1
    fileprivate static let DEFAULT_TOUCH_PRESSURE = 0.8
    fileprivate static let DEFAULT_BRUSH_SIZE: CGFloat = 10.0
    fileprivate static let DEFAULT_OPACITY: CGFloat = 1.0
    fileprivate static let DEFAULT_COLORS = [
        UIColor(red: 186.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0),
        UIColor(red: 27.0/255, green: 149.0/255, blue: 27.0/255, alpha: 1.0),
        UIColor(red: 24.0/255, green: 14.0/255, blue: 197.0/255, alpha: 1.0)
    ]
    
    public var gesturedHandler: (_ index: Int) -> () = { index in
        print(index)
    }
    var brushSize: CGFloat = DEFAULT_BRUSH_SIZE
    var colors = DEFAULT_COLORS
    var dollar = Dollar()
    public var names: [String] = ["Cut", "Copy", "Paste"]
    var timer = Timer()
    var time = 0.0
    
    var lastPoint = CGPoint.zero            // last touched point
    var lastForcePoint = CGPoint.zero       // first 3D touch point
    
    var userForcePath = [CGPoint]()         // list of 3D touch points
    var forceTouch = false
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(runTimeCode), userInfo: nil, repeats: true)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @objc func runTimeCode() {
        time = (forceTouch) ? time + 0.01 : 0.0
    }
}

// MARK: Methods
extension OctView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastPoint = touch.location(in: self)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            if !forceTouch {
                userForcePath.removeAll()
                dollar.clear()
                forceTouch = true
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }
            dollar.addPoint(x: Int(currentPoint.x), y: Int(currentPoint.y))
            if (lastForcePoint == CGPoint.zero) {
                lastForcePoint = currentPoint
            }
            
            if dollar.points.count > 1 {
                self.image = nil
                for view in self.subviews {
                    view.removeFromSuperview()
                }
                let result = dollar.predict()
                if result.count > 0 {
                    for index in 0...result.count-1 {
                        let res = result[index]
                        let currColor = colors[res.index]
                        let points = dollar.recognizer.RawTemplates[res.index]
                        drawPoints(points, text: names[res.index], color: currColor, strokeSize: self.brushSize * CGFloat(res.score) * CGFloat(res.score))
                    }
                }
            }
            userForcePath.append(currentPoint)
            lastPoint = currentPoint
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.image = nil
        for view in self.subviews {
            view.removeFromSuperview()
        }
        dollar.recognize()
        let res = dollar.result
        if res.score as Double > 0.8 {
            self.gesturedHandler(res.index)
        }
        userForcePath.removeAll()
        dollar.clear()
        lastPoint = CGPoint.zero
        lastForcePoint = CGPoint.zero
    }
    
    private func drawPoints(_ points: [CGPoint], text: String, color: UIColor, strokeSize: CGFloat){
        UIGraphicsBeginImageContext(self.frame.size)
        self.image?.draw(in: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        let context = UIGraphicsGetCurrentContext()
        let deltaX = points[0].x - lastForcePoint.x
        let deltaY = points[0].y - lastForcePoint.y
        var length = 0.0
        if (userForcePath.count > 1){
            for index in 1...userForcePath.count-1{
                length += Utils.Distance(p1: userForcePath[index-1], p2: userForcePath[index])
            }
        }
        
        var defLength = 0.0
        var point = 1
        while (defLength < length && point<points.count-1){
            defLength += Utils.Distance(p1: points[point], p2: points[point+1])
            context?.move(to: CGPoint(x: points[point-1].x-deltaX, y: points[point-1].y-deltaY))
            context?.addLine(to: CGPoint(x: points[point].x-deltaX, y: points[point].y-deltaY))
            point += 1
        }
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(strokeSize)
        let newc = color.darker()
        context?.setStrokeColor((newc?.cgColor)!)
        
        context?.strokePath()
        
        for i in point...points.count-1{
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
