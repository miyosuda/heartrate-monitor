//
//  BreathView.swift
//  heartrate-monitor
//
//  Created by Kosuke Miyoshi on 2015/11/28.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation
import AppKit

class BreathView: NSView {
	fileprivate let UPDATE_INTERVAL_SEC: Double = 0.05
	fileprivate let BREATH_INTERVAL_SEC: Double = 4.0

	fileprivate var timer: Timer!
	fileprivate var startDate: Date!

	override func draw(_ rect: CGRect) {
		super.draw(rect)

		if timer == nil {
			return
		}

		let width = frame.width
		let height = frame.height

		let time = Date().timeIntervalSince(startDate!)
		let phase = (time / BREATH_INTERVAL_SEC) * M_PI * 2.0
		let rate = (CGFloat)(1.0 - ((1.0 + cos(phase)) * 0.5))

		let rect = NSMakeRect(0, 0, width, height * rate)
		NSColor.white.set()
		NSRectFill(rect)

		let frameRect = NSMakeRect(0, 0, width, height)
		NSColor.black.set()
		NSFrameRect(frameRect)
	}

	func onUpdate() {
		needsDisplay = true
	}

	func prepare() {
		isHidden = true
	}

	func start() {
		startDate = Date()

		timer = Timer.scheduledTimer(timeInterval: UPDATE_INTERVAL_SEC,
				target: self,
				selector: #selector(BreathView.onUpdate),
				userInfo: nil,
				repeats: true)

		isHidden = false
	}

	func stop() {
		isHidden = true

		if timer != nil {
			timer.invalidate()
			timer = nil
		}
	}
}
