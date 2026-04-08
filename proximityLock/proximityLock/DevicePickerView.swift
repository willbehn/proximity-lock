//
//  DeviceList.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 13/10/2025.
//

import SwiftUI

struct DevicePickerView: View {
    @ObservedObject var scanner: ScannerService
    
    var sortedDevices: [DeviceItem] {
        scanner.devices
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            //Shows if there is a selected device
            if let selected = scanner.selectedDevice {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Currently Selected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(selected.name)
                            .font(.subheadline.weight(.medium))
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            //Device list
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Available Devices")
                        .font(.caption.weight(.medium))
                    Spacer()
                    Button {
                        scanner.updateDevices()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
                
                if sortedDevices.isEmpty {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        Text("No devices found. Click Refresh to scan.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(sortedDevices) { device in
                                Button {
                                    scanner.selectedDevice = device
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: deviceIcon(for: device.name))
                                            .foregroundStyle(.blue)
                                            .frame(width: 20)
                                        
                                        Text(device.name)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        if scanner.selectedDevice?.id == device.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(
                                        scanner.selectedDevice?.id == device.id ?
                                        Color.blue.opacity(0.1) : Color.clear
                                    )
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(4)
                    }
                    .frame(height: 150)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                }
            }
        }
        .padding(CardMetrics.cardPadding)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
    }
    
    private func deviceIcon(for name: String) -> String {
        let lowercased = name.lowercased()
        if lowercased.contains("iphone") { return "iphone" }
        if lowercased.contains("ipad") { return "ipad" }
        if lowercased.contains("watch") { return "applewatch" }
        if lowercased.contains("airpods") { return "airpodspro" }
        if lowercased.contains("mac") { return "laptopcomputer" }
        return "antenna.radiowaves.left.and.right"
    }
}

