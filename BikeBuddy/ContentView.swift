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

#Preview {
    ContentView()
}
