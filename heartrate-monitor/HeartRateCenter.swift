//
//  HeartRateCenter.swift
//  standblue
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

	func setup() {
		self.centralManager = CBCentralManager(delegate: self, queue: nil)

		let HEART_RATE_SERVICE: String = "180D"
		let services = [CBUUID(string: HEART_RATE_SERVICE)]
		let options: Dictionary = [CBCentralManagerScanOptionAllowDuplicatesKey: false];

		self.centralManager.scanForPeripheralsWithServices(services, options: options)
	}

	func cleanup() {
		println("disconnecting peripheral")

		if self.heartRatePeripheral != nil {
			self.centralManager.cancelPeripheralConnection(self.peripheral)
			self.peripheral = nil
		}
	}

	func centralManagerDidUpdateState(central: CBCentralManager!) {
		switch (central.state) {
		case .Unknown:
			println("state: unknown")
			break;
		case .Resetting:
			println("state: resetting")
			break;
		case .Unsupported:
			println("state: unsupported")
			break;
		case .Unauthorized:
			println("state: unauthorized")
			break;
		case .PoweredOff:
			println("state: power off")
			break;
		case .PoweredOn:
			println("state: power on")
			break;
		}
	}

	func centralManager(central: CBCentralManager!,
						didDiscoverPeripheral peripheral: CBPeripheral!,
						advertisementData: [NSObject:AnyObject]!,
						RSSI: NSNumber!) {

		println("peripheral: \(peripheral) rssi=\(RSSI)")

		// 何故かここで参照を保存しておかないとうまく動かない？
		self.peripheral = peripheral

		self.centralManager.connectPeripheral(peripheral, options: nil)
		self.centralManager.stopScan()
	}

	func centralManager(central: CBCentralManager!,
						didConnectPeripheral peripheral: CBPeripheral!) {

		println("connected!")

		heartRatePeripheral = HeartRatePerihepral()
		heartRatePeripheral.setup(peripheral)
	}

	func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
		println("didFailToConnectPeripheral")
	}

	func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
		println("didDisconnectPeripheral")
	}

}
