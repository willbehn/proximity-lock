//
//  SettingsService.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 08/10/2025.
//

import Foundation
import Combine

@MainActor
final class SettingsService: ObservableObject {
    private let defaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private enum Keys {
        static let isFirstTimeLocking = "isFirstTimeLocking"
        static let selectedDeviceId = "selectedDeviceId"
        static let selectedDeviceName = "selectedDeviceName"
        static let threshold = "lockThreshold"
        static let proximityLockEnabled = "proximityLockEnabled"
    }
    
    @Published var isFirstTimeLocking: Bool {
        didSet {
            defaults.set(isFirstTimeLocking, forKey: Keys.isFirstTimeLocking)
        }
    }
    
    @Published var selectedDevice: DeviceItem? {
        didSet {
            if let device = selectedDevice {
                defaults.set(device.id, forKey: Keys.selectedDeviceId)
                defaults.set(device.name, forKey: Keys.selectedDeviceName)
            } else {
                defaults.removeObject(forKey: Keys.selectedDeviceId)
                defaults.removeObject(forKey: Keys.selectedDeviceName)
            }
        }
    }
    
    @Published var threshold: Double {
        didSet {
            defaults.set(threshold, forKey: Keys.threshold)
        }
    }
    
    @Published var proximityLockEnabled: Bool {
        didSet {
            defaults.set(proximityLockEnabled, forKey: Keys.proximityLockEnabled)
        }
    }
    
    init() {
        self.isFirstTimeLocking = defaults.object(forKey: Keys.isFirstTimeLocking) as? Bool ?? true
        
        if let deviceId = defaults.string(forKey: Keys.selectedDeviceId),
           let deviceName = defaults.string(forKey: Keys.selectedDeviceName) {
            self.selectedDevice = DeviceItem(id: deviceId, name: deviceName)
        } else {
            self.selectedDevice = nil
        }
        
        let savedThreshold = defaults.object(forKey: Keys.threshold) as? Double
        self.threshold = savedThreshold ?? -65.0
        
        self.proximityLockEnabled = defaults.object(forKey: Keys.proximityLockEnabled) as? Bool ?? true
    }
    
    func resetToDefaults() {
        isFirstTimeLocking = true
        selectedDevice = nil
        threshold = -65.0
        proximityLockEnabled = true
    }
  
    func isFullyConfigured() -> Bool {
        return selectedDevice != nil && !isFirstTimeLocking
    }
}
