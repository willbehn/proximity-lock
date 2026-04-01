//
//  TestPlot.swift
//  BluetoothProxScanPOC
//
//  Created by William Behn on 13/10/2025.
//


import SwiftUI
import Charts

struct RSSIChartView: View {
    
    private enum Metrics {
        static let chartHeight: CGFloat = 100
        static let chartPadding: CGFloat = 4
    }
    
    private let rssiRange: ClosedRange<Double> = -85.0 ... -35.0
    
    private func formatRSSI(_ value: Double) -> String { "\(Int(value)) dBm" }
    
    @ObservedObject var scanner: ScannerService

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Bluetooth RSSI chart (last \(scanner.lastObservations.count) samples)")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()

            if scanner.isStarting {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text(String(localized: "Waiting for enough samples..."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(Metrics.chartPadding)
            } else {
                Chart {
                    ForEach(Array(scanner.lastObservations.enumerated()), id: \.offset) { idx, rssi in
                        LineMark(
                            x: .value("Idx", idx),
                            y: .value("RSSI", rssi)
                        )
                    }
                    RuleMark(y: .value("Threshold", scanner.threshold))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundStyle(Color.secondary)
                        .annotation(position: .top, alignment: .leading) {
                            Text("threshold")
                                .font(.caption2)
                                .foregroundStyle(.primary)
                                .monospacedDigit()
                        }
                }
                .chartYScale(domain: rssiRange)
                .chartXAxis(.hidden)
                .frame(height: Metrics.chartHeight)
                .frame(maxWidth: .infinity)
                .padding(Metrics.chartPadding)

                Text("Current threshold for RSSI detection: \(formatRSSI(scanner.threshold))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

