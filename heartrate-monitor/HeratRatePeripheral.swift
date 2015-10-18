//
//  HeartRatePeripheral.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/07/02.
//  Copyright (c) 2015年 kosuke miyoshi. All rights reserved.
//

import Foundation
import CoreBluetooth

struct HeartRateFlags {
	// 1bit
	var hr_format: UInt8
	// 2bit
	var sensor_contact: UInt8
	// 1bit
	var energy_expended: UInt8
	// 1bit
	var rr_interval: UInt8

	init(flag: UInt8) {
		hr_format = flag & 0x1;
		sensor_contact = (flag >> 1) & 0x3;
		energy_expended = (flag >> 3) & 0x1;
		rr_interval = (flag >> 4) & 0x1;
	}

	/**
	* get byte size of hr value
	*/
	func getHRSize() -> Int {
		return Int(hr_format) + 1;
	}
}

class HeartRatePerihepral: NSObject, CBPeripheralDelegate {
	let HEART_RATE_SERVICE: String = "180D"
	let HEART_RATE_MEASUREMENT: String = "2A37"

	weak var delegate: HeartRateDelegate!

	init(delegate: HeartRateDelegate) {
		self.delegate = delegate
	}

	func setup(peripheral: CBPeripheral) {
		peripheral.delegate = self;
		// NOTE you might only discover HR service, but on this example we discover all services
		peripheral.discoverServices(nil)
	}

	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {

		print("didDiscoverServices")

		if error != nil {
			return;
		}

		for service in peripheral.services! {
			if service.UUID == CBUUID(string: HEART_RATE_SERVICE) {
				let service: CBService = service as CBService;
				peripheral.discoverCharacteristics(nil, forService: service);
			}
		}
	}

	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService,
					error: NSError?) {

		print("didDiscoverCharacteristicsForService")

		if error != nil {
			return;
		}

		if service.UUID == CBUUID(string: HEART_RATE_SERVICE) {
			for character in service.characteristics! {
				let ch: CBCharacteristic = character as CBCharacteristic;
				if ch.UUID == CBUUID(string: HEART_RATE_MEASUREMENT) {
					peripheral.setNotifyValue(true, forCharacteristic: ch)
				}
			}
		}
	}

    func getUInt16Value(dataPtr: UnsafePointer<UInt8>, offset: Int) -> UInt16 {
		let value0: UInt32 = UInt32(dataPtr[offset + 1])
		let value1: UInt32 = UInt32(dataPtr[offset])
		return UInt16(value0 << 8 + value1)
	}

	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic,
					error: NSError?) {

		if error != nil {
			return;
		}

		if characteristic.UUID == CBUUID(string: HEART_RATE_MEASUREMENT) {
			let value: NSData? = characteristic.value
			let dataPtr: UnsafePointer<UInt8> = UnsafePointer<UInt8>(value!.bytes)
			let dataSize: Int = value!.length

			let flags: UInt8 = dataPtr[0]
			let heartRateFlags = HeartRateFlags(flag: flags)

			// hr value
			var offset: Int = 1
			if heartRateFlags.getHRSize() == 2 {
				// 2byte
				let hrValue: UInt16 = getUInt16Value(dataPtr, offset: offset)
				print("hr=\(hrValue)")
				offset += 2
			} else {
				// 1byte
				let hrValue: UInt8 = dataPtr[offset];
				print("hr=\(hrValue)")
				offset += 1
			}

			// energy value
			if heartRateFlags.energy_expended != 0 {
				// 2byte
				let energyValue: UInt16 = getUInt16Value(dataPtr, offset: offset)
				print("energy=\(energyValue)")
				offset += 2
			}

			// RR interval value
			if heartRateFlags.rr_interval != 0 {
				while offset < dataSize {
					// 2byte
					let rrValue: UInt16 = getUInt16Value(dataPtr, offset: offset)
					let rr: Double = (Double(rrValue) / 1024.0) * 1000.0
					print("rr=\(rr)")
					delegate.heartRateRRDidArrive(rr)
					offset += 2
				}
			}
		}
	}
}
