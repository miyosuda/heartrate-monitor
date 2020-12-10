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
	@IBOutlet weak var balanceIndexLabel: NSTextField!

	@IBOutlet weak var graphTabView: NSTabView!
	@IBOutlet weak var spectrumGraphView: SpectrumGraphView!
	@IBOutlet weak var balanceIndexGraphView: BalanceIndexGraphView!

	@IBOutlet weak var breathView: BreathView!

	var heartRateCenter: HeartRateCenter!
	var heartRateRRIntervalDatas: [Double]!
	var heartRateRRCount = 0;
	var duration = 0.0;

	override func viewDidLoad() {
		super.viewDidLoad()

		stateLabel.stringValue = "init"
		graphTabView.isHidden = true
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		view.window!.title = "Heart rate monitor"

        // hide breath view
		breathView.prepare()
	}

	override func viewWillDisappear() {
		if heartRateCenter != nil {
			heartRateCenter.cleanup()
			heartRateCenter = nil
		}
	}

	@IBAction func onStartButtonPushed(_ sender: AnyObject) {
		if (heartRateCenter == nil) {
			breathView.isHidden = false
			graphTabView.isHidden = true
			breathView.start()

            // show breath view
			heartRateCenter = HeartRateCenter(delegate: self)
			heartRateCenter.setup()

			stateLabel.stringValue = "connecting"

			heartRateRRIntervalDatas = [Double]()
			heartRateRRCount = 0;
			duration = 0.0

			startButton.title = "Stop"
			loadButton.isHidden = true

		} else {
			breathView.isHidden = true
			graphTabView.isHidden = false
			breathView.stop()

			heartRateCenter.cleanup()
			heartRateCenter = nil
			startButton.title = "Start"
			loadButton.isHidden = false

			stateLabel.stringValue = "init"

			analyzeIntervals()

			saveData()
		}
	}

	@IBAction func onLoadButtonPushed(_ sender: AnyObject) {
		chooseLoadData()
	}

	func analyzeIntervals() {
		graphTabView.isHidden = false

		let beatsData = BeatsData(intervals: heartRateRRIntervalDatas)
		beatsData.removeIrregularBeats()

		if !beatsData.isValid {
			return
		}

		let avnn = beatsData.avnn
		let sdnn = beatsData.sdnn
		let rmssd = beatsData.rmssd
		let pnn50 = beatsData.pnn50

		avnnLabel.stringValue = String(format: "%.2f", avnn)
		sdnnLabel.stringValue = String(format: "%.2f", sdnn)
		rmssdLabel.stringValue = String(format: "%.2f", rmssd)
		pnn50Label.stringValue = String(format: "%.2f", pnn50)

        let concurrentQueue = DispatchQueue(label: "spectrum-analysis", attributes: .concurrent)
        concurrentQueue.async {
			// Resample intervals with Const.RESMPLE_INTERAL_MS millisec interval.
			let resampledIntervals = SampleInterpolator.process(beatsData.beats)
			if resampledIntervals == nil {
				return
			}

			// AR spectrum analysis
			let spectrumData = SpectrumAnalyzer.process(resampledIntervals!)
			if (spectrumData != nil) {
				DispatchQueue.main.async {
					self.showSpectrumGraph(spectrumData!)

					let lf = spectrumData!.lf
					let hf = spectrumData!.hf
					let lfhf = lf / hf
					self.lfLabel.stringValue = String(format: "%.3f", lf)
					self.hfLabel.stringValue = String(format: "%.3f", hf)
					self.lfhfLabel.stringValue = String(format: "%.3f", lfhf)
				}
			}

			// BalanceIndex analysis
			let logSpectrumData = BalanceIndexAnalyzer.process(resampledIntervals: resampledIntervals!)
			let (a, _ ) = logSpectrumData.calcSlope()
			let balanceIndex = -a

			DispatchQueue.main.async {
				self.showBalanceIndexGraph(logSpectrumData: logSpectrumData)
				self.balanceIndexLabel.stringValue = String(format: "%.3f", balanceIndex)
			}

		}
	}

	func showSpectrumGraph(_ spectrumData: SpectrumData) {
		spectrumGraphView.setSpectrumData(spectrumData)
	}

	func showBalanceIndexGraph(logSpectrumData: LogSpectrumData) {
		balanceIndexGraphView.setLogSpectrumData(logSpectrumData: logSpectrumData)
	}

	func chooseLoadData() {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canCreateDirectories = false
		panel.canChooseFiles = true
		panel.allowedFileTypes = ["txt"]
		panel.begin {
			(result) -> Void in
            if result == NSApplication.ModalResponse.OK {
				self.loadData(panel.url)
			}
		}
	}

	func loadData(_ url: URL?) {
		if url == nil {
			return
		}

		let path = url!.path

		var data: String? = nil
		do {
			try data = NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
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
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier: "en_US")
			dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
			let now = Date()
			let dateStr = dateFormatter.string(from: now)
			panel.nameFieldStringValue = String(format: "rr_\(dateStr).txt")

			// show save dialog
			panel.begin(completionHandler: {
				(result: NSApplication.ModalResponse) -> Void in
				if result == NSApplication.ModalResponse.OK {
					let saveURL = panel.url
					if (saveURL != nil) {
                        print("save url=\(String(describing: saveURL))")
						self.saveRRIntervalData(saveURL!)
					}
				}
			})
		}
	}

	func saveRRIntervalData(_ url: URL) {
		let path = url.path

		// rr msec interval
		var content = ""
		for rr in heartRateRRIntervalDatas {
			content += (String("\(rr)") + "\n")
		}

		do {
			try content.write(toFile: path, atomically: false, encoding: String.Encoding.utf8);
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

	func heartRateRRDidArrive(_ rr: Double) {
		print("<rr=\(rr)>")
		heartRateRRIntervalDatas.append(rr);

		duration += (rr / 1000.0);

		heartRateRRCount += 1;
		heartRateRRCountLabel.stringValue = String("\(heartRateRRCount)")
		let heartRateValue = 60.0 * 1000.0 / rr;
		heartRateValueLabel.stringValue = String(format: "%.2f", heartRateValue)
		durationLabel.stringValue = String(format: "%.1f sec", duration)
	}
}
