//
//  BluetoothController.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 10/1/25.
//

import Foundation
import CoreBluetooth

// dummy values, use these to get specific service + characteristic device
let targetServiceUUID = CBUUID(string: "FFF0")
let targetCharacteristicUUID = CBUUID(string: "FFF1")

final class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    
    @Published var peripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var receivedData: String = ""
    
    var targetCharacteristic: CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // filter specific devices --> scanForPeripherals(withServices: [CBUUID])
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            print("scanning started")
        default:
            print("Bluetooth unavailable")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if !peripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            peripherals.append(peripheral)
            print("discovered: \(peripheral.name ?? "Unknown")")
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        connectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        print("connected to \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices(nil)    // use [targetServiceUUID] for specific device
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        timestamp: CFAbsoluteTime,
                        isReconnecting: Bool,
                        error: (any Error)?) {
        if let services = peripheral.services {
            for service in services {
                print("Service found: \(service.uuid)")
            }
        }
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Service found: \(service.uuid)")
            
            peripheral.discoverCharacteristics(nil, for: service)   // use [targetCharacteristicsUUID] for specific device
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("Characteristic found: \(characteristic.uuid)")
            
            if characteristic.uuid == targetCharacteristicUUID {
                targetCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid == targetCharacteristicUUID, let value = characteristic.value {
            let stringValue = String(decoding: value, as: UTF8.self)
            receivedData = stringValue
            print("received value: \(stringValue)")
        }
    }
    
    func write(_ string: String) {
        guard let peripheral = connectedPeripheral,
                let characteristic = targetCharacteristic,
                let data = string.data(using: .utf8) else { return }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        print("wrote value: \(string)")
    }
            
}
