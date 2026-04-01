//
//  IsFirstTimeView.swift
//  proximityLock
//
//  Created by William Behn on 01/04/2026.
//

import SwiftUI

struct IsFirstTimeView: View {
    @ObservedObject var settings: SettingsService
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("First Time Setup")
                    .font(.subheadline.weight(.semibold))
            }
            Text("Select a Bluetooth device below and adjust the threshold to get started. Make sure \"Require password after screen saver begins\" is enabled in System Settings > Lock Screen.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Button("Got it!") {
                settings.isFirstTimeLocking = false
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
    }
}
