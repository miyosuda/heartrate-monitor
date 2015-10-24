//
//  SpectrumGraphView.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/10/23.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation
import AppKit

class SpectrumGraphView: NSView {
	var spectrumData: SpectrumData!

	func setSpectrumData(spectrumData: SpectrumData) {
		self.spectrumData = spectrumData
		needsDisplay = true
	}

	private func drawHorizontalGridValue(value: Double, x: Double, y: Double) {
		let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
		style.alignment = NSTextAlignment.Center
		let attr = [NSParagraphStyleAttributeName: style]
		let str = NSString(string: String(format: "%.1f", value))
		str.drawInRect(CGRectMake(CGFloat(x - 20.0), CGFloat(y - 20), 40.0, 40.0), withAttributes: attr)
	}

	private func drawString(str: String, x: Double, y: Double) {
		let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
		style.alignment = NSTextAlignment.Center
		let attr = [NSParagraphStyleAttributeName: style]
		str.drawInRect(CGRectMake(CGFloat(x - 50.0), CGFloat(y - 20), 100.0, 40.0), withAttributes: attr)
	}

	private func drawGrid() {
		let pointCount = spectrumData.pointCount
		let maxPsd = spectrumData.maxPsd
		let maxFreq = spectrumData.maxFreq

		let marginX = 35.0
		let marginY = 35.0

		let width = Double(frame.width) - 2.0 * marginX
		let height = Double(frame.height) - 2.0 * marginY

		let gridColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
		gridColor.set()

		let scaleX = width / maxFreq
		let scaleY = height / maxPsd

		var count = 0;
		for (var x = 0.0; x <= maxFreq + 0.01; x += 0.05) {
			// vertical line
			let path: NSBezierPath = NSBezierPath()
			path.lineWidth = 0.2
			let px: Double = x * scaleX + marginX
			path.moveToPoint(NSPoint(x: px, y: marginY))
			path.lineToPoint(NSPoint(x: px, y: marginY + height))
			path.stroke()

			if (count % 2 == 0) {
				drawHorizontalGridValue(x, x: px, y: 10.0)
			}
			count++
		}

		drawString("Frequency (Hz)", x: marginX + width * 0.5, y: -5.0)

		for (var y = 0.0; y <= maxPsd; y += 10.0) {
			// horizontal line
			let path: NSBezierPath = NSBezierPath()
			path.lineWidth = 0.2
			let py: Double = y * scaleY + marginY
			path.moveToPoint(NSPoint(x: marginX, y: py))
			path.lineToPoint(NSPoint(x: marginX + width, y: py))
			path.stroke()
		}

		let lineColor = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
		lineColor.set()

		var px = spectrumData.points[0].frequency * scaleX + marginX
		var py = spectrumData.points[0].psd * scaleY + marginY

		let path: NSBezierPath = NSBezierPath()
		path.lineWidth = 0.3
		path.moveToPoint(NSPoint(x: px, y: py))

		for var i = 1; i < pointCount; ++i {
			px = spectrumData.points[i].frequency * scaleX + marginX
			py = spectrumData.points[i].psd * scaleY + marginY
			path.lineToPoint(NSPoint(x: px, y: py))
			path.stroke()
		}
	}

	override func drawRect(rect: CGRect) {
		super.drawRect(rect)

		if spectrumData == nil {
			return
		}

		drawGrid()
	}
}