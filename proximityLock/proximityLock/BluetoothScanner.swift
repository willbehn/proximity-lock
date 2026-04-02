//
//  BluetoothScanner.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 08/10/2025.
//

import Foundation
import CoreBluetooth
import Cocoa

import Combine

import os

private let logger = Logger(subsystem: "willbehn.proximityLock", category: "Bluetooth")


struct DeviceItem: Hashable, Identifiable {
    let id: String
    let name: String

    static func == (lhs: DeviceItem, rhs: DeviceItem) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@MainActor
class BluetoothScanner: NSObject, CBCentralManagerDelegate {
    private var manager: CBCentralManager!
    private(set) var startTime: Double? = nil
    
    // Id for apple enheter BT advertisement
    let appleLE0: UInt8 = 0x4C
    let appleLE1: UInt8 = 0x00
    
    private(set) var threshold: Double = -65
    private(set) var devices: Set<DeviceItem> = []
    private(set) var selectedDevice: DeviceItem? = nil
    
    let rssiPublisher = PassthroughSubject<Double, Never>()
    
    private var filter = KalmanFilterRSSI(initialRSSI: -70)
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()
    
    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            handleStateUpdate(central.state)
        }
    }
    
    private func handleStateUpdate(_ state: CBManagerState) {
        switch state {
        case .poweredOn:
            logger.info("Bluetooth ON")
            startScanningIfReady()
        case .poweredOff:    logger.info("Bluetooth OFF")
        case .unauthorized:  logger.info("unauthorized")
        case .unsupported:   logger.info("unsupported")
        case .resetting:     logger.info("resetting")
        case .unknown: fallthrough
        @unknown default:    logger.info("unknown")
        }
    }
    
    
    nonisolated func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        Task { @MainActor in
            handleDiscoveredPeripheral(peripheral, advertisementData: advertisementData, rssi: RSSI)
        }
    }
    
    private func handleDiscoveredPeripheral(_ peripheral: CBPeripheral,
                                           advertisementData: [String: Any],
                                           rssi RSSI: NSNumber) {
        guard RSSI.intValue != 127 else { return }
        
        let now = Date().timeIntervalSince1970
        
        if startTime == nil { startTime = now }
        
        if let manufacturerKey = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
           manufacturerKey.count >= 2, manufacturerKey[0] == appleLE0, manufacturerKey[1] == appleLE1 {
            
            if let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name),
               !name.isEmpty {
                
                let currentDevice = DeviceItem(id: peripheral.identifier.uuidString, name: name)
                devices.insert(currentDevice)
                
                if let selected = self.selectedDevice, currentDevice.id == selected.id {
                    let smoothed = filter.update(measuredRSSI: RSSI.doubleValue, time: now)
                    rssiPublisher.send(smoothed)
                    logger.info("smoothed=\(smoothed) VS normal=\(RSSI.doubleValue)")
                }
            }
        }
    }
    
    func startScanningIfReady() {
        if manager.state == .poweredOn {
            startTime = nil
            manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func stopScanning() {
        manager.stopScan()
    }
    
    func updateThreshold(newThreshold: Double) {
        self.threshold = newThreshold
    }
    
    func updateSelectedDevice(newDevice: DeviceItem) {
        self.selectedDevice = newDevice
    }
}

