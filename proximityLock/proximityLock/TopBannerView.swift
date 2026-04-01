//
//  TopBannerView.swift
//  proximityLock
//
//  Created by William Behn on 01/04/2026.
//

import SwiftUI

struct TopBannerView: View {
    @ObservedObject var scanner: ScannerService
    
    var body: some View {
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
    }
}
