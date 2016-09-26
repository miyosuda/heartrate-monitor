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
	private let REGULAR_BEAT_INTERVAL_DIFF_RATE = 0.2

	var beats: [Beat]

	init(intervals: [Double]) {
		beats = [];
		let intervalSize = intervals.count

		if intervalSize < 1 {
			return
		}

		var time = 0.0
		var interval = intervals[0]

		for i in 0 ..< intervalSize {
			let beat = Beat(time: time, interval: interval)
			beats.append(beat)

			if i < intervalSize - 1 {
				let nextInterval = intervals[i + 1]
				time += nextInterval
				interval = nextInterval
			}
		}
	}

	var isValid: Bool {
		return beats.count > 0
	}

	func removeIrregularBeats() {
		if !isValid {
			return
		}

		var newBeats: [Beat] = []

		let size = beats.count

		var lastBeat = beats[0]
		newBeats.append(lastBeat)

		var removedBeatCount = 0

		for  i in  1 ..< size {
			let beat = beats[i]
			let rate = beat.interval / lastBeat.interval
			if rate >= (1.0 - REGULAR_BEAT_INTERVAL_DIFF_RATE) && rate <= (1.0 + REGULAR_BEAT_INTERVAL_DIFF_RATE) {
				newBeats.append(beat)
			} else {
				removedBeatCount += 1
			}
			lastBeat = beat
		}

		print("irregular beat removed: \(removedBeatCount)")

		beats = newBeats
	}

	var avnn: Double {
		get {
			var sum = 0.0
			for beat in beats {
				sum += beat.interval
			}

			let size = beats.count
			return sum / Double(size);
		}
	}

	var sdnn: Double {
		get {
			let average = avnn
			var d = 0.0

			for beat in beats {
				let v = beat.interval - average
				d += (v * v)
			}

			let size = beats.count
			return sqrt(d / Double(size))
		}
	}

	var rmssd: Double {
		get {
			var d = 0.0

			let size = beats.count

			for i in 0 ..< size - 1 {
				let interval0 = beats[i].interval
				let interval1 = beats[i + 1].interval
				let diff = interval1 - interval0
				d += (diff * diff)
			}

			return sqrt(d / Double(size - 1))
		}
	}

	var pnn50: Double {
		get {
			var count: Int = 0

			let size = beats.count
			for  i in 0 ..< size - 1 {
				let interval0 = beats[i].interval
				let interval1 = beats[i + 1].interval
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
}
