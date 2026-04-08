//
//  OnboardingWindow.swift
//  proximityLock
//
//  Created by William Behn on 08/04/2026.
//

import SwiftUI

struct OnboardingWindow: View {
    @ObservedObject var settings: SettingsService
    @ObservedObject var scanner: ScannerService
    @State private var currentStep = 0
    @Environment(\.dismiss) private var dismiss
    
    private let totalSteps = 4
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Welcome to ProximityLock!")
                    .font(.title2.bold())
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            Group {
                switch currentStep {
                case 0:
                    IntroductionStep()
                case 1:
                    DeviceSelectionStep(scanner: scanner)
                case 2:
                    ThresholdConfigurationStep(scanner: scanner)
                case 3:
                    SecurityNoticeStep()
                default:
                    IntroductionStep()
                }
            }
            .frame(height: 400)
         
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step == currentStep ? Color.blue : Color.secondary.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.vertical, 12)
            
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .keyboardShortcut(.cancelAction)
                }
                
                Spacer()
                
                if currentStep < totalSteps - 1 {
                    Button("Continue") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(currentStep == 1 && scanner.selectedDevice == nil)
                } else {
                    Button("Get Started") {
                        settings.isFirstTimeLocking = false
                        dismiss()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(width: 600, height: 550)
    }
}

struct IntroductionStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("ProximityLock uses Bluetooth signals from your device to automatically lock your Mac when you walk away from it! ProximityLock provides")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "wave.3.right",
                    title: "Bluetooth Monitoring",
                    description: "Tracks signal strength from your device"
                )
                
                FeatureRow(
                    icon: "lock.shield",
                    title: "Automatic Locking",
                    description: "Locks your Mac when you're out of range"
                )
                
                FeatureRow(
                    icon: "slider.horizontal.3",
                    title: "Customizable Sensitivity",
                    description: "Adjust the distance threshold to your preference"
                )
            }
            .padding(.horizontal, 60)
            .padding(.top, 20)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct DeviceSelectionStep: View {
    @ObservedObject var scanner: ScannerService
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Your Device")
                .font(.title3.bold())
            
            Text("Choose a Bluetooth device that you typically carry with you, like your iPhone or Apple Watch. This device will be used to estimate your distance from your Mac.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            
            DevicePickerView(scanner: scanner)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct ThresholdConfigurationStep: View {
    @ObservedObject var scanner: ScannerService
    private let rssiRange: ClosedRange<Double> = -85.0 ... -35.0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Configure Lock Threshold")
                .font(.title3.bold())
            
            Text("Adjust the sensitivity to control when your Mac locks. Lower values require you to be farther away before locking, while higher values lock sooner.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Threshold")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(scanner.threshold)) dBm")
                            .font(.title2.bold())
                            .monospacedDigit()
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Less Sensitive")
                                .font(.caption.weight(.medium))
                            Text("Farther away")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("More Sensitive")
                                .font(.caption.weight(.medium))
                            Text("Closer range")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Slider(
                        value: $scanner.threshold,
                        in: rssiRange
                    )
                    .tint(.blue)
                }
                
                HStack(spacing: 8) {
                    Text("You can adjust this later from the menu bar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct SecurityNoticeStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text("Important Security Notice")
                .font(.title3.bold())
            
            Text("To ensure ProximityLock works effectively, you need to configure your Mac's screen lock settings:")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                InstructionStep(
                    number: 1,
                    text: "Open System Settings"
                )
                
                InstructionStep(
                    number: 2,
                    text: "Navigate to Lock Screen"
                )
                
                InstructionStep(
                    number: 3,
                    text: "Find \"Require password after screen saver begins or display is turned off\""
                )
                
                InstructionStep(
                    number: 4,
                    text: "Set it to \"Immediately\""
                )
            }
            .padding(20)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(12)
            .padding(.horizontal, 60)
            
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("This ensures your Mac locks immediately when ProximityLock triggers the screen saver")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number).")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 24, height: 0)
                
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}
// MARK: - Preview

#Preview("Onboarding - Full Flow") {
    OnboardingWindow(
        settings: SettingsService(),
        scanner: ScannerService(settings: SettingsService())
    )
}

#Preview("Introduction Step") {
    IntroductionStep()
        .frame(width: 600, height: 400)
}

#Preview("Device Selection Step") {
    DeviceSelectionStep(scanner: ScannerService(settings: SettingsService()))
        .frame(width: 600, height: 400)
}

#Preview("Threshold Configuration Step") {
    ThresholdConfigurationStep(scanner: ScannerService(settings: SettingsService()))
        .frame(width: 600, height: 400)
}

#Preview("Security Notice Step") {
    SecurityNoticeStep()
        .frame(width: 600, height: 400)
}

