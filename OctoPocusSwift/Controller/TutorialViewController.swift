//
//  TutorialViewController.swift
//  OctoPocusSwift
//
//  Created by urjhams on 6/15/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    @IBOutlet weak var imgCanvas: UIImageView!
    
    var lastTouch = CGPoint.zero
    var lastPoint: CGPoint?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchNumberOne = touches.first {
            self.lastTouch = touchNumberOne.location(in: view)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchNumberOne = touches.first {
            let touchLocation = touchNumberOne.location(in: view)
            self.lastPoint = touchLocation
            print("\(lastPoint ?? CGPoint(x: 0, y: 0))\n")
            drawLine(from: self.lastTouch, to: touchLocation)
            self.lastTouch = touchLocation
        }
    }
    private func drawLine(from start: CGPoint, to end: CGPoint) {
        UIGraphicsBeginImageContext(imgCanvas.frame.size)
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: start.x, y: start.y))
        context?.addLine(to: CGPoint(x: end.x, y: end.y))
        context?.setLineCap(.round)
        context?.setLineWidth(25)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.strokePath()
        self.imgCanvas.image?.draw(in: view.frame)
        imgCanvas.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
}
