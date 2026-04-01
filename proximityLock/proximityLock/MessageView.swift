//
//  IsFirstTimeView.swift
//  proximityLock
//
//  Created by William Behn on 01/04/2026.
//

import SwiftUI

struct MessageView: View {
    enum Style {
        case info
        case warning
        case custom(Color)
        
        var tint: Color {
            switch self {
            case .info: return .blue
            case .warning: return .red
            case .custom(let c): return c
            }
        }
    }
    
    @ObservedObject var settings: SettingsService
    let message: String
    var style: Style = .info
    var title: String? = nil
    var showsAction: Bool = false
    
    private enum Metrics {
        static let cardCornerRadius: CGFloat = 10
        static let cardBorderWidth: CGFloat = 1
        static let spacing: CGFloat = 8
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.spacing) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .foregroundStyle(style.tint)
                Text(title ?? "No title")
                    .font(.subheadline.weight(.semibold))
            }
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            if showsAction {
                Button("Got it!") {
                    settings.isFirstTimeLocking = false
                }
                .tint(style.tint)
                .controlSize(.small)
            }
        }
        .padding(4)
        .background(style.tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.cardCornerRadius)
                .stroke(style.tint.opacity(0.3), lineWidth: Metrics.cardBorderWidth)
        )
    }
    
    private var iconName: String {
        switch style {
        case .warning: return "exclamationmark.triangle.fill"
        default: return "info.circle.fill"
        }
    }

}
