//
//  BalanceIndexAnalyzer.swift
//  heartrate-monitor
//
//  Created by Kosuke Miyoshi on 2016/01/25.
//  Copyright © 2016年 narrative nigths. All rights reserved.
//

import Foundation
import Accelerate

class BalanceIndexAnalyzer {
	/**
	* @param resampledIntervals
	*           Resample intervals with Const.RESMPLE_INTERAL_MS millisec interval.
	*/
	static func process(resampledIntervals: [Double]) -> Double {
		var useSampleCount = 1
		while true {
			if useSampleCount * 2 > resampledIntervals.count {
				break
			}
			useSampleCount *= 2
		}
		
		let resampledIntervalsPointer = UnsafePointer<Double>(resampledIntervals)
		let log2n : vDSP_Length = vDSP_Length(log2(Double(useSampleCount)))

		let fftSetup : FFTSetup = vDSP_create_fftsetupD(log2n, Int32(kFFTRadix2))

		// Window function
		var windowData = [Double](count: useSampleCount, repeatedValue: 0)
		var windowedOutput = [Double](count: useSampleCount, repeatedValue: 0)

		vDSP_hann_windowD( &windowData, vDSP_Length(useSampleCount), Int32(0) )
		vDSP_vmulD( resampledIntervalsPointer, 1,
					&windowData, 1,
					&windowedOutput, 1,
					vDSP_Length(useSampleCount) )

		// Transform to Complex
		var imaginaryData = [Double](count: useSampleCount, repeatedValue: 0)
		var dspSplit = DSPDoubleSplitComplex( realp: &windowedOutput,
											  imagp: &imaginaryData )

		vDSP_ctozD( UnsafePointer<DSPDoubleComplex>(windowedOutput), 2,
					&dspSplit, 1,
					vDSP_Length(useSampleCount/2) )

		// Apply FFT
		vDSP_fft_zripD( fftSetup, &dspSplit, 1, log2n, Int32(FFT_FORWARD) )

		// Scaling
		let scale : Double = 1.0 / Double(useSampleCount*2)
		let scales = [scale]

		vDSP_vsmulD( UnsafePointer<Double>(dspSplit.realp), 1,
					 UnsafePointer<Double>(scales),
					 UnsafeMutablePointer<Double>(dspSplit.realp), 1,
					 vDSP_Length(useSampleCount/2) )

		vDSP_vsmulD( UnsafePointer<Double>(dspSplit.imagp), 1,
					 UnsafePointer<Double>(scales),
					 UnsafeMutablePointer<Double>(dspSplit.imagp), 1,
					 vDSP_Length(useSampleCount/2) )

		vDSP_destroy_fftsetupD(fftSetup)

		var powers = [Double](count: useSampleCount, repeatedValue: 0.0)
		vDSP_zvmagsD( &dspSplit, 1,
					  &powers, 1,
					  vDSP_Length(useSampleCount/2) )
        
        var logFreqs = [Double](count: useSampleCount/2, repeatedValue: 0.0)
        var logPowers = [Double](count: useSampleCount/2, repeatedValue: 0.0)
		
		for var i = 0; i < useSampleCount / 2; i++ {
            let f = Double(i) * 1.0 / Double(useSampleCount)
            let freq = f * 1000.0 / Constants.RESMPLE_INTERAL_MS
            logFreqs[i] = log10(freq)
            
			let power = powers[i]
            logPowers[i] = log10(power)
			print("\(logFreqs[i]), \(logPowers[i])")
		}
        
		// TODO:
		
		return 0.0
	}
}
