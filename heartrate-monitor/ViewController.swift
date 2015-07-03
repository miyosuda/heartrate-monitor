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
	var heartRateRRIntervalDatas: [Double]!

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

			heartRateRRIntervalDatas = [Double]()

			startButton.title = "Stop"
		} else {
			heartRateCenter.cleanup()
			heartRateCenter = nil
			startButton.title = "Start"

			saveData()
		}
	}

	func saveData() {
		if heartRateRRIntervalDatas.count > 0 {
			var panel = NSSavePanel()
            panel.nameFieldLabel = "File Name"
            panel.beginWithCompletionHandler( { (result:Int) -> Void in
                if result == NSFileHandlingPanelOKButton {
                    var saveURL = panel.URL
                    if( saveURL != nil ) {
                        println("save url=\(saveURL)")
                        self.saveRRIntervalData(saveURL!)
                    }
                }
            } )
        }
	}
    
    func saveRRIntervalData(url:NSURL) {
        let path = url.path!
        var content = ""
        for rr in heartRateRRIntervalDatas {
            content += (String("\(rr)") + "\n")
        }
        content.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
    }


	func heartRateDeviceDidConnect() {
		println("<connect>")
	}

	func heartRateDeviceDidDisconnect() {
		println("<disconnect>")
	}

	func heartRateRRDidArrive(rr: Double) {
		println("<rr=\(rr)>")
		heartRateRRIntervalDatas.append(rr);
	}
}
