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
    
    var body: some View {
        VStack(alignment: .leading, spacing: CardMetrics.spacing) {
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
        .padding(CardMetrics.cardPadding)
        .background(style.tint.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: CardMetrics.cardCornerRadius)
                .stroke(style.tint.opacity(0.3), lineWidth: CardMetrics.cardBorderWidth)
        )
    }
    
    private var iconName: String {
        switch style {
        case .warning: return "exclamationmark.triangle.fill"
        default: return "info.circle.fill"
        }
    }

}
