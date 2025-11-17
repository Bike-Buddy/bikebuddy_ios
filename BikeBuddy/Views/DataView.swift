//
//  DataView.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 11/12/25.
//

import Foundation
import SwiftUI
import Charts

struct BikeData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
}

struct DataView: View {
    @State private var showAlert = false
    
    // Dummy step data for the past 7 days
    var data: [BikeData] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<365*24).map {
            let day = calendar.date(byAdding: .hour, value: -$0, to: today)!
            return BikeData(date: day, value: Int.random(in: 0...200))
        }.reversed()
    }()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ChartView(title: "Sample Steps (Hour)", unit: .hour, data: data.suffix(48))
                    
                    ChartView(title: "Sample Steps (Day)", unit: .day, data: data.suffix(356*24))
                    
                    ChartView(title: "Sample Steps (Month)", unit: .month, data: data.suffix(12*30*24))
                    
                    ChartView(title: "Sample Steps (Year)", unit: .year, data: data)
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
                            Task {
                                await DataManager.shared.deleteAll()
                            }
                            print("Ok button was tapped")
                        }
                        Button("Cancel", role: .cancel) {
                            print("cancel button was tapped")
                        }
                    } message: {
                        Text("This will delete all your collected bike data")
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
