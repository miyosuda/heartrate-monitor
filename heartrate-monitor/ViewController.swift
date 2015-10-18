//
//  ViewController.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/07/02.
//  Copyright (c) 2015年 narrative nigths. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, HeartRateDelegate {
	@IBOutlet weak var startButton: NSButtonCell!

	@IBOutlet weak var stateLabel: NSTextField!
	@IBOutlet weak var heartRateRRCountLabel: NSTextField!
	@IBOutlet weak var heartRateValueLabel: NSTextField!
	@IBOutlet weak var durationLabel: NSTextField!

	var heartRateCenter: HeartRateCenter!
	var heartRateRRIntervalDatas: [Double]!
	var heartRateRRCount = 0;
	var duration = 0.0;

	override func viewDidLoad() {
		super.viewDidLoad()

		stateLabel.stringValue = "init"
	}

	override func viewWillDisappear() {
		print("viewWillDisappear")

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

			stateLabel.stringValue = "connecting"

			heartRateRRIntervalDatas = [Double]()
            heartRateRRCount = 0;
            duration = 0.0

			startButton.title = "Stop"
		} else {
			heartRateCenter.cleanup()
			heartRateCenter = nil
			startButton.title = "Start"

			stateLabel.stringValue = "init"

			saveData()
		}
	}

	func saveData() {
		if heartRateRRIntervalDatas.count > 0 {
			let panel = NSSavePanel()
			panel.nameFieldLabel = "File Name"

            // set default filename
			let dateFormatter = NSDateFormatter()
			dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
			dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let now = NSDate()
			let dateStr = dateFormatter.stringFromDate(now)
            panel.nameFieldStringValue = String(format:"rr_\(dateStr).txt")

            // show save dialog
			panel.beginWithCompletionHandler({
				(result: Int) -> Void in
				if result == NSFileHandlingPanelOKButton {
					let saveURL = panel.URL
					if (saveURL != nil) {
						print("save url=\(saveURL)")
						self.saveRRIntervalData(saveURL!)
					}
				}
			})
		}
	}

	func saveRRIntervalData(url: NSURL) {
		let path = url.path!
        
        // rr msec interval
        var content = ""
        for rr in heartRateRRIntervalDatas {
            content += (String("\(rr)") + "\n")
        }
        
        do {
            try content.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding);
        } catch let err as NSError {
             print("write to file failed: " + err.localizedDescription)
        }
	}


	func heartRateDeviceDidConnect() {
		print("<connect>")
		stateLabel.stringValue = "connected"
	}

	func heartRateDeviceDidDisconnect() {
		print("<disconnect>")
		stateLabel.stringValue = "disconnected"
	}

	func heartRateRRDidArrive(rr: Double) {
		print("<rr=\(rr)>")
		heartRateRRIntervalDatas.append(rr);

		duration += (rr / 1000.0);

		heartRateRRCount++;
		heartRateRRCountLabel.stringValue = String("\(heartRateRRCount)")
		let heartRateValue = 60.0 * 1000.0 / rr;
		heartRateValueLabel.stringValue = String(format: "%.2f", heartRateValue)
		durationLabel.stringValue = String(format: "%.1f sec", duration)
	}
}
