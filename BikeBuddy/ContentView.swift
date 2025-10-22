//
//  ContentView.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var bleManager = BLEManager()
    @State private var messageToSend: String = ""
    
    var body: some View {
        NavigationView {
            List(bleManager.peripherals, id: \.identifier) { peripheral in
                // peripheral.identifier.uuidString == "4FAFC201-1FB5-459E-8FCC-C5C9C331914B"
                if ( peripheral.name?.hasPrefix("Long name works now") ?? false ) {
                    Button(action: { bleManager.connect(to: peripheral) }) {
                        Text(peripheral.description)
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

#Preview {
    ContentView()
}
