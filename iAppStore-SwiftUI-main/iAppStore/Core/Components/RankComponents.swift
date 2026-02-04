//
//  RankComponents.swift
//  iAppStore
//
//  排行榜页面组件
//  包含筛选标签、排行榜单元格等组件
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/15.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Filter Tag
/// 筛选标签组件
struct FilterTag: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(AppTheme.Typography.caption1)
                    .lineLimit(1)
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(isSelected ? .white : AppTheme.Colors.Text.primary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(
                isSelected
                    ? AnyShapeStyle(AppTheme.Colors.primary)
                    : AnyShapeStyle(Color(.systemGray6))
            )
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AppTheme.Animation.press, value: isPressed)
    }
}

// MARK: - Modern Rank Cell
/// 现代化排行榜单元格视图
struct ModernRankCell: View {
    let index: Int
    let item: AppRank
    let regionName: String
    
    @Environment(\.openURL) private var openURL
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 排名
            rankNumber
            
            // App图标
            AppIconView(
                url: item.imImage.last?.label,
                size: 64,
                showBorder: true
            )
            
            // App信息
            appInfo
            
            Spacer(minLength: 0)
            
            // 获取按钮
            getButton
        }
        .padding(.horizontal, AppTheme.Spacing.default)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.Background.primary)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppTheme.Animation.press, value: isPressed)
        .contextMenu {
            AppContextMenu(
                appleID: item.id.attributes.imID,
                bundleID: item.id.attributes.imBundleID,
                appUrl: item.id.label,
                developerUrl: item.imArtist.attributes?.href
            )
        }
    }
    
    // MARK: - Subviews
    
    /// 排名数字
    private var rankNumber: some View {
        Text("\(index + 1)")
            .font(AppTheme.Typography.rankNumber)
            .foregroundStyle(rankColor)
            .frame(width: 32, alignment: .center)
    }
    
    /// 排名颜色
    private var rankColor: Color {
        switch index {
        case 0: return .orange
        case 1: return Color(.systemGray)
        case 2: return .brown
        default: return AppTheme.Colors.Text.secondary
        }
    }
    
    /// App信息区域
    private var appInfo: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            // App名称
            Text(item.imName.label)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.Text.primary)
                .lineLimit(2)
            
            // 描述
            Text(item.summary?.label.replacingOccurrences(of: "\n", with: " ") ?? item.rights?.label ?? "")
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(AppTheme.Colors.Text.secondary)
                .lineLimit(2)
            
            // 分类和价格
            HStack(spacing: AppTheme.Spacing.sm) {
                // 分类标签
                Text(item.category.attributes.label)
                    .font(AppTheme.Typography.caption1)
                    .foregroundStyle(AppTheme.Colors.Text.secondary)
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.xs)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                
                // 价格
                if item.imPrice.attributes.amount != "0.00" {
                    Text("\(item.imPrice.attributes.currency) \(item.imPrice.attributes.amount)")
                        .font(AppTheme.Typography.caption1)
                        .foregroundStyle(AppTheme.Colors.primary)
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    /// 获取按钮
    private var getButton: some View {
        Button {
            if let url = URL(string: item.id.label) {
                openURL(url)
            }
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
        } label: {
            Text(item.imPrice.attributes.amount == "0.00" ? "获取" : "购买")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(AppTheme.Colors.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        FilterTag(title: "热门免费榜", icon: "chart.bar.fill", isSelected: true) {}
    }
    .padding()
}
