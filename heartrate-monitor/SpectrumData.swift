//
//  SpectrumData.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/10/23.
//  Copyright © 2015年 narrative nigths. All rights reserved.
//

import Foundation

struct SpectrumPoint {
    var frequency : Double
    var psd : Double
}

struct SpectrumData {
    var points : [SpectrumPoint]
}

