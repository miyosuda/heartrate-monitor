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
}

