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
        static let cardPadding: CGFloat = 4
        static let cardCornerRadius: CGFloat = 10
        static let cardBorderWidth: CGFloat = 1
        static let bottomPadding: CGFloat = 12
    }
    
    private let rssiRange: ClosedRange<Double> = -85.0 ... -35.0
    
    private func formatRSSI(_ value: Double) -> String { "\(Int(value)) dBm" }
    
    var body: some View {
        VStack {
            // Top banner and messages
            VStack(alignment: .leading, spacing: 8) {
                
                TopBannerView(scanner: scanner)
                    .padding(Metrics.cardPadding)
                
                if settings.isFirstTimeLocking {
                    MessageView(
                        settings: settings,
                        message: "Select a Bluetooth device below and adjust the rssi threshold to get started. Wait for around 30 secods so we get intial reading,then porxiimty lock is active when you see the graph",
                        style: .info,
                        title: "First Time Setup",
                        showsAction: true
                    )
                }
                
                MessageView(
                    settings: settings,
                    message: "To ensure ProximityLock works properly, please enable the immediate screen lock setting. Go to Settings → Lock Screen → \"Require password after screen saver begins or display is turned off\" and set it to \"Immediately\".",
                    style: .warning,
                    title: "Security Notice",
                    showsAction: false
                )
                
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
