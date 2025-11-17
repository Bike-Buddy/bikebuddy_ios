//
//  DataManager.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 11/7/25.
//

import Foundation
import SwiftData

// TODO: test all of this with ContentView + BLEManager

@Model
class SensorReading {
    var id: UUID
    var value: String
    var timestamp: Date
    
    init(value: String, timestamp: Date = .now) {
        self.id = UUID()
        self.value = value
        self.timestamp = timestamp
    }
}

@MainActor
final class DataManager {
    static let shared = DataManager()
    private let context: ModelContext
    
    private init() {
        let container = try! ModelContainer(for: SensorReading.self)
        self.context = ModelContext(container)
    }
    
    func parseData(_ value: Data) -> [Int32]? {
        let bytesToSkip = 8         // skip first 8 Bytes in packet
        let numIntsToRead = 16      // read next 16 4-Byte Ints in packet
        let intSize = MemoryLayout<Int32>.size
        
        var intArray: [Int32] = []
        
        guard value.count >= bytesToSkip + (numIntsToRead * intSize) else {
            print("not enough data to read ints after skipping 8 Bytes")
            return nil
        }
        
        let dataAfterSkip = value.subdata(in: bytesToSkip..<value.count)
        
        for i in 0..<numIntsToRead {
            let startIndex = i * intSize
            let endIndex = startIndex + intSize
            
            guard endIndex <= dataAfterSkip.count else {
                print("not enough data to read all ints")
                return nil
            }
            
            let intData = dataAfterSkip.subdata(in: startIndex..<endIndex)
            
            var intValue: Int32 = 0
            _ = withUnsafeMutableBytes(of: &intValue) { intData.copyBytes(to: $0)}
            
            intArray.append(intValue)
        }
        
        print("intArray: \(intArray)")
        
        return intArray
    }
    
    func saveReading(_ value: Data) async {
        
        // TODO: only save data if there is a change from previous val
        // TODO: modify SensorReading to save dictionary from String 
        
        if let dataArray = parseData(value) {
            print("dataArray: \(dataArray)")
        }
        
        let reading = SensorReading(value: value.hexEncodedString())
        context.insert(reading)
        do {
            try context.save()
            print("saved reading")
        } catch {
            print("failed save: \(error)")
        }

        /*
        if let dataArray = parseData(value) {
            let reading = SensorReading(value: dataArray)
            context.insert(reading)
            do {
                try context.save()
                print("saved reading")
            } catch {
                print("failed save: \(error)")
            }
        }
         */
    }
    
    func deleteAll() async {
        do {
            let fetchDescriptor = FetchDescriptor<SensorReading>()
            let allData = try context.fetch(fetchDescriptor)
            for reading in allData {
                context.delete(reading)
            }
            try context.save()
            print("all sensor data deleted")
        } catch {
            print("failed deletion: \(error)")
        }
        
    }
}
