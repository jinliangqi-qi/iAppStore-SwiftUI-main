//
//  SubscriptionComponents.swift
//  iAppStore
//
//  订阅管理页面组件
//  包含筛选器枚举、筛选标签、功能说明项、订阅单元格等组件
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/15.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Subscription Filter
/// 订阅筛选器枚举
enum SubscriptionFilter: CaseIterable, Sendable {
    case all
    case pending
    case completed
    case versionUpdate
    case launch
    case removal
    
    var title: String {
        switch self {
        case .all: return "全部"
        case .pending: return "进行中"
        case .completed: return "已完成"
        case .versionUpdate: return "版本更新"
        case .launch: return "应用上架"
        case .removal: return "应用下架"
        }
    }
}

// MARK: - Filter Chip
/// 筛选器标签组件
struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                
                if count > 0 {
                    Text("\(count)")
                        .font(AppTheme.Typography.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            isSelected
                                ? Color.white.opacity(0.3)
                                : AppTheme.Colors.primary.opacity(0.15)
                        )
                        .clipShape(Capsule())
                }
            }
            .foregroundStyle(isSelected ? .white : AppTheme.Colors.Text.primary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.Background.gray6)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feature Item
/// 功能说明项组件
struct FeatureItem: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(title)
                .font(AppTheme.Typography.caption1)
                .foregroundStyle(AppTheme.Colors.Text.secondary)
        }
    }
}

// MARK: - Subscription Cell
/// 订阅单元格组件
struct SubscriptionCell: View {
    let item: AppSubscribe
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // App图标
            AppIconView(
                url: item.artworkURL100,
                size: 72,
                showBorder: true
            )
            
            // 订阅信息
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                // App名称
                Text(item.trackName)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.Text.primary)
                    .lineLimit(1)
                
                // 订阅状态标签
                statusBadge
                
                // 详细信息
                detailInfo
                
                // 状态时间
                statusTime
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
    
    /// 状态标签
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(AppTheme.Typography.caption1)
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(statusColor.opacity(0.1))
        .clipShape(Capsule())
    }
    
    /// 状态颜色
    private var statusColor: Color {
        item.isFinished ? .green : .orange
    }
    
    /// 状态文本
    private var statusText: String {
        switch item.subscribeType {
        case "版本更新":
            return item.isFinished ? "新版本已生效" : "等待版本更新"
        case "应用上架":
            return item.isFinished ? "应用已上架" : "等待应用上架"
        case "应用下架":
            return item.isFinished ? "应用已下架" : "监控应用下架"
        default:
            return ""
        }
    }
    
    /// 详细信息
    private var detailInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("App ID: \(item.appId)")
                .font(AppTheme.Typography.caption2)
                .foregroundStyle(AppTheme.Colors.Text.tertiary)
            
            Text("地区: \(item.regionName)")
                .font(AppTheme.Typography.caption2)
                .foregroundStyle(AppTheme.Colors.Text.tertiary)
            
            if item.subscribeType != "应用上架" {
                Text("当前版本: v\(item.currentVersion)")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.Text.tertiary)
            }
        }
    }
    
    /// 状态时间
    @ViewBuilder
    private var statusTime: some View {
        if item.isFinished, let endTime = item.endCheckTimeStamp {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.green)
                
                Text("完成于 \(FormatHelper.formatDate(endTime))")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(.green)
            }
        } else if let endTime = item.endCheckTimeStamp {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.Colors.Text.tertiary)
                
                Text("最后检查 \(FormatHelper.formatDate(endTime))")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.Text.tertiary)
            }
        } else {
            HStack(spacing: 4) {
                Image(systemName: "clock.badge.questionmark")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.Colors.Text.tertiary)
                
                Text("等待检查...")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.Text.tertiary)
            }
        }
    }
}

// 保持向后兼容
typealias SubscribeCellView = SubscriptionCell
typealias SubscripteCellView = SubscriptionCell

// MARK: - Subscribe Type Card
/// 订阅类型选择卡片
struct SubscribeTypeCard: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? color : AppTheme.Colors.Text.tertiary)
                
                Text(title)
                    .font(AppTheme.Typography.caption1)
                    .foregroundStyle(isSelected ? AppTheme.Colors.Text.primary : AppTheme.Colors.Text.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .fill(isSelected ? color.opacity(0.1) : AppTheme.Colors.Background.gray6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AppTheme.Animation.press, value: isPressed)
    }
}

// MARK: - Subscribe Add Alert Type
/// 添加订阅时的错误类型
enum SubscribeAddAlertType: Identifiable, Sendable {
    case parameterError
    case searchEmptyError
    case existCheckError
    
    var id: Int { hashValue }
    
    var message: String {
        switch self {
        case .parameterError:
            return "当前填写的参数不完整，请检查清楚~"
        case .searchEmptyError:
            return "搜索内容不能为空~"
        case .existCheckError:
            return "已经存在相同 App ID 的检查项，请检查确认~"
        }
    }
}

// 向后兼容
typealias SubscripeAddAlertType = SubscribeAddAlertType

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        FilterChip(title: "全部", count: 5, isSelected: true) {}
        FeatureItem(icon: "arrow.up.circle.fill", title: "版本更新", color: .blue)
        SubscribeTypeCard(title: "版本更新", icon: "arrow.up.circle.fill", color: .blue, isSelected: true) {}
    }
    .padding()
}
