//
//  DataManager.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 11/7/25.
//

import Foundation
import SwiftData

// TODO: test all of this with ContentView + BLEManager

extension UInt32 {
    var as2BitNumbers: [UInt8] {
        var result: [UInt8] = []
        for i in 0..<16 {
            let shift = i * 2
            let twoBitChunk = UInt8((self >> shift) & 0b11)
            result.append(twoBitChunk)
        }
        return result
    }
    
    var as8BitNumbers: [UInt8] {
        var result: [UInt8] = []
        for i in 0..<4 {
            let shift = i * 8
            let fourBitChunk = UInt8((self >> shift) & 0b1111)
            result.append(fourBitChunk)
        }
        return result
    }
}

/*
 
 data Array:
 
 - Float BrakeHealth
 - Float Velocity
 - Float Acceleration
 - unit32_t WobblePoints = 2 Bits per Point (16 points) = [01 01 01 10 … 01]
 - uint32_t PenaltyFlags = 8 bits per value (4 values)
    - Tires = Encoded for bad tire behaviors
    - Brakes = Encoded for bad brake behaviors
    - Gears = Encoded for bad pedaling
    - E-Stop > 100 = 100 Flag
 
 */

@Model
class DataArray {
    var id: UUID
    var value: [UInt32]
    var timestamp: Date
    
    var BrakeHealth: Float
    var Velocity: Float
    var Acceleration: Float
    var WobblePoints: [UInt8]
    var PenaltyFlags: [UInt8]

    var AverageWobble: Float {
        guard !WobblePoints.isEmpty else { return 0 }
        return WobblePoints.reduce(0) { $0 + Float($1) } / 16.0
    }

    init(value: [UInt32], timestamp: Date = .now) {
        self.id = UUID()
        self.value = value
        self.timestamp = timestamp
        
        self.BrakeHealth =  Float(value[0])
        self.Velocity =     Float(value[1])
        self.Acceleration = Float(value[2])
        // self.WobblePoints = value[3].as2BitNumbers
        self.WobblePoints = value[3].as2BitNumbers
        self.PenaltyFlags = value[3].as2BitNumbers
    }
}

/*
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
 */

@MainActor
final class DataManager {
    static let shared = DataManager()
    private let context: ModelContext
    
    private init() {
        // let container = try! ModelContainer(for: SensorReading.self)
        let container = try! ModelContainer(for: DataArray.self)
        self.context = ModelContext(container)
    }
    
    func parseData(_ value: Data) -> [UInt32]? {
        let bytesToSkip = 0         // skip first 0 Bytes in packet
        let numIntsToRead = 4       // read next 16 4-Byte Ints in packet
        let intSize = MemoryLayout<UInt32>.size
        
        var intArray: [UInt32] = []
        
        guard value.count >= bytesToSkip + (numIntsToRead * intSize) else {
            print("not enough data to read ints after skipping 0 Bytes")
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
            
            var intValue: UInt32 = 0
            _ = withUnsafeMutableBytes(of: &intValue) { intData.copyBytes(to: $0) }
            
            intArray.append(intValue)
        }
        
        print("intArray: \(intArray)")
        
        return intArray
    }
    
    func saveReading(_ value: Data) async {
        
        /*
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
        */

        
        if let dataArray = parseData(value) {
            let reading = DataArray(value: dataArray)
            context.insert(reading)
            do {
                try context.save()
                print("saved reading")
            } catch {
                print("failed save: \(error)")
            }
        }
    }
    
    func deleteAll() async {
        do {
            // let fetchDescriptor = FetchDescriptor<SensorReading>()
            let fetchDescriptor = FetchDescriptor<DataArray>()
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
    
    func fetchData(withLimit: Int?, from startDate: Date, to endDate: Date?) -> [DataArray]? {
        do {
            var fetchDescriptor = FetchDescriptor<DataArray>()
            var predicate: Predicate<DataArray>
            if let endDate = endDate {
                predicate = #Predicate<DataArray> { data in
                    data.timestamp >= startDate && data.timestamp <= endDate
                }
            } else {
                predicate = #Predicate<DataArray> { data in
                    data.timestamp >= startDate
                }
            }
            fetchDescriptor.predicate = predicate
            fetchDescriptor.fetchLimit = withLimit
            fetchDescriptor.sortBy = [SortDescriptor(\DataArray.timestamp, order: .reverse)]    // NOTE: most recent items come first
            return try context.fetch(fetchDescriptor)
        } catch {
            print("failed to fetch data: \(error)")
            return nil
        }
    }
}
