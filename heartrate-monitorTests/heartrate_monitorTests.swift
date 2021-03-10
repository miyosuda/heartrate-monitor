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
        XCTAssertEqual(Constants.RESMPLE_INTERAL_MS, 250.0, accuracy:epsilon)

		var rawIntervals: [Double] = [Double]()
		rawIntervals.append(100.0)
		rawIntervals.append(200.0)
		rawIntervals.append(100.0)
		rawIntervals.append(200.0)
        
        let beatsData = BeatsData(intervals:rawIntervals)

        let resampledIntervals = SampleInterpolator.process(beatsData.beats)

		XCTAssert(resampledIntervals != nil)

		XCTAssert(resampledIntervals!.count == 3)

        XCTAssertEqual(resampledIntervals![0], 100.0, accuracy: epsilon)
        XCTAssertEqual(resampledIntervals![1], 150.0, accuracy: epsilon)
        XCTAssertEqual(resampledIntervals![2], 200.0, accuracy: epsilon)
	}
    
    func testSampleInterpolation2() {
        XCTAssertEqual(Constants.RESMPLE_INTERAL_MS, 250.0, accuracy:epsilon)
        
        var rawIntervals: [Double] = [Double]()
        rawIntervals.append(100.0)
        rawIntervals.append(100.0)
        rawIntervals.append(200.0)
        rawIntervals.append(200.0)
        
        let beatsData = BeatsData(intervals:rawIntervals)
        let resampledIntervals = SampleInterpolator.process(beatsData.beats)
        
        XCTAssert(resampledIntervals != nil)
        
        XCTAssert(resampledIntervals!.count == 3)
        
        XCTAssertEqual(resampledIntervals![0], 100.0, accuracy: epsilon)
        XCTAssertEqual(resampledIntervals![1], 175.0, accuracy: epsilon)
        XCTAssertEqual(resampledIntervals![2], 200.0, accuracy: epsilon)
    }
        
    func testCalcAutoRegressionCoeffs() {
        let resampledIntervals = [ 0.000000000,  0.000000000,  0.631477142, -0.320985966,  0.824080766,
                                   0.390071224,  0.212813007, -0.774419370, -0.244077049, -0.183143382,
                                   0.012392628,  1.176335615,  0.089261905, -0.274778149, -0.493976229,
                                  -0.055583998, -0.197458588, -0.163338769,  0.142264093, -0.501943933,
                                   0.361110645, -0.771789864,  0.125952354,  0.060736002,  0.067228224,
                                   0.392879699, -0.118369784,  0.330506394,  0.445461859, -0.415529085,
                                  -0.482734673,  0.092105619, -0.201221517, -0.209625546, -0.189401462,
                                  -0.303588651,  0.415597354,  0.434107957,  0.439502863, -0.270368776,
                                   0.741682102, -0.358889763,  1.061384249, -0.029834237, -0.086260396,
                                  -0.398185829, -0.494521366, -0.458938177, -0.728971652,  0.703144139,
                                   0.149116073, -0.063050347,  0.167470777, -0.238100347,  1.301141248,
                                  -0.752717414,  0.323383273, -0.049864833,  0.362010764, -0.183047547,
                                  -1.020936905, -0.399453910,  0.151610812, -0.093357181, -0.428033935,
                                   0.037426175, -0.470345140,  0.243396297, -0.832191414,  0.421442952,
                                  -0.085178340,  0.106619045, -0.027723858,  0.148927534, -0.365202405,
                                   0.050332162,  0.273834509,  0.488317444, -0.015964307,  0.006153958,
                                  -0.459568211, -0.603131823, -0.305207833,  0.627952034,  0.190932105,
                                  -0.078996835, -0.168789420, -0.177167299,  0.521686578, -0.290456571,
                                   0.765834374,  0.095571530,  0.721492565, -0.605057756,  0.245636490,
                                  -0.577477204,  0.473203370, -0.130626672, -0.049279849,  0.723985829]
        
        var aic = 0.0
        var sigma2 = 0.0
        let degree = 3
        let coefficients: [Double]? =
            SpectrumAnalyzer.calcAutoRegressionCoeffs(resampledIntervals,
                                                       degree: degree,
                                                       aic: &aic,
                                                       sigma2: &sigma2)
        
        print(coefficients ?? 0.0)
        print(sigma2)
        print(aic)
        
        // [old]
        // -0.10485316087758097, 0.14546111924183386, -0.21012857036945848])
        // 0.17496308198006164
        // 120.75376823510214
    }
}
