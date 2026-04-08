//
//  MenuBarView.swift
//  proximityLock
//
//  Created by William Behn on 08/04/2026.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var scanner: ScannerService
    @EnvironmentObject var settings: SettingsService
    @State private var showingPreferences = false
    @State private var showingOnboarding = false
    
    private let rssiRange: ClosedRange<Double> = -85.0 ... -35.0
    
    private func formatRSSI(_ value: Double) -> String { "\(Int(value)) dBm" }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: scanner.proximityLockEnabled ? "lock.circle.fill" : "lock.open.fill")
                        .foregroundStyle(scanner.proximityLockEnabled ? .green : .secondary)
                        .imageScale(.large)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Proximity Lock")
                            .font(.headline)
                        Text(scanner.proximityLockEnabled ? "Monitoring" : "Disabled")
                            .font(.caption)
                            .foregroundStyle(scanner.proximityLockEnabled ? .green : .secondary)
                    }
                    
                    Spacer()
                    
                    Toggle(isOn: $scanner.proximityLockEnabled) {
                        EmptyView()
                    }
                    .toggleStyle(.switch)
                    .onChange(of: scanner.proximityLockEnabled) { _, newValue in
                        if newValue { scanner.start() } else { scanner.stop() }
                    }
                }
                
                // Selected Device
                if let device = scanner.selectedDevice {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundStyle(.blue)
                            .imageScale(.small)
                        Text(device.name)
                            .font(.subheadline)
                        Spacer()
                        Button {
                            showingPreferences = true
                        } label: {
                            Text("Change")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.blue)
                    }
                } else {
                    Button {
                        showingPreferences = true
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("No device selected")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            
            Divider()
            
            // Quick Threshold Adjust
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Sensitivity")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(formatRSSI(scanner.threshold))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                
                Slider(
                    value: $scanner.threshold,
                    in: rssiRange
                )
                .tint(.blue)
            }
            .padding(12)
            
            Divider()
            
            // Compact RSSI Chart
            RSSIChartView(scanner: scanner)
                .frame(height: 80)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            
            Divider()
            
            // Menu Actions
            VStack(spacing: 0) {
                Button {
                    showingPreferences = true
                } label: {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Preferences...")
                        Spacer()
                        Text("⌘,")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                
                Button {
                    showingOnboarding = true
                } label: {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Show Getting Started")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                
                Divider()
                    .padding(.vertical, 4)
                
                Button(role: .destructive) {
                    NSApp.terminate(nil)
                } label: {
                    HStack {
                        Text("Quit Proximity Lock")
                        Spacer()
                        Text("⌘Q")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .padding(.vertical, 4)
        }
        .frame(width: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingPreferences) {
            PreferencesWindow(settings: settings, scanner: scanner)
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingWindow(settings: settings, scanner: scanner)
        }
    }
}
