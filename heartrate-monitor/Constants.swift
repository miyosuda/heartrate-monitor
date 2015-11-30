//
//  Constants.swift
//  heartrate-monitor
//
//  Created by Kosuke Miyoshi on 2015/11/29.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation

struct Constants {
	// min frequency of LF part
	static let MIN_LF = 0.04
	// max frequency of LF part
	static let MAX_LF = 0.15
	// min frequency of HF part
	static let MIN_HF = 0.15
	// max frequency of HF part
	static let MAX_HF = 0.4


	// resampling interval in millisec
	static let RESMPLE_INTERAL_MS = 250.0

	// max frequency for spectrum graph
	static let SPECTRUM_GRAPH_MAX_FREQ = 0.5
}
