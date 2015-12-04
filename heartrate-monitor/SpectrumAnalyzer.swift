//
//  SpectrumAnalyzer.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/10/21.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation

class SpectrumAnalyzer {
	static func solveLinearEquations(inout mat: Array<Array<Double>>, inout v: [Double]) -> Bool {
		let degree = v.count

		for var i = 0; i < degree - 1; ++i {
			var max = fabs(mat[i][i])
			var maxi = i

			for var j = i + 1; j < degree; ++j {
				let h = fabs(mat[j][i])
				if h > max {
					max = h
					maxi = j
				}
			}

			if maxi != i {
				for var j = 0; j < degree; ++j {
					let tmp = mat[i][j]
					mat[i][j] = mat[maxi][j]
					mat[maxi][j] = tmp
				}

				let tmp = v[i]
				v[i] = v[maxi]
				v[maxi] = tmp
			}

			let pivot = mat[i][i]

			if fabs(pivot) == 0.0 {
				print("gausian elimination couldn't solve: singular matrix\n")
				return false
			}

			// forward elimination
			for var j = i + 1; j < degree; ++j {
				let q = mat[j][i] / pivot
				mat[j][i] = 0.0
				for var k = i + 1; k < degree; k++ {
					mat[j][k] -= (q * mat[i][k])
				}
				v[j] -= (q * v[i])
			}
		}

		// backward substitution
		for var i = degree - 1; i >= 0; --i {
			for var j = degree - 1; j > i; --j {
				v[i] -= (mat[i][j] * v[j])
			}
			v[i] /= mat[i][i]
		}

		return true
	}

	static func processYuleWalker(inputSeries: [Double], inout coefficients: [Double]) -> Bool {
		let degree = coefficients.count

		var mat = Array<[Double]>(count: degree,
				repeatedValue: [Double](count: degree, repeatedValue: 0.0))

		let length = inputSeries.count

		for var i = 0; i < degree; i++ {
			for var n = 0; n < length - degree; n++ {
				let ni = n + 1 + i
				coefficients[i] += (inputSeries[n] * inputSeries[ni])
			}
		}

		for var i = 0; i < degree; i++ {
			for var j = i; j < degree; j++ {
				for var n = 0; n < length - degree; n++ {
					let ni = n + 1 + i
					let nj = n + 1 + j
					mat[i][j] += (inputSeries[ni] * inputSeries[nj]);
				}
			}
		}

		let base = Double(length - degree)
		for var i = 0; i < degree; i++ {
			coefficients[i] /= base
			for var j = i; j < degree; j++ {
				mat[i][j] /= base
				mat[j][i] = mat[i][j]
			}
		}

		if solveLinearEquations(&mat, v: &coefficients) == false {
			print("linear solver failed")
			return false
		} else {
			return true
		}
	}

	static func calcAutoRegressionCoeffs(rawInputSeries: [Double],
										 degree: Int,
										 inout aic: Double,
										 inout sigma2: Double) -> [Double]? {
		let length = rawInputSeries.count
		var inputSeries: [Double] = [Double](count: length, repeatedValue: 0.0)

		var mean = 0.0
		for value in rawInputSeries {
			mean += value
		}
		mean /= Double(length)

		for var i = 0; i < length; ++i {
			inputSeries[i] = rawInputSeries[i] - mean;
		}

		var coefficients: [Double] = [Double](count: degree, repeatedValue: 0.0)

		let ret = processYuleWalker(inputSeries, coefficients: &coefficients)
		if !ret {
			return nil
		}

		sigma2 = calcSigma2(inputSeries, coefficients: coefficients)
		aic = calcAIC(sigma2, length: length, degree: degree)

		return coefficients
	}

	static func calcSigma2(inputSeries: [Double],
						   coefficients: [Double]) -> Double {

		// version of adding degree-size 0 before and after inputSeries 
		let degree = coefficients.count
		let originalLength = inputSeries.count

		var extendedInputSeries = [Double](count: inputSeries.count + 2 * degree,
				repeatedValue: 0.0)

		//for var i=0; i<degree; ++i {
		//	extendedInputSeries[i] = 0.0
		//}

		for var i = 0; i < originalLength; ++i {
			extendedInputSeries[degree + i] = inputSeries[i]
		}

		//for var i=0; i<degree; ++i {
		//	extendedInputSeries[originalLength + degree + i] = 0.0
		//}

		let length = extendedInputSeries.count
		var s = 0.0
		for var n = 0; n < length - degree; ++n {
			let xs = extendedInputSeries[n]
			var xd = 0.0
			for var i = 0; i < degree; ++i {
				let ni = n + 1 + i
				xd += (coefficients[i] * extendedInputSeries[ni])
			}
			let d = xs - xd
			s += (d * d)
		}
		return s / Double(length - degree)

		// version of not adding degree-size 0 before and after inputSeries
		/*
		let degree = coefficients.count
		let length = inputSeries.count
	
		var s = 0.0
		for var n=0; n<length-degree; ++n {
			let xs = inputSeries[n]
			var xd = 0.0
			for var i=0; i<degree; ++i {
				let ni = n+1+i
				xd += (coefficients[i] * inputSeries[ni])
			 }
		     let d = xs - xd
			 s += (d * d)
		}
		return s / Double(length - degree)
		*/
	}

	static func calcAIC(sigma2: Double, length: Int, degree: Int) -> Double {
		// version of adding degree-size 0 before and after inputSeries
		//var aic = Doubel(length) * ( log(2.0 * M_PI * sigma2) + 1.0 ) + 2.0 * (degree + 1)

		// version of not adding degree-size 0 before and after inputSeries
		let a = Double(length + degree)
		let b = (log(2.0 * M_PI * sigma2) + 1.0)
		let c = 2.0 * (Double(degree) + 1.0)
		let aic = a * b + c
		return aic
	}

	static func calcSpectrum(coeffs: [Double], length: Int, sigma2: Double) -> SpectrumData {
		let degree = coeffs.count
		let spectrumLength = length / 2 + 1

		var points = [SpectrumPoint]()

		for var j = 0; j < spectrumLength; j++ {
			let f = Double(j) * 1.0 / Double(length)
			let theta = 2.0 * M_PI * f

			var rv = 1.0;
			var iv = 0.0;

			for var k = 0; k < degree; k++ {
				let a = coeffs[k]
				let t = Double(-(k + 1)) * theta
				rv -= a * cos(t)
				iv -= a * sin(t)
			}

			let psd = sigma2 / (rv * rv + iv * iv)
			let realFreq = f * 1000.0 / Constants.RESMPLE_INTERAL_MS
			points.append(SpectrumPoint(frequency: realFreq, psd: psd))
		}

		let spectrumData = SpectrumData(points: points)
		return spectrumData
	}

    static func process(beatsData: BeatsData) -> SpectrumData? {
		// Resample intervals with Const.RESMPLE_INTERAL_MS millisec interval.
		let resampledIntervals = SampleInterpolator.process(beatsData.beats)
		if resampledIntervals == nil {
			return nil
		}

		var minAic = DBL_MAX
		var bestSigma2 = 0.0
		var bestDegree = -1
		var maxDegree = 50
		var bestCoeffcients: [Double]? = nil

		if maxDegree > resampledIntervals!.count {
			maxDegree = resampledIntervals!.count
		}

		var aics = [Double](count: maxDegree, repeatedValue: DBL_MAX)

		for var i = 1; i < maxDegree; ++i {
			var aic = 0.0
			var sigma2 = 0.0
			let coefficients: [Double]? =
			calcAutoRegressionCoeffs(resampledIntervals!, degree: i, aic: &aic, sigma2: &sigma2)
			if coefficients == nil {
				print("calc auto regression failed")
				continue
			} else {
				aics[i] = aic
				if aic < minAic {
					minAic = aic
					bestDegree = i
					bestSigma2 = sigma2
					bestCoeffcients = coefficients
				}
			}
		}

		print("best degree=\(bestDegree)")
		print("best sigma2=\(bestSigma2)")

		if maxDegree != -1 {
			return calcSpectrum(bestCoeffcients!, length: resampledIntervals!.count, sigma2: bestSigma2)
		} else {
			return nil
		}
	}
}
