//
//  ViewController.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/07/02.
//  Copyright (c) 2015年 narrative nigths. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, HeartRateDelegate {
	@IBOutlet weak var startButton: NSButton!
	@IBOutlet weak var loadButton: NSButton!

	@IBOutlet weak var stateLabel: NSTextField!
	@IBOutlet weak var heartRateRRCountLabel: NSTextField!
	@IBOutlet weak var heartRateValueLabel: NSTextField!
	@IBOutlet weak var durationLabel: NSTextField!

	@IBOutlet weak var avnnLabel: NSTextField!
	@IBOutlet weak var sdnnLabel: NSTextField!
	@IBOutlet weak var rmssdLabel: NSTextField!
	@IBOutlet weak var pnn50Label: NSTextField!

    @IBOutlet weak var lfLabel: NSTextField!
    @IBOutlet weak var hfLabel: NSTextField!
    @IBOutlet weak var lfhfLabel: NSTextField!
    
	@IBOutlet weak var spectrumGraphView: SpectrumGraphView!

    @IBOutlet weak var breathView: BreathView!

	var heartRateCenter: HeartRateCenter!
	var heartRateRRIntervalDatas: [Double]!
	var heartRateRRCount = 0;
	var duration = 0.0;

	override func viewDidLoad() {
		super.viewDidLoad()

		stateLabel.stringValue = "init"
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		view.window!.title = "Heart rate monitor"

		breathView.prepare()
	}

	override func viewWillDisappear() {
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
			breathView.start()

			heartRateCenter = HeartRateCenter(delegate: self)
			heartRateCenter.setup()

			stateLabel.stringValue = "connecting"

			heartRateRRIntervalDatas = [Double]()
			heartRateRRCount = 0;
			duration = 0.0

			startButton.title = "Stop"
			loadButton.hidden = true

		} else {
			breathView.stop()

			heartRateCenter.cleanup()
			heartRateCenter = nil
			startButton.title = "Start"
			loadButton.hidden = false

			stateLabel.stringValue = "init"

			analyzeIntervals()

			saveData()
		}
	}

	@IBAction func onLoadButtonPushed(sender: AnyObject) {
		chooseLoadData()
	}

	func analyzeIntervals() {
		let avnn = HRVUtils.calcAVNN(heartRateRRIntervalDatas)
		let sdnn = HRVUtils.calcSDNN(heartRateRRIntervalDatas)
		let rmssd = HRVUtils.calcRMSSD(heartRateRRIntervalDatas)
		let pnn50 = HRVUtils.calcPNN50(heartRateRRIntervalDatas)

		avnnLabel.stringValue = String(format: "%.2f", avnn)
		sdnnLabel.stringValue = String(format: "%.2f", sdnn)
		rmssdLabel.stringValue = String(format: "%.2f", rmssd)
		pnn50Label.stringValue = String(format: "%.2f", pnn50)

		let copiedHeartRateRRIntervalDatas = heartRateRRIntervalDatas

		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		dispatch_async(queue) {
			let spectrumData = SpectrumAnalyzer.process(copiedHeartRateRRIntervalDatas)
			if (spectrumData != nil) {
				dispatch_async(dispatch_get_main_queue()) {
					self.showSpectrumGraph(spectrumData!)

                    let lf = spectrumData!.lf
                    let hf = spectrumData!.hf
                    let lfhf = lf/hf
                    self.lfLabel.stringValue = String(format: "%.3f", lf)
                    self.hfLabel.stringValue = String(format: "%.3f", hf)
                    self.lfhfLabel.stringValue = String(format: "%.3f", lfhf)
				}
			}
		}
	}

	func showSpectrumGraph(spectrumData: SpectrumData) {
		spectrumGraphView.setSpectrumData(spectrumData)
	}

	func chooseLoadData() {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canCreateDirectories = false
		panel.canChooseFiles = true
		panel.allowedFileTypes = ["txt"]
		panel.beginWithCompletionHandler {
			(result) -> Void in
			if result == NSFileHandlingPanelOKButton {
				self.loadData(panel.URL)
			}
		}
	}

	func loadData(url: NSURL?) {
		if url == nil {
			return
		}

		let path = url!.path!

		var data: String? = nil
		do {
			try data = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
		} catch let err as NSError {
			print("write to file failed: " + err.localizedDescription)
		}

		if data == nil {
			return
		}

		var intervals: [Double] = []
		data!.enumerateLines {
			(line, stop) -> () in
			let interval = atof(line)
			intervals.append(interval)
		}

		heartRateRRIntervalDatas = intervals

		analyzeIntervals()
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
			panel.nameFieldStringValue = String(format: "rr_\(dateStr).txt")

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
