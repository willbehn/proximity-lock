//
//  DeviceList.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 13/10/2025.
//

import SwiftUI

struct DevicePickerView: View {
    @State private var devices: [DeviceItem] = []
    @State private var selectedID: String? = nil
    
    @ObservedObject var scanner: ScannerService
    
    var sortedDevices: [DeviceItem] {
        scanner.devices
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CardMetrics.spacing) {
                HStack {
                    Text("Devices")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                }
            
            if let selected = scanner.selectedDevice {
                Text("Selected: \(selected.name)")
                    .font(.footnote)
                    .foregroundStyle(.primary)
            }
            
            Text("Choose Device")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(sortedDevices) { device in
                        Button {
                            selectedID = device.id
                            scanner.selectedDevice = device
                        } label: {
                            HStack {
                                Text(device.name)
                                    .font(.subheadline)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }.padding(.vertical, 2)
                }
                .padding(.vertical, 2)
            }
            .frame(height: 60)
            
            Button(action: {
                scanner.updateDevices()
            }) {
                Label("Rescan", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(CardMetrics.cardPadding)
        .overlay(
            RoundedRectangle(cornerRadius: CardMetrics.cardCornerRadius)
                .stroke(.quaternary, lineWidth: CardMetrics.cardBorderWidth)
        )
    }
    
}

