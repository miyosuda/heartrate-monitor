//
//  SpectrumAnalyzer.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/10/21.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation

/**
* Spectrum Analyze using Auto Regressive method. (Yule-Walker method)
*/

class SpectrumAnalyzer {
	static func solveLinearEquations(_ mat: inout Array<Array<Double>>, v: inout [Double]) -> Bool {
		let degree = v.count

		for i in 0 ..< degree - 1 {
			var max = fabs(mat[i][i])
			var maxi = i

			for j in i + 1 ..< degree {
				let h = fabs(mat[j][i])
				if h > max {
					max = h
					maxi = j
				}
			}

			if maxi != i {
				for j in 0 ..< degree {
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
			for j in i + 1 ..< degree {
				let q = mat[j][i] / pivot
				mat[j][i] = 0.0
				for k in i + 1 ..< degree {
					mat[j][k] -= (q * mat[i][k])
				}
				v[j] -= (q * v[i])
			}
		}

		// backward substitution
		for i in (0 ..< degree).reversed() {
			for j in ((i + 1) ..< degree).reversed() {
				v[i] -= (mat[i][j] * v[j])
			}
			v[i] /= mat[i][i]
		}

		return true
	}

	static func processYuleWalker(_ inputSeries: [Double],
                                  coefficients: inout [Double],
                                  sigma2: inout Double,
                                  aic: inout Double) -> Bool {
		let degree = coefficients.count

		var mat = Array<[Double]>(repeating: [Double](repeating: 0.0, count: degree),
				count: degree)

		let length = inputSeries.count
        
        var rr = [Double](repeating: 0.0, count: degree+1)
        
        for d in 0 ..< degree+1 {
            for n in 0 ..< length - d {
                let nd = n + d
                rr[d] += (inputSeries[n] * inputSeries[nd])
            }
        }
        
        for i in 0..<degree+1 {
            rr[i] /= Double(length)
        }
        
        for i in 0..<degree {
            coefficients[i] = rr[i+1]
        }
        
        for i in 0 ..< degree {
            for j in 0 ..< degree {
                mat[i][j] = rr[abs(i-j)]
            }
        }
        
        let ret = solveLinearEquations(&mat, v: &coefficients)
        
		if ret == false {
			print("linear solver failed")
			return false
		}
        
        sigma2 = rr[0]
        for i in 0 ..< degree {
            sigma2 -= rr[i+1] * coefficients[i]
        }
        
        aic = Double(length) * log(sigma2) + 2 * Double(degree) + 2
        
        sigma2 = sigma2 / (Double(length) - Double(degree) - 1) * Double(length) // R compatible
        
        return true
	}

	static func calcAutoRegressionCoeffs(_ rawInputSeries: [Double],
										 degree: Int,
										 aic: inout Double,
										 sigma2: inout Double) -> [Double]? {
		let length = rawInputSeries.count
		var inputSeries: [Double] = [Double](repeating: 0.0, count: length)

		var mean = 0.0
		for value in rawInputSeries {
			mean += value
		}
		mean /= Double(length)

		for i in 0 ..< length {
			inputSeries[i] = rawInputSeries[i] - mean;
		}

		var coefficients: [Double] = [Double](repeating: 0.0, count: degree)
        
		let ret = processYuleWalker(inputSeries,
                                    coefficients: &coefficients,
                                    sigma2: &sigma2,
                                    aic: &aic)
		if !ret {
			return nil
		}

		return coefficients
	}

	static func calcSpectrum(_ coeffs: [Double], length: Int, sigma2: Double) -> SpectrumData {
		let degree = coeffs.count
		let spectrumLength = length / 2 + 1

		var points = [SpectrumPoint]()

		for j in 0 ..< spectrumLength {
			let f = Double(j) * 1.0 / Double(length)
			let theta = 2.0 * Double.pi * f

			var rv = 1.0;
			var iv = 0.0;

			for k in 0 ..< degree {
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

	/**
	* @param resampledIntervals
	*           Resample intervals with Const.RESMPLE_INTERAL_MS millisec interval.
	*/
	static func process(_ resampledIntervals: [Double]) -> SpectrumData? {
		var minAic = Double.greatestFiniteMagnitude
		var bestSigma2 = 0.0
		var bestDegree = -1
		var maxDegree = 50
		var bestCoeffcients: [Double]? = nil

		if maxDegree > resampledIntervals.count {
			maxDegree = resampledIntervals.count
		}

		var aics = [Double](repeating: Double.greatestFiniteMagnitude, count: maxDegree)

		for i in 1 ..< maxDegree {
			var aic = 0.0
			var sigma2 = 0.0
			let coefficients: [Double]? =
			calcAutoRegressionCoeffs(resampledIntervals, degree: i, aic: &aic, sigma2: &sigma2)
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
			return calcSpectrum(bestCoeffcients!, length: resampledIntervals.count, sigma2: bestSigma2)
		} else {
			return nil
		}
	}
}
