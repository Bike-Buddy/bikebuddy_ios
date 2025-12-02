//
//  BluetoothController.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 10/1/25.
//

import Foundation
import CoreBluetooth

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

// use these to get specific service + characteristic device
let targetServiceUUID = CBUUID(string: "4FAFC201-1FB5-459E-8FCC-C5C9C331914B")
let targetCharacteristicUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26A8")

final class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // use a singleton so centralManager isnt deallocated when moving between views (avoids XPC error)
    static let shared = BLEManager()
    
    private var centralManager: CBCentralManager!
    
    @Published var peripherals: [CBPeripheral] = []
    @Published var isConnected = false  // honestly should just use connectedPeripheral instead, checking if it is nil would be the same as this boolean check (i think)
    @Published var receivedData: String = ""
    
    var connectedPeripheral: CBPeripheral?
    var targetCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func refreshDevices() {
        print("refreshing devices")
        switch centralManager.state {
        case .poweredOn:
            // NOTE: this keeps any connected peripherals on refresh, might want to disconnect + clear peripherals list + start new scan
            if connectedPeripheral != nil {
                peripherals = [connectedPeripheral!]
                print("already connected to \(connectedPeripheral!.description)")
            } else {
                peripherals.removeAll()
                centralManager.scanForPeripherals(withServices: nil, options: nil)
                print("start new scan")
            }
        default:
            break
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        if connectedPeripheral == peripheral && isConnected {
            print("already connected to \(peripheral.name ?? "Unknown")")
            return
        }
        centralManager.connect(peripheral, options: nil)
    }
    
    /*
    // TODO: disconnect option ???
    func cancelPeripheralConnection(to peripheral: CBPeripheral) {
        if connectedPeripheral != peripheral || !isConnected {
            print("no existing connection with \(peripheral.name ?? "Unknown")")
            return
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    */
    
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
            for service in peripheral.services ?? [] {
                if service.uuid == targetServiceUUID {
                    print("discovered: \(peripheral.name ?? "Unknown"), advertised: \(advertisementData)")
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        isConnected = true
        connectedPeripheral = peripheral
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
        connectedPeripheral = nil
        peripherals.removeAll()
        print("did disconnect from \(peripheral.name ?? "Unknown")")
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
                peripheral.setNotifyValue(true, for: characteristic)
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
        
        if characteristic.uuid == targetCharacteristicUUID, let value = characteristic.value {
            let stringValue = value.hexEncodedString()
            receivedData = stringValue
                         
            // TODO: parse receivedData into custom struct type to extract data + store
            // 4 warnings: tire, brake, gear/chain, number of red flags
            
            Task {
                await DataManager.shared.saveReading(value)
            }
            
            // print("received update value: \(stringValue)")
        }
    }
}
