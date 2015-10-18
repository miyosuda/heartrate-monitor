//
//  HRVUtils.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/10/19.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation

class HRVUtils {

	static func calcAVNN(intervals: [Double]) -> Double {
		var sum = 0.0
		for interval in intervals {			
			sum += interval
		}

		let size = intervals.count		
		return sum / Double(size);
	}

	static func calcSDNN(intervals: [Double]) -> Double {
		let average = calcAVNN(intervals)
		var d = 0.0
		
		for interval in intervals {
			let v = interval - average
			d += (v * v)
		}

		let size = intervals.count		
		return sqrt(d / Double(size))
	}

	static func calcRMSSD(intervals: [Double]) -> Double {
		var d = 0.0

		let size = intervals.count
		for var i = 0; i < size - 1; ++i {
			let interval0 = intervals[i]
			let interval1 = intervals[i + 1]
			let diff = interval1 - interval0
			d += (diff * diff)
		}

		return sqrt(d / Double(size - 1))
	}

	static func calcPNN50(intervals: [Double]) -> Double {
		var count: Int = 0

		let size = intervals.count
		for var i = 0; i < size - 1; ++i {
			let interval0 = intervals[i]
			let interval1 = intervals[i + 1]
			var diff = interval1 - interval0
			if diff < 0.0 {
				diff = -diff
			}

			if diff > 50.0 {
				// greater than 50ms
				count++
			}
		}

		return Double(count) / Double(size) * 100.0
	}

}
