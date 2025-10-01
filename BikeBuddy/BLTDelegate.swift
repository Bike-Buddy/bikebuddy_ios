//
//  BluetoothController.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 10/1/25.
//

import Foundation
import CoreBluetooth

protocol BLTDelegateProtocol: AnyObject {
    
}

final class BLTDelegate: NSObject, BLTDelegateProtocol, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    // func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral]
    // func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral]
    // func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil)
    // func cancelPeripheralConnection(_ peripheral: CBPeripheral)
    // func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral]
    // func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral]
    // func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil)
    // func stopScan()

    override init() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            
        case .poweredOff:
            
        case .resetting:
            
        case .unauthorized:
            
        case .unknown:
            
        case .unsupported:
            
        default:
            print("something happened")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {

    }
    
    func centralManager(_ central: CBCentralManager,
                        willRestoreState dict: [String : Any]) {
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        connectionEventDidOccur event: CBConnectionEvent,
                        for peripheral: CBPeripheral) {
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) {
        
    }
        
}
