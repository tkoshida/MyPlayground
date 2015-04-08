//
//  ViewController.swift
//  MyPlayground
//
//  Created by Takayoshi Koshida on 2015/04/06.
//  Copyright (c) 2015年 tkoshida. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onCrashButton(sender: AnyObject) {
        abort()
    }
}

