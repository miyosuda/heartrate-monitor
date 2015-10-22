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

	private func drawGrid() {
		let pointCount = spectrumData.pointCount
		let maxPsd = spectrumData.maxPsd
		let maxFreq = spectrumData.maxFreq
        
        let width = Double(frame.width)
        let height = Double(frame.height)

		let gridColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
		gridColor.set()

		let scaleX = width / maxFreq
        let scaleY = height / maxPsd

		for (var x = 0.0; x <= maxFreq; x += 0.05) {
			// vertical line
			let path: NSBezierPath = NSBezierPath()
            path.lineWidth = 0.2
			let px: Double = x * scaleX
			path.moveToPoint(NSPoint(x: px, y: 0.0))
			path.lineToPoint(NSPoint(x: px, y: height))
			path.stroke()
		}
        
        for (var y = 0.0; y <= maxPsd; y += 10.0) {
            // horizontal line
            let path: NSBezierPath = NSBezierPath()
            path.lineWidth = 0.2
            let py: Double = y * scaleY
            path.moveToPoint(NSPoint(x: 0.0, y: py))
            path.lineToPoint(NSPoint(x: width, y: py))
            path.stroke()
        }
        
        let lineColor = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        lineColor.set()
        
        var px = spectrumData.points[0].frequency * scaleX
        var py = spectrumData.points[0].psd * scaleY
        
        let path: NSBezierPath = NSBezierPath()
        path.lineWidth = 0.3
        path.moveToPoint(NSPoint(x: px, y: py))
        
        for var i=1; i<pointCount; ++i {
            px = spectrumData.points[i].frequency * scaleX
            py = spectrumData.points[i].psd * scaleY
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