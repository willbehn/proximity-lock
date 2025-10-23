//
//  main.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 08/10/2025.
//

import Foundation
import CoreBluetooth
import Cocoa

import Foundation
import Combine

import os

private let logger = Logger(subsystem: "willbehn.proximityLock", category: "Bluetooth")


struct DeviceItem: Hashable, Identifiable {
    let id: String
    let name: String
}

class BluetoothScanner: NSObject, CBCentralManagerDelegate {
    private var manager: CBCentralManager!
    private var startTime: Double? = nil
    private var stopAdTrigger: Bool = false
    
    private var unlockTime: Double? = nil
    
    private let lockCenter = DistributedNotificationCenter.default()
    private var isLocked: Bool = false
    
    
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
        manager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "bt.queue"))
        
        
        
        lockCenter.addObserver(
            forName: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            logger.info("screen is locked")
            self?.isLocked = true
            self?.stopScanning()
        }
        
        lockCenter.addObserver(
            forName: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            logger.info("screen is unlocked")
            self?.isLocked = false
            self?.startScanningIfReady()
            self?.unlockTime = Date().timeIntervalSince1970
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:     logger.info("Bluetooth ON")
        case .poweredOff:    logger.info("Bluetooth OFF")
        case .unauthorized:  logger.info("unauthorized")
        case .unsupported:   logger.info("unsupported")
        case .resetting:     logger.info("resetting")
        case .unknown: fallthrough
        @unknown default:    logger.info("unknown")
        }
    }
    
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        
        guard RSSI.intValue != 127 else { return }
        guard !isLocked else { return }
        
        let now = Date().timeIntervalSince1970
        
        if startTime == nil {startTime = now}
        
        if let lt = self.unlockTime, now - lt <= 60 { return }
        
        if let manufacturerKey = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
           manufacturerKey.count >= 2, manufacturerKey[0] == appleLE0, manufacturerKey[1] == appleLE1 {
            
            if let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name),
               !name.isEmpty {
                
                
                let currentDevice: DeviceItem = DeviceItem(id: peripheral.identifier.uuidString, name: name)
                devices.insert(currentDevice)
                
                
                if let selected = self.selectedDevice, currentDevice.id == selected.id {
                    //print("[][APPLE] RSSI=\(rssi) dBm m name=\(name)")
                    //print("id=\(peripheral.identifier.uuidString)")
                    
                    let smoothed = filter.update(measuredRSSI: RSSI.doubleValue, time: now)
                    
                    rssiPublisher.send(smoothed)
                    
                    logger.info("smoothed=\(smoothed) VS normal=\(RSSI.doubleValue)")
                    
                    guard (now - (startTime ?? 0.0)) > 25 else { return }
                    
                    if smoothed < threshold{
                        logger.info("LOCKING at \(Date()) rssi=\(smoothed)")
                        
                        startScreenSaver()
                        
                    }
                }
            }
        }
    }
    
    func startScanningIfReady() {
        if manager.state == .poweredOn {
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

func startScreenSaver() {
    let saverPath = "/System/Library/CoreServices/ScreenSaverEngine.app"
    let url = URL(fileURLWithPath: saverPath)
    let config = NSWorkspace.OpenConfiguration()
    
    DispatchQueue.main.async {
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error = error {
                logger.error("Error \(error)")
            }
        }
    }
}

