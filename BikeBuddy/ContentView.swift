//
//  ContentView.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var bleManager = BLEManager()
    
    @State private var showSheet = false

    var body: some View {
        NavigationView {
            List(bleManager.peripherals, id: \.identifier) { peripheral in
                if ( peripheral.name?.contains("BikeBuddy") ?? false ) {
                    Button(action: { bleManager.connect(to: peripheral)
                        showSheet.toggle() 
                    }) {
                        Text(peripheral.name ?? "No Name")
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

#Preview {
    ContentView()
}
