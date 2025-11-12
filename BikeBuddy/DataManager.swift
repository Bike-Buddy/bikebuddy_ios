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
    
    func saveReading(_ value: String) async {
        let reading = SensorReading(value: value)
        context.insert(reading)
        do {
            try context.save()
            print("saved reading: \(value)")
        } catch {
            print("failed save: \(error)")
        }
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
