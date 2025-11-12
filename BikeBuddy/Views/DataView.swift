//
//  DataView.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 11/12/25.
//

import Foundation
import SwiftUI

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
        
        return (0..<7).map {
            let day = calendar.date(byAdding: .day, value: -$0, to: today)!
            return BikeData(date: day, value: Int.random(in: 3000...12000))
        }.reversed()
    }()
    
    var body: some View {
        NavigationStack {
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
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
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 220)
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

