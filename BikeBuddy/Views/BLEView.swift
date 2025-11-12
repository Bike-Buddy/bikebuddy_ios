//
//  BLEView.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 11/12/25.
//

import Foundation
import SwiftUI

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

