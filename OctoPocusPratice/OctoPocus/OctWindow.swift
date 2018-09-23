//
//  OctWindow.swift
//  OctoPocusPratice
//
//  Created by urjhams on 8/27/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit

class OctWindow: UIWindow {
    var view: OctView!
    
    public func setOctView(view: OctView) {
        self.view = view
        self.addSubview(view)
    }
    
    override public func sendEvent(_ event: UIEvent) {
        if event.type == .touches {
            if let count = event.allTouches?.filter({ $0.phase == .began }).count, count > 0 {
                view.touchesBegan(event.allTouches!)
                super.sendEvent(event)
            }
            if let count = event.allTouches?.filter({ $0.phase == .moved }).count, count > 0 {
                view.touchesMoved(event.allTouches!)
                if (!view.forceTouch){
                    super.sendEvent(event)
                }
            }
            if let count = event.allTouches?.filter({ $0.phase == .ended }).count, count > 0 {
                view.touchesEnded(event.allTouches!)
                super.sendEvent(event)
            }
            if let count = event.allTouches?.filter({ $0.phase == .cancelled }).count, count > 0 {
                super.sendEvent(event)
            }
        }
    }

}
