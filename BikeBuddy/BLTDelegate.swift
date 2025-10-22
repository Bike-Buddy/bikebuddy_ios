//
//  BluetoothController.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 10/1/25.
//

import Foundation
import CoreBluetooth

// use these to get specific service + characteristic device
let targetServiceUUID = CBUUID(string: "4FAFC201-1FB5-459E-8FCC-C5C9C331914B")
let targetCharacteristicUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26A8")

final class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    
    @Published var peripherals: [CBPeripheral] = []
    @Published var isConnected = false
    @Published var receivedData: String = ""
    
    var connectedPeripheral: CBPeripheral?
    var targetCharacteristic: CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func refreshDevices() {
        print("refreshing devices")
        if centralManager.state == .poweredOn {
            peripherals.removeAll()
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not powered on")
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        refreshDevices()
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if !peripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            peripherals.append(peripheral)
            if peripheral.services?.first?.uuid == targetServiceUUID {
                print("discovered: \(peripheral.name ?? "Unknown"), advertised: \(advertisementData)")
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        isConnected = true
        centralManager.stopScan()
        peripheral.delegate = self

        print("connected to \(peripheral.name ?? "Unknown")")

        peripheral.discoverServices([targetServiceUUID])    // use [targetServiceUUID] for specific device
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        timestamp: CFAbsoluteTime,
                        isReconnecting: Bool,
                        error: (any Error)?) {
        isConnected = false
        peripherals.removeAll()
        refreshDevices()
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: (any Error)?) {
        
        if let error = error {
            print("unable to discover services: \(error.localizedDescription)")
            refreshDevices()
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            print("Service found: \(service.uuid)")
            peripheral.discoverCharacteristics([targetCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: (any Error)?) {
        
        if let error = error {
            print("unable to discover characteristics: \(error.localizedDescription)")
            refreshDevices()
            return
        }

        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print("Characteristic found: \(characteristic.uuid)")
            
            if characteristic.uuid == targetCharacteristicUUID {
                targetCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
                // peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: (any Error)?) {
        
        if let error = error {
            print("characteristic update notification error: \(error.localizedDescription)")
            refreshDevices()
            return
        }
        
        if characteristic.uuid == targetCharacteristicUUID {
            if characteristic.isNotifying {
                print("notifications have begun")
            } else {
                print("notifications have ended, disconnecting")
                centralManager.cancelPeripheralConnection(peripheral)
            }
        }
    }
        
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: (any Error)?) {
        if let error = error {
            print("characteristic update value error: \(error.localizedDescription)")
            refreshDevices()
            return
        }
        
        if let value = characteristic.value {
            let stringValue = String(decoding: value, as: UTF8.self)
            receivedData = stringValue
            print("received value: \(stringValue)")
        }
    }
    
}
