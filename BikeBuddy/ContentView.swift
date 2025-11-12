//
//  ContentView.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 10/1/25.
//

import SwiftUI
import Charts
import Combine

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                
                NavigationLink(destination: BLEView()) {
                    CardView(title: "Bluetooth",
                             value: nil,
                             unit: "View Connected Devices",
                             icon: "dot.radiowaves.left.and.right",
                             gradient: .init(colors: [.pink, .red], startPoint: .bottom, endPoint: .top ))
                }
                
                NavigationLink(destination: DataView()) {
                    CardView(title: "Bike Health",
                             value: nil,
                             unit: "View Collected Metrics",
                             icon: "bicycle",
                             gradient: .init(colors: [.red, .pink], startPoint: .bottomLeading, endPoint: .topTrailing ))
                }
                
                NavigationLink(destination: AdviceView()) {
                    CardView(title: "Bike Advice",
                             value: nil,
                             unit: "Get Recommendations",
                             icon: "waveform.path.ecg.text.page.fill",
                             gradient: .init(colors: [.red, .pink], startPoint: .bottomTrailing, endPoint: .bottomLeading ))
                }

                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Summary")
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                // Code to execute when the app is about to terminate
                print("APP IS CLOSING!!!")
                // Perform cleanup, save data, etc.
            }
        }
    }
}

struct CardView: View {
    let title: String
    let value: String?
    let unit: String?
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        if let value = value {
                            Text(value)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        if let unit = unit {
                            Text(unit)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .regular))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.ultraThinMaterial.opacity(0.3))
                    .clipShape(Circle())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

struct BLEView: View {
    @StateObject var bleManager = BLEManager.shared
    @State private var showSheet = false
        
    var body: some View {
        NavigationStack {
            List(bleManager.peripherals, id: \.identifier) { peripheral in
                if ( peripheral.name?.contains("BikeBuddy") ?? false ) {
                    Button(action: {
                        bleManager.connect(to: peripheral)
                        showSheet.toggle()
                    }) {
                        HStack {
                            Text(peripheral.name ?? "No Name")
                        }
                    }
                    .sheet(isPresented: $showSheet) {
                        SheetView(bleManager: bleManager)
                    }
                }
            }
            .navigationTitle("Devices")
            .refreshable {
                bleManager.refreshDevices()
            }
        }
    }
}

struct SheetView: View {
    
    @ObservedObject var bleManager: BLEManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            
            Text("Received Data:")
                .font(.headline)
            Text(bleManager.receivedData)
                .font(.body)
                .padding()
            
            Text("Device Info:")
                .font(.headline)
            Text(bleManager.connectedPeripheral?.description ?? "No Device Connected")
                .font(.body)
                .padding()
            
            Button("Dismiss") {
                dismiss()
            }
        }
    }
}

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
            // .navigationSubtitle(Text("Past 7 Days"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Delete Data") {
                        showAlert = true
                    }
                    .font(.subheadline)
                    .alert("Are you sure?", isPresented: $showAlert) {
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

struct AdviceView: View {
    var data: [String] = [
        "Keep your chain clean and lubricated – wipe it down regularly and reapply bike-specific chain lube (not WD-40).",
        "Clean your bike after wet or muddy rides – dirt and grit wear down parts faster.",
        "Check tire pressure before every ride – use the recommended PSI printed on the sidewall.",
        "Inspect tires for cuts, glass, or embedded debris – prevents punctures and blowouts.",
        "Wipe rims and brake pads – dirt buildup can reduce braking power and damage rims.",
        "Keep derailleurs properly adjusted – shifting should be smooth without clicking or skipping.",
        "Replace your chain regularly – every 2,000–3,000 miles for road bikes, or sooner for mountain bikes.",
        "Check cassette and chainrings for wear – shark-tooth–shaped teeth mean it’s time to replace them.",
        "Clean and lube derailleur pulleys – small but easy to overlook; they collect grime fast.",
        "Do a quick pre-ride safety check – brakes, wheels, and quick releases before every ride.",
        "Schedule a full tune-up at least once a year – even if everything feels fine, a pro can spot early issues.",
        "True your wheels – look for side-to-side wobbles and tighten or loosen spokes as needed.",
        "Check spoke tension – uneven tension can lead to broken spokes or wobbly rims.",
        "Inspect brake pads – replace if grooves are worn down or braking feels weak.",
        "Adjust brake cables and levers – ensure smooth pull and proper return.",
        "Check disc brakes for rotor rub or oil contamination – clean rotors with isopropyl alcohol."
    ]
    
    var body: some View {
        NavigationStack {
            Text(data.randomElement() ?? "Happy riding!")
                .padding()
        }
    }
}

#Preview {
    ContentView()
}
