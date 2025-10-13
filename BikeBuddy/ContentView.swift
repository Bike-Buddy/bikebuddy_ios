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
                Button(action: {
                    bleManager.connect(to: peripheral)
                }) {
                    Text(peripheral.name ?? "Unknown Device")
                }
            }.navigationTitle("Bluetooth devices")
        }
    }
}

#Preview {
    ContentView()
}
