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
    
    @Published var proximityLockEnabled = false {
        didSet {
            settings.proximityLockEnabled = proximityLockEnabled
            lockMonitor.isEnabled = proximityLockEnabled
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
    @Published var isStarting: Bool = true
    
    private var samples: RSSIWindow
    
    private var scanner: BluetoothScanner = BluetoothScanner()
    private var lockMonitor: LockMonitor = LockMonitor()
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
        self.proximityLockEnabled = settings.proximityLockEnabled
        lockMonitor.isEnabled = self.proximityLockEnabled
        
        scanner.updateThreshold(newThreshold: settings.threshold)
        if let device = settings.selectedDevice {
            scanner.updateSelectedDevice(newDevice: device)
        }
        
        // Setup lock monitor callbacks
        setupLockMonitor()
        
        if self.proximityLockEnabled {
            start()
        }
    }
    
    private func setupLockMonitor() {
        lockMonitor.onScreenLocked = { [weak self] in
            self?.scanner.stopScanning()
        }
        
        lockMonitor.onScreenUnlocked = { [weak self] in
            self?.scanner.startScanningIfReady()
        }
    }
    
    func start() {
        proximityLockEnabled = true
        isStarting = true

        scanner.startScanningIfReady()
        
        self.rssiCancellable = scanner.rssiPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rssi in
                guard let self else { return }
                
                self.samples.add(rssi)
                self.tick &+= 1
                
                if self.tick % self.publishEvery == 0, self.samples.values.count == self.sampleCount {
                    self.lastObservations = self.samples.values
                    isStarting = false
                }
                
                // Check if we should lock based on proximity
                if self.lockMonitor.shouldLock(
                    rssi: rssi,
                    threshold: self.threshold,
                    scanStartTime: self.scanner.startTime
                ) {
                    self.lockMonitor.triggerLock()
                }
            }
    }

    func stop() {
        proximityLockEnabled = false
        isStarting = true
        rssiCancellable = nil
        scanner.stopScanning()
        
    }
    
    func updateDevices() {
        self.devices = scanner.devices
    }
}

