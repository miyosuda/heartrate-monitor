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
		// Trim spectrum data with limit of SPECTRUM_GRAPH_MAX_FREQ
		var trimedPoints = [SpectrumPoint]()
		for point in spectrumData.points {
			if point.frequency <= Constants.SPECTRUM_GRAPH_MAX_FREQ {
				trimedPoints.append(point)
			}
		}

		self.spectrumData = SpectrumData(points: trimedPoints)
		needsDisplay = true
	}

	private func drawHorizontalGridValue(value: Double, x: Double, y: Double) {
		let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
		style.alignment = NSTextAlignment.Center
		let attr = [NSParagraphStyleAttributeName: style]
		let str = NSString(string: String(format: "%.1f", value))
		str.drawInRect(CGRectMake(CGFloat(x - 20.0), CGFloat(y - 20), 40.0, 40.0), withAttributes: attr)
	}

	private func drawHorizontalString(str: String, x: Double, y: Double) {
		let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
		style.alignment = NSTextAlignment.Center
		let attr = [NSParagraphStyleAttributeName: style]
		str.drawInRect(CGRectMake(CGFloat(x - 50.0), CGFloat(y - 20), 100.0, 40.0), withAttributes: attr)
	}

	private func drawVerticalGridValue(value: Double, x: Double, y: Double) {
        var str:NSString! = nil
        if value > 1000.0 {
            str = NSString(string: String(format: "%.0fK", value/1000.0))
        } else {
            str = NSString(string: String(format: "%.0f", value))
        }
        
		drawVerticalString(String(str), x: x, y: y)
	}

	private func drawVerticalString(str: String, x: Double, y: Double) {
		let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
		style.alignment = NSTextAlignment.Right
		let attr = [NSParagraphStyleAttributeName: style]
		str.drawInRect(CGRectMake(CGFloat(x - 100.0), CGFloat(y) - 8, 100.0, 16.0), withAttributes: attr)
	}

	private func getGridUnit(maxValue: Double) -> Double {
		let d = maxValue / 10.0

		var base10 = 1.0
		var base = base10

		while true {
			if base10 >= d {
				base = base10
				break
			}
			let base25 = base10 * 2.5
			if base25 >= d {
				base = base25
				break
			}

			let base50 = base10 * 5.0
			if base50 >= d {
				base = base50
				break
			}
			base10 *= 10.0
		}
		return base
	}

	private func drawGrid() {
		let pointCount = spectrumData.pointCount
		let maxPsd = spectrumData.maxPsd
		let maxFreq = spectrumData.maxFreq

		let marginX = 60.0
		let marginY = 40.0

		let width = Double(frame.width) - 2.0 * marginX
		let height = Double(frame.height) - 2.0 * marginY

		let gridColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
		gridColor.set()

		let scaleX = width / maxFreq
		let scaleY = height / maxPsd

		// Fill Spectrum LF/HF part
		let lowFreqColor = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
		let highFreqColor = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
		lowFreqColor.set()

		for var i = 0; i < pointCount - 1; ++i {
			if spectrumData.points[i].frequency < Constants.MIN_LF {
				continue
			} else if spectrumData.points[i + 1].frequency > Constants.MAX_HF {
				continue
			} else if spectrumData.points[i + 1].frequency > Constants.MIN_HF {
				highFreqColor.set()
			} else {
				lowFreqColor.set()
			}

			let px0 = spectrumData.points[i].frequency * scaleX + marginX
			let py0 = spectrumData.points[i].psd * scaleY + marginY

			let px1 = spectrumData.points[i + 1].frequency * scaleX + marginX
			let py1 = spectrumData.points[i + 1].psd * scaleY + marginY

			let path: NSBezierPath = NSBezierPath()
			path.moveToPoint(NSPoint(x: px0, y: py0))
			path.lineToPoint(NSPoint(x: px1, y: py1))
			path.lineToPoint(NSPoint(x: px1, y: marginY))
			path.lineToPoint(NSPoint(x: px0, y: marginY))
			path.fill()
		}

		// Grid X axis
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

		// Grid X Label
		drawHorizontalString("Frequency (Hz)", x: marginX + width * 0.5, y: -5.0)

		// Grid Y axis
		count = 0
		let gridUnitY = getGridUnit(maxPsd)
        
		for (var y = 0.0; y <= maxPsd; y += gridUnitY) {
			// horizontal line
			let path: NSBezierPath = NSBezierPath()
			path.lineWidth = 0.2
			let py: Double = y * scaleY + marginY
			path.moveToPoint(NSPoint(x: marginX, y: py))
			path.lineToPoint(NSPoint(x: marginX + width, y: py))
			path.stroke()

			if count % 2 == 0 {
				drawVerticalGridValue(y, x: 50, y: py)
			}
			count++
		}

		// Y Label
		drawVerticalString("PSD", x: 25, y: marginY + height * 0.5)

		// Spectrum Graph line
		let lineColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
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