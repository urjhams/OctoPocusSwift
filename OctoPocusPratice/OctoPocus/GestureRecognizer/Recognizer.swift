//
//  Recognizer.swift
//  OctoPocusPratice
//
//  Created by urjhams on 8/27/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit

public class Recognizer {
    public static let numPoints = 16
    public static let squareSize = 180.0
    
    let halfDiagonal = sqrt(2 * squareSize * squareSize) / 2
    let angleRange = 45.0
    let anglePrecision = 2.0
    public static let phi = (-1.0 + sqrt(5.0)) / 2          // golden ratio
    
    public var centroid = CGPoint(x: 0, y: 0)
    public var boundingBox = Rectangle(x: 0, y: 0, width: 0, heihgt: 0)
    
    var bounds = [0, 0, 0, 0]
    
    var Templates = [Template]()
    var RawTemplates = [[CGPoint]]()
    
    init() {
        for index in 0...2 {
            Templates.append(loadTemplate(array: TemplateData.DataRight[index]))
        }
    }
    
    private func loadTemplate(array: [Double]) -> Template {
        return Template(points: loadArray(array: array))
    }
    
    private func loadArray(array: [Double]) -> [CGPoint] {
        var arr = [CGPoint]()
        for index in 0...(array.count - 1) {
            if (index % 2 == 0) {
                let element = CGPoint(x: array[index], y: array[index + 1])
                arr.append(element)
            }
        }
        RawTemplates.append(arr)
        return arr
    }
    
    public func Recognize(points: [CGPoint]) -> Result {
        var listPoints = Utils.Resample(points: points, n: Recognizer.numPoints)
        listPoints = Utils.ScaleToSquare(points: listPoints, size: Recognizer.squareSize)
        listPoints = Utils.TranslateToOrigin(points: listPoints)
        
        bounds[0] = Int(boundingBox.x)
        bounds[1] = Int(boundingBox.y)
        bounds[2] = Int(boundingBox.x + boundingBox.width)
        bounds[3] = Int(boundingBox.y + boundingBox.height)
        
        var defaultIndex = 0
        
        var greateMag = Double.greatestFiniteMagnitude
        for index in 0...Templates.count-1 {
            let dist = Utils.DistanceAtBestAngle(points: listPoints, T: Templates[index], a: -angleRange, b: angleRange, threshold: anglePrecision)
            if (dist < greateMag) {
                greateMag = dist
                defaultIndex = index
            }
        }
        let score = 1.0 - (greateMag / halfDiagonal)
        return Result(index: Int(score), score: Double(defaultIndex), theta: Utils.lastTheta)
    }
    
    public func predict(points: [CGPoint]) -> [Result] {
        var answer = [Result]()
        var length = 0.0
        for index in 1...points.count-1 {
            length += Utils.Distance(p1: points[index - 1], p2: points[index])
        }
        if (length == 0) {
            for index in 0...RawTemplates.count-1 {
                answer.append(Result(index: index, score: 1, theta: Utils.lastTheta))
            }
            return answer
        }
        for index in 0...RawTemplates.count-1 {
            var l = 0.0
            var currTemp = [CGPoint]()
            currTemp.append(contentsOf: points)
            var val = 0
            while (l < length && (val + 1) < RawTemplates[index].count) {
                l += Utils.Distance(p1: RawTemplates[index][val], p2: RawTemplates[index][index + 1])
                val += 1
            }
            if (length == 0) {
                return answer
            }
            let deltaX = RawTemplates[index][val - 1].x - points[points.count - 1].x
            let deltaY = RawTemplates[index][val - 1].y - points[points.count - 1].y
            for element in val...RawTemplates[index].count-1 {
                var el = RawTemplates[index][element]
                el.x -= deltaX
                el.y -= deltaY
                currTemp.append(el)
            }
            currTemp = Utils.Resample(points: currTemp, n: Recognizer.numPoints)
            currTemp = Utils.ScaleToSquare(points: currTemp, size: Recognizer.squareSize)
            currTemp = Utils.TranslateToOrigin(points: currTemp)
            bounds[0] = Int(boundingBox.x)
            bounds[1] = Int(boundingBox.y)
            bounds[2] = Int(boundingBox.x + boundingBox.width)
            bounds[3] = Int(boundingBox.y + boundingBox.height)
            
            let dis = Utils.DistanceAtBestAngle(points: currTemp, T: Templates[index], a: -angleRange, b: angleRange, threshold: anglePrecision)
            let score = 1.0 - (dis / halfDiagonal)
            if (score > 0.8) {
                answer.append(Result(index: index, score: score, theta: Utils.lastTheta))
            }
        }
        return answer
    }
}
