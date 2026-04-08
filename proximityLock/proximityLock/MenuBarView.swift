//
//  MenuBarView.swift
//  proximityLock
//
//  Created by William Behn on 08/04/2026.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var scanner: ScannerService
    @EnvironmentObject var settings: SettingsService
    @Environment(\.openWindow) private var openWindow
    
    private let rssiRange: ClosedRange<Double> = -85.0 ... -35.0
    
    private func formatRSSI(_ value: Double) -> String { "\(Int(value)) dBm" }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: scanner.proximityLockEnabled ? "lock.circle.fill" : "lock.open.fill")
                        .foregroundStyle(scanner.proximityLockEnabled ? .green : .secondary)
                        .imageScale(.large)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ProximityLock")
                            .font(.headline)
                        Text(scanner.proximityLockEnabled ? "Monitoring" : "Disabled")
                            .font(.caption)
                            .foregroundStyle(scanner.proximityLockEnabled ? .green : .secondary)
                    }
                    
                    Spacer()
                    
                    Toggle(isOn: $scanner.proximityLockEnabled) {
                        EmptyView()
                    }
                    .toggleStyle(.switch)
                    .onChange(of: scanner.proximityLockEnabled) { _, newValue in
                        if newValue { scanner.start() } else { scanner.stop() }
                    }
                }
                
                // Selected Device
                if let device = scanner.selectedDevice {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundStyle(.blue)
                            .imageScale(.small)
                        Text(device.name)
                            .font(.subheadline)
                        Spacer()
                    }
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .imageScale(.small)
                        Text("No device selected")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(12)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Sensitivity")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(formatRSSI(scanner.threshold))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                
                Slider(
                    value: $scanner.threshold,
                    in: rssiRange
                )
                .tint(.blue)
            }
            .padding(12)
            
            Divider()
            
            VStack(spacing: 0) {
                RSSIChartView(scanner: scanner)
                    .frame(height: 100)
                    .padding(12)
            }
            
            Divider()
            
            VStack(spacing: 0) {
                Button {
                    openWindow(id: "settings")
                } label: {
                    HStack {
                        Text("ProximityLock settings...")
                        Spacer()
                        Text("⌘,")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                
                Divider()
                    .padding(.vertical, 4)
                
                Button(role: .destructive) {
                    NSApp.terminate(nil)
                } label: {
                    HStack {
                        Text("Quit Proximity Lock")
                        Spacer()
                        Text("⌘Q")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .padding(.vertical, 4)
        }
        .frame(width: 300)
        //.background(Color(NSColor.windowBackgroundColor))
    }
}
