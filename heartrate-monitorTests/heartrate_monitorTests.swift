//
//  heartrate_monitorTests.swift
//  heartrate-monitorTests
//
//  Created by kosuke miyoshi on 2015/07/03.
//  Copyright (c) 2015年 narrative nigths. All rights reserved.
//

import Cocoa
import XCTest

class heartrate_monitorTests: XCTestCase {

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testSampleInterpolation() {
		XCTAssert(true, "Pass")

		var rawIntervals: [Double] = [Double]()
		rawIntervals.append(100.0)
		rawIntervals.append(200.0)
		rawIntervals.append(100.0)
		rawIntervals.append(200.0)

		var resampledIntervals = SampleInterpolator.process(rawIntervals)

		XCTAssert(resampledIntervals != nil, "resampled intervals was nil")

		XCTAssert(resampledIntervals!.count == 3, "resampled count not match")

		XCTAssert(resampledIntervals![0] == 100.0, "resample failed")
		XCTAssert(resampledIntervals![1] == 150.0, "resample failed")
		XCTAssert(resampledIntervals![2] == 200.0, "resample failed")
	}
    
    func testSampleInterpolation2() {
        XCTAssert(true, "Pass")
        
        var rawIntervals: [Double] = [Double]()
        rawIntervals.append(100.0)
        rawIntervals.append(100.0)
        rawIntervals.append(200.0)
        rawIntervals.append(200.0)
        
        var resampledIntervals = SampleInterpolator.process(rawIntervals)
        
        XCTAssert(resampledIntervals != nil, "resampled intervals was nil")
        
        XCTAssert(resampledIntervals!.count == 3, "resampled count not match")
        
        XCTAssert(resampledIntervals![0] == 100.0, "resample failed")
        XCTAssert(resampledIntervals![1] == 175.0, "resample failed")
        XCTAssert(resampledIntervals![2] == 200.0, "resample failed")
    }

	//func testPerformanceExample() {
	//	self.measureBlock() {
	//	}
	//}
}
