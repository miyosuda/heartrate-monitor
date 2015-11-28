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
	private let UPDATE_INTERVAL_SEC: Double = 0.05
	private let BREATH_INTERVAL_SEC: Double = 4.0

	private var timer: NSTimer!
	private var startDate: NSDate!

	override func drawRect(rect: CGRect) {
		super.drawRect(rect)

		if timer == nil {
			return
		}

		let width = frame.width
		let height = frame.height

		let time = NSDate().timeIntervalSinceDate(startDate!)
		let phase = (time / BREATH_INTERVAL_SEC) * M_PI * 2.0
		let rate = (CGFloat)(1.0 - ((1.0 + cos(phase)) * 0.5))

		let rect = NSMakeRect(0, 0, width, height * rate)
		NSColor.whiteColor().set()
		NSRectFill(rect)

		let frameRect = NSMakeRect(0, 0, width, height)
		NSColor.blackColor().set()
		NSFrameRect(frameRect)
	}

	func onUpdate() {
		needsDisplay = true
	}

	func prepare() {
		hidden = true
	}

	func start() {
		startDate = NSDate()

		timer = NSTimer.scheduledTimerWithTimeInterval(UPDATE_INTERVAL_SEC,
				target: self,
				selector: Selector("onUpdate"),
				userInfo: nil,
				repeats: true)

		hidden = false
	}

	func stop() {
		hidden = true

		if timer != nil {
			timer.invalidate()
			timer = nil
		}
	}
}
