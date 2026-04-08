//
//  InitialSetupView.swift
//  proximityLock
//
//  Created by William Behn on 08/04/2026.
//

import SwiftUI

struct InitialSetupView: View {
    @ObservedObject var settings: SettingsService
    
    var body: some View {
        VStack(alignment: .leading, spacing: CardMetrics.spacing) {
            // Header with icon
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
                Text("Initial Setup")
                    .font(.subheadline.weight(.semibold))
            }
            
            // Welcome section
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome to ProximityLock!")
                    .font(.caption.weight(.medium))
                
                Text("To get started:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. Select a Bluetooth device below, this device will be used to estimate your distance from your Mac.")
                    Text("2. Turn on Proximity Lock using the toggle at the top.")
                    Text("3. Adjust the lock threshold slider to control sensitivity. Lower values require the device to be farther away before locking, while higher values lock sooner.")
                    Text("4. Wait a short moment while enough signal samples are collected for accurate tracking.")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                Text("Once everything is set up, your Mac will automatically lock when the selected device moves out of range!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Security notice section
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    Text("Security Notice")
                        .font(.caption.weight(.medium))
                }
                
                Text("To ensure ProximityLock works properly, please enable the immediate screen lock setting.\nGo to Settings → Lock Screen → \"Require password after screen saver begins or display is turned off\" and set it to \"Immediately\".")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Single confirmation button
            Button {
                settings.isFirstTimeLocking = false
            } label: {
                HStack {
                    Spacer()
                    Text("Got it! Let's get started")
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .tint(.blue)
        }
        .padding(CardMetrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: CardMetrics.cardCornerRadius)
                .fill(Color.blue.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: CardMetrics.cardCornerRadius)
                .stroke(Color.blue.opacity(0.3), lineWidth: CardMetrics.cardBorderWidth)
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}
