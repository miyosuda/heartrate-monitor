//
//  LogSpectrumData.swift
//  heartrate-monitor
//
//  Created by Kosuke Miyoshi on 2016/01/28.
//  Copyright © 2016年 narrative nigths. All rights reserved.
//

import Foundation
import Darwin

struct LogSpectrumPoint {
	var logFrequency: Double
	var logPsd: Double
}

struct LogSpectrumData {
	var points: [LogSpectrumPoint]
	
	var pointCount: Int {
		get {
			return points.count
		}
	}
	
	var minLogPsd: Double {
		get {
			var min = DBL_MAX
			
			for point in points {
				if point.logPsd < min {
					min = point.logPsd
				}
			}
			return min
		}
	}
	
	var maxLogPsd: Double {
		get {
			var max = DBL_MIN
			
			for point in points {
				if point.logPsd > max {
					max = point.logPsd
				}
			}
			return max
		}
	}
	
	var maxLogFreq: Double {
		return points[points.count - 1].logFrequency
	}
	
	var minLogFreq: Double {
		return points[0].logFrequency
	}
	
	func calcSlope() -> (Double, Double) {
		var ux = 0.0
		var uy = 0.0
		var exy = 0.0

		for point in points {
			let x = point.logFrequency
			let y = point.logPsd
			ux += x
			uy += y
			exy += (x * y)
		}
		
		let pointCount = points.count
		
		ux /= Double(pointCount)
		uy /= Double(pointCount)
		exy /= Double(pointCount)
		
		let covxy = exy - ux * uy
		
		var sigmaX2 = 0.0
		
		for point in points {
			let x = point.logFrequency
			let dx = x - ux
			sigmaX2 += (dx * dx)
		}
		
		sigmaX2 /= Double(pointCount)

		// Slope
		let a = (covxy / sigmaX2)

		// Y axis intecept
		let b = uy - a * ux
		return (a, b)
	}
}
