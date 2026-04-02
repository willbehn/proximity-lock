//
//  LockMonitor.swift
//  proximityLock
//
//  Created by William Behn on 02/04/2026.
//

import Foundation
import Cocoa
import Combine
import os

private let logger = Logger(subsystem: "willbehn.proximityLock", category: "LockMonitor")

@MainActor
final class LockMonitor: ObservableObject {
    let unlockGracePeriod: TimeInterval = 60
        
    @Published private(set) var isLocked: Bool = false
    @Published var isEnabled: Bool = true
    
    private var unlockTime: TimeInterval?
    private let lockCenter = DistributedNotificationCenter.default()
    private var hasTriggeredLock: Bool = false
    
    var onScreenLocked: (() -> Void)?
    var onScreenUnlocked: (() -> Void)?
    
    init() {
        setupLockObservers()
    }
    
    private func setupLockObservers() {
        lockCenter.addObserver(
            forName: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleScreenLocked()
            }
        }
        
        lockCenter.addObserver(
            forName: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleScreenUnlocked()
            }
        }
    }
    
    private func handleScreenLocked() {
        logger.info("Screen is locked")
        hasTriggeredLock = true
        isLocked = true
        onScreenLocked?()
    }
    
    private func handleScreenUnlocked() {
        logger.info("Screen is unlocked")
        hasTriggeredLock = false
        isLocked = false
        unlockTime = Date().timeIntervalSince1970
        onScreenUnlocked?()
    }
    
    func shouldLock(
        rssi: Double,
        threshold: Double,
        scanStartTime: TimeInterval?
    ) -> Bool {
        
        guard !hasTriggeredLock else {
            logger.debug("Lock already triggered")
            return false
        }
        
        // Ikke lås hvis låsing er skrudd av
        guard isEnabled else {
            logger.debug("Lock disabled")
            return false
        }
        
        // Låser ikke hvis lås allerede er låst
        guard !isLocked else {
            logger.debug("Already locked")
            return false
        }
        
        // Venter med å låse igjen til
        let now = Date().timeIntervalSince1970
        if let unlockTime, now - unlockTime <= unlockGracePeriod {
            logger.debug("Within unlock grace period")
            return false
        }
        
        let shouldLock = rssi < threshold
        
        if shouldLock {
            logger.info("RSSI \(rssi) below threshold \(threshold), should lock")
        }
        
        return shouldLock
    }
    
    func triggerLock() {
        logger.info("Triggering screen lock at \(Date())")
        
        let saverPath = "/System/Library/CoreServices/ScreenSaverEngine.app"
        let url = URL(fileURLWithPath: saverPath)
        let config = NSWorkspace.OpenConfiguration()
        
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error = error {
                logger.error("Failed to lock screen: \(error.localizedDescription)")
            } else {
                logger.info("Screen lock triggered successfully")
            }
        }
    }
}
