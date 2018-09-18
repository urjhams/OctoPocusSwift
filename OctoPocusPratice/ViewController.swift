//
//  ViewController.swift
//  OctoPocusPratice
//
//  Created by urjhams on 8/27/18.
//  Copyright © 2018 urjhams. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let window = UIApplication.shared.keyWindow! as! OctWindow
        let view = OctView()
        view.gesturedHandler = { index in
            view.isUserInteractionEnabled = false
            let alert = UIAlertController(title: nil, message: view.names[index], preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: {
                view.isUserInteractionEnabled = true
            })
        }
        window.setOctView(view: view)
    }


}

