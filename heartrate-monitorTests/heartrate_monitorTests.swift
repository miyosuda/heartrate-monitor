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
    let epsilon = 0.000001
    
	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testSampleInterpolation() {
        XCTAssertEqualWithAccuracy(Constants.RESMPLE_INTERAL_MS, 250.0, accuracy:epsilon)

		var rawIntervals: [Double] = [Double]()
		rawIntervals.append(100.0)
		rawIntervals.append(200.0)
		rawIntervals.append(100.0)
		rawIntervals.append(200.0)

		var resampledIntervals = SampleInterpolator.process(rawIntervals)

		XCTAssert(resampledIntervals != nil)

		XCTAssert(resampledIntervals!.count == 3)

        XCTAssertEqualWithAccuracy(resampledIntervals![0], 100.0, accuracy: epsilon)
		XCTAssertEqualWithAccuracy(resampledIntervals![1], 150.0, accuracy: epsilon)
		XCTAssertEqualWithAccuracy(resampledIntervals![2], 200.0, accuracy: epsilon)
	}
    
    func testSampleInterpolation2() {
        XCTAssertEqualWithAccuracy(Constants.RESMPLE_INTERAL_MS, 250.0, accuracy:epsilon)
        
        var rawIntervals: [Double] = [Double]()
        rawIntervals.append(100.0)
        rawIntervals.append(100.0)
        rawIntervals.append(200.0)
        rawIntervals.append(200.0)
        
        var resampledIntervals = SampleInterpolator.process(rawIntervals)

        
        XCTAssert(resampledIntervals != nil)
        
        XCTAssert(resampledIntervals!.count == 3)
        
        XCTAssertEqualWithAccuracy(resampledIntervals![0], 100.0, accuracy: epsilon)
        XCTAssertEqualWithAccuracy(resampledIntervals![1], 175.0, accuracy: epsilon)
        XCTAssertEqualWithAccuracy(resampledIntervals![2], 200.0, accuracy: epsilon)
    }
}
