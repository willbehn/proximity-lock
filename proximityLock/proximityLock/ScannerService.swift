//
//  ScannerService.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 09/10/2025.
//

import Combine
import Dispatch

struct RSSIWindow {
    private var window: [Double] = []
    var maxCount: Int
    var count: Int { window.count }

    init(maxCount: Int) {
        self.maxCount = maxCount
    }
    
    var values: [Double] { window }
    
    mutating func add(_ newRSSI: Double) {
        if window.count >= maxCount {
            window.removeFirst()
        }
        window.append(newRSSI)
    }
    
    func average() -> Double? {
        guard !window.isEmpty else { return nil }
        return window.reduce(0, +) / Double(window.count)
    }
}

@MainActor
final class ScannerService: ObservableObject {
    private let sampleCount: Int = 30
    
    @Published var isOn = false {
        didSet {
            settings.proximityLockEnabled = isOn
            scanner.setProximityLockEnabled(isOn)
        }
    }
    @Published var threshold: Double {
        didSet {
            scanner.updateThreshold(newThreshold: threshold)
            settings.threshold = threshold
        }
    }
    @Published var lastObservations: [Double]
    @Published var devices: Set<DeviceItem>
    @Published var selectedDevice: DeviceItem? {
        didSet {
            if let device = selectedDevice {
                scanner.updateSelectedDevice(newDevice: device)
                settings.selectedDevice = device
            }
        }
    }
    
    private var samples: RSSIWindow
    
    private var scanner: BluetoothScanner = BluetoothScanner()
    private let settings: SettingsService
    
    private var rssiCancellable: AnyCancellable?
    
    private var publishEvery: Int = 4
    private var tick: Int = 0
    
    init(settings: SettingsService) {
        self.settings = settings
        
        self.threshold = settings.threshold
        self.selectedDevice = settings.selectedDevice
        self.samples = RSSIWindow(maxCount: sampleCount)
        self.lastObservations = []
        self.devices = scanner.devices
        self.isOn = settings.proximityLockEnabled
        scanner.setProximityLockEnabled(self.isOn)
        
        scanner.updateThreshold(newThreshold: settings.threshold)
        if let device = settings.selectedDevice {
            scanner.updateSelectedDevice(newDevice: device)
        }
        
        // Auto-start scanning if enabled from settings
        if self.isOn {
            start()
        }
    }
    
    func start() {
        isOn = true

        scanner.startScanningIfReady()
        
        self.rssiCancellable = scanner.rssiPublisher
            .receive(on: DispatchQueue.main)
            .sink{
                [weak self] rssi in
                
                guard let self else {return }
                self.samples.add(rssi)
                
                self.tick &+= 1
                
                if self.tick % self.publishEvery == 0, self.samples.values.count == self.sampleCount{
                    self.lastObservations = self.samples.values
                }
            }
    }

    func stop() {
        isOn = false
        rssiCancellable = nil
        scanner.stopScanning()
    }
    
    func updateDevices() {
        self.devices = scanner.devices
    }
}

