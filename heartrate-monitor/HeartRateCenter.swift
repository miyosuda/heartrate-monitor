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

		self.centralManager.scanForPeripheralsWithServices(services, options: options)
	}

	func cleanup() {
		print("disconnecting peripheral")

		if self.heartRatePeripheral != nil {
			self.centralManager.cancelPeripheralConnection(self.peripheral)
			self.peripheral = nil
		}
	}

	func centralManagerDidUpdateState(central: CBCentralManager) {
		switch (central.state) {
		case .Unknown:
			print("state: unknown")
			break;
		case .Resetting:
			print("state: resetting")
			break;
		case .Unsupported:
			print("state: unsupported")
			break;
		case .Unauthorized:
			print("state: unauthorized")
			break;
		case .PoweredOff:
			print("state: power off")
			break;
		case .PoweredOn:
			print("state: power on")
			break;
		}
	}

	func centralManager(central: CBCentralManager,
						didDiscoverPeripheral peripheral: CBPeripheral,
						advertisementData: [String:AnyObject],
						RSSI: NSNumber) {

		print("peripheral: \(peripheral) rssi=\(RSSI) data=\(advertisementData)")

		// we need to store reference to peripheral
		self.peripheral = peripheral
                            
		self.centralManager.connectPeripheral(self.peripheral, options: nil)
		self.centralManager.stopScan()
	}

	func centralManager(central: CBCentralManager,
						didConnectPeripheral peripheral: CBPeripheral) {

		print("connected!")
		delegate.heartRateDeviceDidConnect()

		heartRatePeripheral = HeartRatePerihepral(delegate: delegate)
		heartRatePeripheral.setup(peripheral)
	}

	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		print("didFailToConnectPeripheral")
	}

	func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		print("didDisconnectPeripheral")
		delegate.heartRateDeviceDidDisconnect()
	}

}
