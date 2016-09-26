//
//  HeartRateDelegate.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/07/03.
//  Copyright (c) 2015年 narrative nigths. All rights reserved.
//

import Foundation

protocol HeartRateDelegate: class {
	func heartRateDeviceDidConnect()
	func heartRateDeviceDidDisconnect()
	func heartRateRRDidArrive(_ rr: Double)
}
