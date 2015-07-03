//
//  ViewController.swift
//  standblue
//
//  Created by kosuke miyoshi on 2015/07/02.
//  Copyright (c) 2015年 narrative nigths. All rights reserved.
//

import Cocoa

class ViewController: NSViewController{
	var heartRateCenter : HeartRateCenter = HeartRateCenter()

	override func viewDidLoad() {
		super.viewDidLoad()

		heartRateCenter.setup()
	}

	override func viewWillDisappear() {
		println("viewWillDisappear")

		heartRateCenter.cleanup()
	}

	override var representedObject: AnyObject? {
		didSet {
		}
	}

}

