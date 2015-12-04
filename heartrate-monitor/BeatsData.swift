//
//  BeatsData.swift
//  heartrate-monitor
//
//  Created by Kosuke Miyoshi on 2015/12/04.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation

struct Beat {
	/// time in msec
	var time: Double

	// interval in msec
	var interval: Double
}

class BeatsData {
	var beats: [Beat]

	init(intervals: [Double]) {
		beats = [];
		let intervalSize = intervals.count

		if intervalSize < 1 {
			return
		}

		var time = 0.0
		var interval = intervals[0]

		for var i = 0; i < intervalSize; ++i {
			let beat = Beat(time: time, interval: interval)
			beats.append(beat)

			if i < intervalSize - 1 {
				let nextInterval = intervals[i + 1]
				time += nextInterval
				interval = nextInterval
			}
		}
	}
    
    var isValid : Bool {
        return beats.count > 0
    }
}
