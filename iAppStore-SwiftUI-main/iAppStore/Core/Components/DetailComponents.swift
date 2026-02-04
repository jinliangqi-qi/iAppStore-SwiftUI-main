//
//  DetailComponents.swift
//  iAppStore
//
//  App详情页面通用组件
//  包含区域标题、快捷信息项、截图卡片、信息行等组件
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/17.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Section Header
/// 区域标题组件
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppTheme.Colors.primary)
            
            Text(title)
                .font(AppTheme.Typography.title3)
                .foregroundStyle(AppTheme.Colors.Text.primary)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

// MARK: - Quick Info Item
/// 快捷信息项组件
struct QuickInfoItem: View {
    let title: String
    let value: String
    var subtitle: String = ""
    var icon: String?
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Typography.caption2)
                .foregroundStyle(AppTheme.Colors.Text.tertiary)
                .textCase(.uppercase)
            
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.primary)
            } else {
                Text(value)
                    .font(AppTheme.Typography.title3)
                    .foregroundStyle(AppTheme.Colors.Text.primary)
            }
            
            Text(subtitle)
                .font(AppTheme.Typography.caption2)
                .foregroundStyle(AppTheme.Colors.Text.secondary)
                .lineLimit(1)
        }
        .frame(width: 80)
        .padding(.horizontal, AppTheme.Spacing.sm)
    }
}

// MARK: - Screenshot Card
/// 截图卡片组件
struct ScreenshotCard: View {
    let url: String
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(Color(.systemGray5))
                    .shimmer()
            }
            .frame(width: 220, height: 390)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .lightShadow()
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppTheme.Animation.press, value: isPressed)
    }
}

// MARK: - Info Row
/// 信息行组件
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.Text.secondary)
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.Text.primary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }
}

// MARK: - Rating View
/// 评分视图组件
struct RatingStarsView: View {
    let rating: Double
    var count: Int?
    var showCount: Bool = true
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            // 星星
            HStack(spacing: 2) {
                ForEach(0..<5) { star in
                    Image(systemName: star < Int(rating) ? "star.fill" : (Double(star) < rating ? "star.leadinghalf.filled" : "star"))
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            // 评分数值
            Text(String(format: "%.1f", rating))
                .font(AppTheme.Typography.caption1)
                .foregroundStyle(AppTheme.Colors.Text.secondary)
            
            // 评价数量
            if showCount, let count = count, count > 0 {
                Text("(\(formatRatingCount(count)))")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.Text.tertiary)
            }
        }
    }
    
    /// 格式化评价数量
    private func formatRatingCount(_ count: Int) -> String {
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000)
        } else if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000)
        }
        return "\(count)"
    }
}

// MARK: - Format Helpers
/// 格式化工具
enum FormatHelper {
    /// 格式化评价数量
    static func formatRatingCount(_ count: Int) -> String {
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000)
        } else if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000)
        }
        return "\(count)"
    }
    
    /// 格式化文件大小
    static func formatFileSize(_ bytes: String) -> String {
        guard let size = Double(bytes) else { return "N/A" }
        let mb = size / 1024 / 1024
        if mb >= 1000 {
            return String(format: "%.1f GB", mb / 1024)
        }
        return String(format: "%.1f MB", mb)
    }
    
    /// 格式化日期
    static func formatDate(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SectionHeader(title: "预览", icon: "photo.on.rectangle.angled")
        
        QuickInfoItem(title: "评分", value: "4.5", subtitle: "1000个评分")
        
        RatingStarsView(rating: 4.5, count: 1000)
        
        InfoRow(title: "版本", value: "1.0.0")
    }
    .padding()
}
