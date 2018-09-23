//
//  Dollar.swift
//  OctoPocusPratice
//
//  Created by urjhams on 8/27/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit

class Dollar{
    var x,y: Int!
    var state: Int!
    
    var key = Int(-1)
    
    var gesture = true
    var points = [CGPoint]()
    
    var recognizer: Recognizer!
    var result = Result(index: -1, score: 0, theta: Utils.lastTheta)
    
    var active = true
    
    var gestureSet: Int!
    
    init(){
        recognizer = Recognizer()
    }
    
    public func getPoints() -> [CGPoint] {
        return points
    }
    
    public func addPoint(x: Int, y: Int) {
        if (active){
            points.append(CGPoint(x: x, y: y))
        }
    }
    
    public func recognize() {
        
        if (!active){
            return
        }
        
        if (points.count == 0){
            return
        }
        
        result = recognizer.Recognize(points: points)
        
    }
    
    public func predict() -> [Result]{
        if (!active){
            return [Result]()
        }
        
        if (points.count == 0){
            return [Result]()
        }
        return recognizer.Predict(points: points)
    }
    
    
    public func clear() {
        points.removeAll()
        result.score = 0
        result.index = -1
    }
}
