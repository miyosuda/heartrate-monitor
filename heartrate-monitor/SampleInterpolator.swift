//
//  SampleInterpolator.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/10/20.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation

struct Beat {
	/// time in msec
	var time: Double

	// interval in msec
	var interval: Double
}

class Sample {
	/// interpolated time in msec
	fileprivate var time: Double = 0.0

	// index of beat before this sample
	fileprivate var beatIndex0: Int = -1

	// index of beat after this sample
	fileprivate var beatIndex1: Int = -1

	// resampled interval in msec
	fileprivate var resampledInterval: Double = 0.0

	func setBeatIndex1(_ index1: Int) {
		// if beat index1 is alerady set, do nothing
		if (beatIndex1 == -1) {
			beatIndex1 = index1
		}
	}

	func isIndex1Set() -> Bool {
		return beatIndex1 != -1
	}

	func setup() {
		if isIndex1Set() {
			// if index1 is already set, make index0 one before it.
			var index0 = beatIndex1 - 1
			if index0 < 0 {
				index0 = 0
			}
			beatIndex0 = index0
		} else {
			print(">>> index1 was not set yet")
		}
	}

	func resampleInterval(_ beats: [Beat]) {
		let beat0 = beats[beatIndex0]
		let beat1 = beats[beatIndex1]

		if beatIndex0 == beatIndex1 {
			resampledInterval = beat0.interval
			return
		}

		if time < beat0.time || time > beat1.time {
			print("wrong interpolation: time=\(time), t0=\(beat0.time), t1=\(beat1.time)")
		}

		let dt = beat1.time - beat0.time // msec

		let dt0 = (time - beat0.time) / dt
		let dt1 = (beat1.time - time) / dt

		resampledInterval = dt0 * beat1.interval + dt1 * beat0.interval
	}
}

class SampleInterpolator {

	/**
	* Resample RR intervals with interval of Const.RESMPLE_INTERAL_MS millisec.
	*/
	static func process(_ intervals: [Double]) -> [Double]? {
		var beats: [Beat] = []
		var samples: [Sample] = []

		let intervalSize = intervals.count

		if intervalSize < 1 {
			print("intervals were too short\n")
			return nil
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

		let lastTime = beats[beats.count - 1].time

		// put 4 samples per one second
		let sampleSize = Int(floor(lastTime / Constants.RESMPLE_INTERAL_MS)) + 1

		for i in 0 ..< sampleSize {
			let sample = Sample()
			sample.time = Double(i) * Constants.RESMPLE_INTERAL_MS
			samples.append(sample)
		}

		for i in 0 ..< beats.count {
			let beat = beats[i]
			let time = beat.time
			let beforeTimeIndex = Int(floor(time / Constants.RESMPLE_INTERAL_MS))

			// if beatIndex1 is already set, new one ignored.
			// (Because former beatIndex1 is needed, and so
			// later one is ignored.)
			samples[beforeTimeIndex].setBeatIndex1(i)
		}

		for i in 0 ..< sampleSize {
			let sample = samples[i]
			if !sample.isIndex1Set() {
				// need to set sample's index1.
				// finding among latter samples, and copy first found one.
				for j in i + 1 ..< sampleSize {
					let sample1 = samples[j]
					if sample1.isIndex1Set() {
						sample.setBeatIndex1(sample1.beatIndex1)
						break
					}
				}
			}
		}

		for sample in samples {
			sample.setup()
		}

		var resampledIntervals: [Double] = []

		for sample in samples {
			sample.resampleInterval(beats)
			resampledIntervals.append(sample.resampledInterval)
		}

		return resampledIntervals
	}
}
