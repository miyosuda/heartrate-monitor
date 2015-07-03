//
//  ViewController.swift
//  standblue
//
//  Created by kosuke miyoshi on 2015/07/02.
//  Copyright (c) 2015年 narrative nigths. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, HeartRateDelegate {
	@IBOutlet weak var startButton: NSButtonCell!

	var heartRateCenter: HeartRateCenter!

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillDisappear() {
		println("viewWillDisappear")

		if heartRateCenter != nil {
			heartRateCenter.cleanup()
			heartRateCenter = nil
		}
	}

	override var representedObject: AnyObject? {
		didSet {
		}
	}

	@IBAction func onStartButtonPushed(sender: AnyObject) {
		if (heartRateCenter == nil) {
			heartRateCenter = HeartRateCenter(delegate: self)
			heartRateCenter.setup()
			startButton.title = "Stop"
		} else {
			heartRateCenter.cleanup()
			heartRateCenter = nil
			startButton.title = "Start"
		}
	}

	func heartRateDeviceDidConnect() {
        println("<connect>")
	}

	func heartRateDeviceDidDisconnect() {
        println("<disconnect>")
	}

	func heartRateRRDidArrive(rr: Double) {
        println("<rr=\(rr)>")
	}
}
