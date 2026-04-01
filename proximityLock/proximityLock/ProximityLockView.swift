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

    private let rssiRange: ClosedRange<Double> = -85.0 ... -35.0
    
    private func formatRSSI(_ value: Double) -> String { "\(Int(value)) dBm" }
    
    var body: some View {
        VStack {
            // Top banner and messages
            VStack(alignment: .leading, spacing: 8) {
                
                TopBannerView(scanner: scanner)
                
                if settings.isFirstTimeLocking {
                    MessageView(
                        settings: settings,
                        message: "Welcome to ProximityLock!\n\nTo get started:\n1. Select a Bluetooth device below, this device will be used to estimate your distance from your Mac.\n2. Turn on Proximity Lock using the toggle at the top.\n3. Adjust the lock threshold slider to control sensitivity. Lower values require the device to be farther away before locking, while higher values lock sooner.\n4. Wait a short moment while enough signal samples are collected for accurate tracking.\n\nOnce everything is set up, your Mac will automatically lock when the selected device moves out of range!",
                        style: .info,
                        title: "Getting started",
                        showsAction: true
                    )
                }
                
                MessageView(
                    settings: settings,
                    message: "To ensure ProximityLock works properly, please enable the immediate screen lock setting.\nGo to Settings → Lock Screen → \"Require password after screen saver begins or display is turned off\" and set it to \"Immediately\".",
                    style: .warning,
                    title: "Security Notice",
                    showsAction: false
                )
                
                VStack(alignment: .leading, spacing: CardMetrics.spacing) {
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
                .padding(CardMetrics.cardPadding)
                .overlay(
                    RoundedRectangle(cornerRadius: CardMetrics.cardCornerRadius)
                        .stroke(.quaternary, lineWidth: CardMetrics.cardBorderWidth)
                )
                
                RSSIChartView(scanner: scanner)
                    .padding(CardMetrics.cardPadding)
                    .overlay(
                        RoundedRectangle(cornerRadius: CardMetrics.cardCornerRadius)
                            .stroke(.quaternary, lineWidth: CardMetrics.cardBorderWidth)
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
            .padding(CardMetrics.bottomPadding)
            .frame(width: 300)
        }
    }
}
