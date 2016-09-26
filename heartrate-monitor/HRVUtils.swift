//
//  HRVUtils.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/10/19.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation

class HRVUtils {

	static func calcAVNN(_ intervals: [Double]) -> Double {
		var sum = 0.0
		for interval in intervals {			
			sum += interval
		}

		let size = intervals.count		
		return sum / Double(size);
	}

	static func calcSDNN(_ intervals: [Double]) -> Double {
		let average = calcAVNN(intervals)
		var d = 0.0
		
		for interval in intervals {
			let v = interval - average
			d += (v * v)
		}

		let size = intervals.count		
		return sqrt(d / Double(size))
	}

	static func calcRMSSD(_ intervals: [Double]) -> Double {
		var d = 0.0

		let size = intervals.count
		for i in 0 ..< size - 1 {
			let interval0 = intervals[i]
			let interval1 = intervals[i + 1]
			let diff = interval1 - interval0
			d += (diff * diff)
		}

		return sqrt(d / Double(size - 1))
	}

	static func calcPNN50(_ intervals: [Double]) -> Double {
		var count: Int = 0

		let size = intervals.count
		for i in 0 ..< size - 1 {
			let interval0 = intervals[i]
			let interval1 = intervals[i + 1]
			var diff = interval1 - interval0
			if diff < 0.0 {
				diff = -diff
			}

			if diff > 50.0 {
				// greater than 50ms
				count += 1
			}
		}

		return Double(count) / Double(size) * 100.0
	}

}
