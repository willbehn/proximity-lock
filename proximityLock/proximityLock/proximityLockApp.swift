//
//  proximityLockApp.swift
//  proximityLock
//
//  Created by William Behn on 13/10/2025.
//

import SwiftUI

@main
struct ProximityLockApp: App {
    @StateObject private var settings: SettingsService
    @StateObject private var scanner: ScannerService
    
    init() {
        // For testing av first time, TODO husk å fjern
        // UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        let settings = SettingsService()
        _settings = StateObject(wrappedValue: settings)
        _scanner = StateObject(wrappedValue: ScannerService(settings: settings))
    }

    var body: some Scene {
        MenuBarExtra("BT Prox", systemImage: "lock") {
            ProximityLockView()
                .environmentObject(settings)
                .environmentObject(scanner)
        }
        .menuBarExtraStyle(.window)
    }
}
