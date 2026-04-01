//
//  BluetoothProxScanApp.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 09/10/2025.
//

import SwiftUI

struct ProximityLockView: View {
    @EnvironmentObject var scanner: ScannerService
    @EnvironmentObject var settings: SettingsService
    @State private var isEditing = false
    
    private enum Metrics {
        static let cardPadding: CGFloat = 8
        static let cardCornerRadius: CGFloat = 10
        static let cardBorderWidth: CGFloat = 1
        static let bottomPadding: CGFloat = 12
    }
    
    private let rssiRange: ClosedRange<Double> = -85.0 ... -35.0
    
    private func formatRSSI(_ value: Double) -> String { "\(Int(value)) dBm" }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.circle.fill")
                        .imageScale(.large)
                    Text(String(localized: "Proximity Lock"))
                        .font(.headline)
                    
                    Spacer()
                    
                    Toggle(isOn: $scanner.isOn) {
                        Label(scanner.isOn ? String(localized: "On") : String(localized: "Off"),
                              systemImage: "circle.fill")
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(scanner.isOn ? .green : .secondary)
                        .help(String(localized: "Scanner status"))
                    }
                    .toggleStyle(.switch)
                    .onChange(of: scanner.isOn) { _, newValue in
                        if newValue { scanner.start() } else { scanner.stop() }
                    }
                }
                
                if settings.isFirstTimeLocking {
                    IsFirstTimeView(settings: settings)
                        .padding(Metrics.cardPadding)
                        .overlay(
                            RoundedRectangle(cornerRadius: Metrics.cardCornerRadius)
                                .stroke(.quaternary, lineWidth: Metrics.cardBorderWidth)
                        )
                        .background(.blue.opacity(0.1))
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lock threshold")
                                .font(.subheadline.weight(.semibold))
                            Text("Lock when RSSI is below \(formatRSSI(scanner.threshold))")
                                .font(.caption)
                                .monospacedDigit()
                        }
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Less sensitive").font(.caption)
                            Text(formatRSSI(rssiRange.lowerBound)).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("More sensitive").font(.caption)
                            Text(formatRSSI(rssiRange.upperBound)).font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    
                    Slider(
                        value: $scanner.threshold,
                        in: rssiRange
                    )
                    .tint(.accentColor)
                }
                .padding(Metrics.cardPadding)
                .overlay(
                    RoundedRectangle(cornerRadius: Metrics.cardCornerRadius)
                        .stroke(.quaternary, lineWidth: Metrics.cardBorderWidth)
                )
                
                RSSIChartView(scanner: scanner)
                    .padding(Metrics.cardPadding)
                    .overlay(
                        RoundedRectangle(cornerRadius: Metrics.cardCornerRadius)
                            .stroke(.quaternary, lineWidth: Metrics.cardBorderWidth)
                    )
                
                DevicePickerView(scanner: scanner)
                    .padding(Metrics.cardPadding)
                    .overlay(
                        RoundedRectangle(cornerRadius: Metrics.cardCornerRadius)
                            .stroke(.quaternary, lineWidth: Metrics.cardBorderWidth)
                    )
                
                Divider()
                
                Button(role: .destructive, action: { NSApp.terminate(nil) }) {
                    HStack {
                        Text("Quit Proximity Lock")
                        Spacer()
                        Text("⌘Q").foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            
            }
            .padding(Metrics.bottomPadding)
            .frame(width: 300)
        }
    }
}
