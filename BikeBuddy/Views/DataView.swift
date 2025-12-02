//
//  DataView.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 11/12/25.
//

import Foundation
import SwiftUI
import Charts

let debug = 1

struct BikeData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
}

struct DataView: View {
    @State private var showAlert = false
    
    // TODO: read data from 
    
    // Dummy step data for the past 7 days
    var data: [BikeData] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<365*24).map {
            let day = calendar.date(byAdding: .hour, value: -$0, to: today)!
            return BikeData(date: day, value: Int.random(in: 0...200))
        }.reversed()
    }()
    
    @State var bikeData: [DataArray] = {
        if (debug == 1) {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            return (0..<365*24).map {
                let a1 = UInt32.random(in: 0...100)
                let b1 = UInt32.random(in: 0...100)
                let c1 = UInt32.random(in: 0...100)
                let d1 = UInt32(0xFFFFFFFF)
                // let e1 = UInt32(0xFFFFFFFF)

                let day = calendar.date(byAdding: .hour, value: -$0, to: today)!
                let dataArray = DataArray(value: [a1, b1, c1, d1], timestamp: day)
                return dataArray
            }.reversed()
        } else {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            return DataManager.shared.fetchData(withLimit: nil, from: today, to: nil)
        }
    }() ?? []
    
    /*
    var bikeData: [DataArray] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<365*24).map {
            
            let a1 = UInt32.random(in: 0...100)
            let b1 = UInt32.random(in: 0...100)
            let c1 = UInt32.random(in: 0...100)
            let d1 = UInt32(0xFFFFFFFF)
            let e1 = UInt32(0xFFFFFFFF)

            let day = calendar.date(byAdding: .hour, value: -$0, to: today)!
            let dataArray = DataArray(value: [a1, b1, c1, d1, e1], timestamp: day)
            print(dataArray.Acceleration)
            print(dataArray.AverageWobble)
            return dataArray
        }.reversed()
    }()
     */
    
    func removeData() {
        if ( debug == 1 ) {
            bikeData.removeLast(1000)
        } else {
            Task {
                await DataManager.shared.deleteAll()
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    /*
                    ChartView(title: "Tire Wobble (Hour)", unit: .hour, data: data.suffix(48))
                    
                    ChartView(title: "Brake Health (Day)", unit: .day, data: data.suffix(48))
                    
                    ChartView(title: "Gear Health (Month)", unit: .month, data: data.suffix(12*30*24))
                    */
                    
                    DataArrayChartView(title: "Velocity", unit: .day, data: bikeData)
                    
                    DataArrayChartView(title: "Acceleration", unit: .day, data: bikeData)

                    // DataArrayChartView(title: "Average Wobble", unit: .month, data: bikeData)

                    DataArrayChartView(title: "Brake Health", unit: .month, data: bikeData)
                }
            }
            .padding(.horizontal)
            .navigationTitle("Data")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Delete Data", systemImage: "trash", role: .destructive) {
                        showAlert = true
                    }
                    .tint(.red)
                    .alert("Delete Bike Data?", isPresented: $showAlert) {
                        Button("Ok", role: .destructive) {
                            /*
                            Task {
                                await DataManager.shared.deleteAll()
                            }
                             */
                            removeData()
                            print("Ok button was tapped")
                        }
                        Button("Cancel", role: .cancel) {
                            print("cancel button was tapped")
                        }
                    } message: {
                        Text("This will delete all collected bike data for the day")
                    }
                }
            }
        }
    }
}

struct ChartView: View {
    let title: String
    let unit: Calendar.Component?
    var data: [BikeData]
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        // change this
        formatter.locale = Locale(identifier: "en_GB")
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Chart(data) { item in
                BarMark(
                    x: .value("Day", item.date, unit: unit ?? .day),
                    y: .value("Steps", item.value)
                )
                .cornerRadius(6)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .red],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .chartXAxis {
                switch (unit) {
                case .hour:
                    AxisMarks(values: .stride(by: .hour, count: 6)) {value in
                        AxisValueLabel(format: .dateTime.hour(.conversationalDefaultDigits(amPM: .abbreviated)))
                    }
                case .day:
                    AxisMarks(values: .stride(by: .day, count: 28)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, formatter: Self.dateFormatter)
                            }
                        }
                    }
                case .month:
                    AxisMarks(values: .stride(by: .month)) {value in
                        AxisValueLabel(format: .dateTime.month(.narrow))
                    }
                case .year:
                    AxisMarks(values: .stride(by: .year)) { value in
                        AxisValueLabel(format: .dateTime.year(.defaultDigits))
                    }
                default:
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartScrollableAxes(.horizontal)
            .frame(height: 200)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

struct DataArrayChartView: View {
    let title: String
    let unit: Calendar.Component?
    var data: [DataArray]
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        // change this
        formatter.locale = Locale(identifier: "en_GB")
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            /*
            Chart(data) { item in
                BarMark(
                    x: .value("Day", item.timestamp, unit: unit ?? .day),
                    y: .value(dataLabel, item.Acceleration)
                )
                .cornerRadius(6)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .red],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
             */
            getChart(data: data, dataLabel: getUnit(title), unit: unit)
            .chartXAxis {
                switch (unit) {
                case .hour:
                    AxisMarks(values: .stride(by: .hour, count: 6)) {value in
                        AxisValueLabel(format: .dateTime.hour(.conversationalDefaultDigits(amPM: .abbreviated)))
                    }
                case .day:
                    AxisMarks(values: .stride(by: .day, count: 28)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, formatter: Self.dateFormatter)
                            }
                        }
                    }
                case .month:
                    AxisMarks(values: .stride(by: .month)) {value in
                        AxisValueLabel(format: .dateTime.month(.narrow))
                    }
                case .year:
                    AxisMarks(values: .stride(by: .year)) { value in
                        AxisValueLabel(format: .dateTime.year(.defaultDigits))
                    }
                default:
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartScrollableAxes(.horizontal)
            .frame(height: 200)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

func getUnit(_ input: String) -> dataLabel {
    switch input {
    case "Acceleration":
        return .Acceleration
    case "Velocity":
        return .Velocity
    case "Average Wobble":
        return .AverageWobble
    case "Brake Health":
        return .BrakeHealth
    default:
        return .Velocity
    }
}

enum dataLabel {
    case Acceleration
    case Velocity
    case AverageWobble
    case BrakeHealth
}

@ViewBuilder
func getChart(data: [DataArray], dataLabel: dataLabel, unit: Calendar.Component?) -> some View {
       
    switch dataLabel {
    case .Acceleration:
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.timestamp, unit: unit ?? .day),
                y: .value("Acceleration", item.Acceleration)
            )
            .cornerRadius(6)
            .foregroundStyle(
                LinearGradient(
                    colors: [.pink, .red],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
    case .Velocity:
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.timestamp, unit: unit ?? .day),
                y: .value("Velocity", item.Velocity)
            )
            .cornerRadius(6)
            .foregroundStyle(
                LinearGradient(
                    colors: [.pink, .red],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
    case .AverageWobble:
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.timestamp, unit: unit ?? .day),
                y: .value("Average Wobble", item.AverageWobble)
            )
            .cornerRadius(6)
            .foregroundStyle(
                LinearGradient(
                    colors: [.pink, .red],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
    case .BrakeHealth:
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.timestamp, unit: unit ?? .day),
                y: .value("Brake Health", item.BrakeHealth)
            )
            .cornerRadius(6)
            .foregroundStyle(
                LinearGradient(
                    colors: [.pink, .red],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
    }
}
