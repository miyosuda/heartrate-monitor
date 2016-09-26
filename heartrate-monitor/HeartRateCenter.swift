//
//  HeartRateCenter.swift
//  heartrate-monitor
//
//  Created by kosuke miyoshi on 2015/07/03.
//  Copyright (c) 2015年 narrative nigths. All rights reserved.
//

import Foundation
import CoreBluetooth


class HeartRateCenter: NSObject, CBCentralManagerDelegate {
	var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
	var heartRatePeripheral: HeartRatePerihepral!

	weak var delegate: HeartRateDelegate!

	init(delegate: HeartRateDelegate) {
		self.delegate = delegate
	}

	func setup() {
		self.centralManager = CBCentralManager(delegate: self, queue: nil)

		let HEART_RATE_SERVICE: String = "180D"
		let services = [CBUUID(string: HEART_RATE_SERVICE)]
		let options: Dictionary = [CBCentralManagerScanOptionAllowDuplicatesKey: false];

		self.centralManager.scanForPeripherals(withServices: services, options: options)
	}

	func cleanup() {
		print("disconnecting peripheral")

		if self.heartRatePeripheral != nil {
			self.centralManager.cancelPeripheralConnection(self.peripheral)
			self.peripheral = nil
		}
	}

	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		switch (central.state) {
		case .unknown:
			print("state: unknown")
			break;
		case .resetting:
			print("state: resetting")
			break;
		case .unsupported:
			print("state: unsupported")
			break;
		case .unauthorized:
			print("state: unauthorized")
			break;
		case .poweredOff:
			print("state: power off")
			break;
		case .poweredOn:
			print("state: power on")
			break;
		}
	}

	func centralManager(_ central: CBCentralManager,
						didDiscover peripheral: CBPeripheral,
						advertisementData: [String:Any],
						rssi RSSI: NSNumber) {

		print("peripheral: \(peripheral) rssi=\(RSSI) data=\(advertisementData)")

		// we need to store reference to peripheral
		self.peripheral = peripheral
                            
		self.centralManager.connect(self.peripheral, options: nil)
		self.centralManager.stopScan()
	}

	func centralManager(_ central: CBCentralManager,
						didConnect peripheral: CBPeripheral) {

		print("connected!")
		delegate.heartRateDeviceDidConnect()

		heartRatePeripheral = HeartRatePerihepral(delegate: delegate)
		heartRatePeripheral.setup(peripheral)
	}

	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		print("didFailToConnectPeripheral")
	}

	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		print("didDisconnectPeripheral")
		delegate.heartRateDeviceDidDisconnect()
	}

}
