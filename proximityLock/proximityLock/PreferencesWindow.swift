//
//  PreferencesWindow.swift
//  proximityLock
//
//  Created by William Behn on 08/04/2026.
//

import SwiftUI

struct PreferencesWindow: View {
    @ObservedObject var settings: SettingsService
    @ObservedObject var scanner: ScannerService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                PreferenceSection(title: "Device", icon: "antenna.radiowaves.left.and.right") {
                    DevicePickerView(scanner: scanner)
                }
                .padding(16)
                
                Divider()
                
                PreferenceSection(title: "Lock Threshold", icon: "slider.horizontal.3") {
                    ThresholdPreferenceView(scanner: scanner)
                }
                .padding(16)
                
                Divider()
                
                PreferenceSection(title: "Monitoring", icon: "eye") {
                    MonitoringPreferenceView(scanner: scanner)
                }
                .padding(16)
            }
         
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 500, height: 600)
    }
}

struct PreferenceSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ThresholdPreferenceView: View {
    @ObservedObject var scanner: ScannerService
    private let rssiRange: ClosedRange<Double> = -85.0 ... -35.0
    
    private func formatRSSI(_ value: Double) -> String { "\(Int(value)) dBm" }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Lock when RSSI is below:")
                Spacer()
                Text(formatRSSI(scanner.threshold))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.blue)
            }
            
            Slider(
                value: $scanner.threshold,
                in: rssiRange
            )
            .tint(.blue)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Less sensitive").font(.caption)
                    Text(formatRSSI(rssiRange.lowerBound))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("More sensitive").font(.caption)
                    Text(formatRSSI(rssiRange.upperBound))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text("Lower values require the device to be further away before locking.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(CardMetrics.cardPadding)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
    }
}

struct MonitoringPreferenceView: View {
    @ObservedObject var scanner: ScannerService
    
    var body: some View {
        VStack(spacing: 12) {
            RSSIChartView(scanner: scanner)
        }
        .padding(CardMetrics.cardPadding)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
    }
}




