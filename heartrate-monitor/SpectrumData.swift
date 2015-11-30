//
//  SpectrumData.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/10/23.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation

struct SpectrumPoint {
	var frequency: Double
	var psd: Double
}

struct SpectrumData {
	var points: [SpectrumPoint]

	var pointCount: Int {
		get {
			return points.count
		}
	}

	var maxPsd: Double {
		get {
			var maxPsd = 0.0

			for point in points {
				if point.psd > maxPsd {
					maxPsd = point.psd
				}
			}
			return maxPsd
		}
	}

	var maxFreq: Double {
		return points[points.count - 1].frequency
	}

	// Calc LF (0.04Hz ~ 0.15Hz) power sum
	var lf: Double {
		get {
			if points.count < 2 {
				return 0.0
			}

			let df = points[1].frequency - points[0].frequency
			var ret: Double = 0.0
			for point in points {
				if point.frequency >= Constants.MIN_LF && point.frequency < Constants.MAX_LF {
					ret += (point.psd * df)
				}
				if point.frequency >= Constants.MAX_LF {
					break
				}
			}
			return ret
		}
	}

	// Calc HF (0.15Hz ~ 0.4Hz) power sum
	var hf: Double {
		get {
			if points.count < 2 {
				return 0.0
			}

			let df = points[1].frequency - points[0].frequency
			var ret: Double = 0.0
			for point in points {
				if point.frequency >= Constants.MIN_HF && point.frequency < Constants.MAX_HF {
					ret += (point.psd * df)
				}
				if point.frequency >= Constants.MAX_HF {
					break
				}
			}
			return ret
		}
	}
}

