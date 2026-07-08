//
//  AppCellView.swift
//  iAppStore
//
//  通用App单元格视图组件
//  用于排行榜、搜索结果等列表场景
//  兼容 iOS 26 / macOS / iPadOS / Swift 6
//
//  Created by iAppStore on 2026/02/02.
//  Copyright © 2026 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Cell Style
/// 单元格样式枚举
enum AppCellStyle: Sendable {
    /// 排行榜样式（带排名）
    case rank
    /// 搜索结果样式
    case search
    /// 订阅样式
    case subscription
    /// 紧凑样式
    case compact
}

// MARK: - App Cell Data
/// App单元格数据协议
protocol AppCellData: Sendable {
    var cellId: String { get }
    var cellName: String { get }
    var cellSubtitle: String { get }
    var cellIconURL: String? { get }
    var cellCategory: String? { get }
    var cellPrice: String? { get }
    var cellIsFree: Bool { get }
    var cellRating: Double? { get }
    var cellRatingCount: Int? { get }
}

// MARK: - App Cell View
/// 通用App单元格视图
struct AppCellView<Data: AppCellData>: View {
    
    // MARK: - Properties
    
    /// 单元格数据
    let data: Data
    /// 单元格样式
    var style: AppCellStyle = .rank
    /// 排名（仅排行榜样式使用）
    var rank: Int?
    /// 地区名称
    var regionName: String = ""
    /// 获取按钮点击回调
    var onGetTapped: (() -> Void)?
    
    // MARK: - State
    
    @State private var isPressed = false
    @Environment(\.openURL) private var openURL
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 排名（如果有）
            if let rank = rank, style == .rank {
                rankView(rank)
            }
            
            // App图标
            AppIconView(
                url: data.cellIconURL,
                size: iconSize,
                showBorder: true
            )
            
            // App信息
            appInfoView
            
            Spacer(minLength: 0)
            
            // 获取按钮
            getButton
        }
        .padding(.horizontal, AppTheme.Spacing.default)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.Background.primary)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppTheme.Animation.press, value: isPressed)
    }
    
    // MARK: - Computed Properties
    
    /// 图标尺寸
    private var iconSize: CGFloat {
        switch style {
        case .rank, .search:
            return 64
        case .subscription:
            return 72
        case .compact:
            return 48
        }
    }
    
    // MARK: - Subviews
    
    /// 排名视图
    private func rankView(_ rank: Int) -> some View {
        Text("\(rank)")
            .font(AppTheme.Typography.rankNumber)
            .foregroundStyle(rankColor(for: rank))
            .frame(width: 32, alignment: .center)
    }
    
    /// 根据排名返回颜色
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .orange
        case 2: return AppTheme.Colors.Background.gray
        case 3: return Color.brown
        default: return AppTheme.Colors.Text.secondary
        }
    }
    
    /// App信息视图
    private var appInfoView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            // App名称
            Text(data.cellName)
                .font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.Text.primary)
                .lineLimit(2)
            
            // 副标题/开发者
            Text(data.cellSubtitle)
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(AppTheme.Colors.Text.secondary)
                .lineLimit(style == .subscription ? 3 : 2)
            
            // 底部信息栏
            HStack(spacing: AppTheme.Spacing.sm) {
                // 分类标签
                if let category = data.cellCategory, !category.isEmpty {
                    categoryTag(category)
                }
                
                // 评分
                if let rating = data.cellRating, rating > 0 {
                    ratingView(rating, count: data.cellRatingCount)
                }
                
                // 价格（紧凑模式）
                if style == .compact {
                    Spacer()
                    priceText
                }
            }
        }
    }
    
    /// 分类标签
    private func categoryTag(_ category: String) -> some View {
        Text(category)
            .font(AppTheme.Typography.caption1)
            .foregroundStyle(AppTheme.Colors.Text.secondary)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(AppTheme.Colors.Background.gray6)
            .clipShape(Capsule())
    }
    
    /// 评分视图
    private func ratingView(_ rating: Double, count: Int?) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundStyle(.orange)
            
            Text(String(format: "%.1f", rating))
                .font(AppTheme.Typography.caption1)
                .foregroundStyle(AppTheme.Colors.Text.secondary)
            
            if let count = count, count > 0 {
                Text("(\(formatCount(count)))")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.Text.tertiary)
            }
        }
    }
    
    /// 格式化评价数量
    private func formatCount(_ count: Int) -> String {
        if count >= 10000 {
            return String(format: "%.1f万", Double(count) / 10000.0)
        } else if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }
    
    /// 价格文字
    private var priceText: some View {
        Text(data.cellIsFree ? "免费" : (data.cellPrice ?? ""))
            .font(AppTheme.Typography.caption1)
            .foregroundStyle(data.cellIsFree ? AppTheme.Colors.Text.secondary : AppTheme.Colors.primary)
    }
    
    /// 获取按钮
    @ViewBuilder
    private var getButton: some View {
        if style != .compact {
            Button(action: {
                #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                #endif
                onGetTapped?()
            }) {
                Text(data.cellIsFree ? "获取" : (data.cellPrice ?? "购买"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(data.cellIsFree ? .white : AppTheme.Colors.primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(
                        data.cellIsFree
                            ? AnyShapeStyle(AppTheme.Colors.primary)
                            : AnyShapeStyle(AppTheme.Colors.primary.opacity(0.12))
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - AppRank Extension
/// 让 AppRank 遵循 AppCellData 协议
extension AppRank: @unchecked Sendable, AppCellData {
    var cellId: String { id.attributes.imID }
    var cellName: String { imName.label }
    var cellSubtitle: String {
        summary?.label.replacingOccurrences(of: "\n", with: " ") ?? rights?.label ?? ""
    }
    var cellIconURL: String? { imImage.last?.label }
    var cellCategory: String? { category.attributes.label }
    var cellPrice: String? {
        if imPrice.attributes.amount == "0.00" {
            return nil
        }
        return "\(imPrice.attributes.currency) \(imPrice.attributes.amount)"
    }
    var cellIsFree: Bool { imPrice.attributes.amount == "0.00" }
    var cellRating: Double? { nil }
    var cellRatingCount: Int? { nil }
}

// MARK: - AppDetail Extension
/// 让 AppDetail 遵循 AppCellData 协议
extension AppDetail: @unchecked Sendable, AppCellData {
    var cellId: String { String(trackId) }
    var cellName: String { trackName }
    var cellSubtitle: String { artistName }
    var cellIconURL: String? { artworkUrl100 }
    var cellCategory: String? { primaryGenreName }
    var cellPrice: String? { formattedPrice }
    var cellIsFree: Bool { price == 0 }
    var cellRating: Double? { Double(averageUserRating) }
    var cellRatingCount: Int? { userRatingCount }
}

// MARK: - Preview
#Preview("App Cells") {
    List {
        // 这里可以添加预览数据
        Text("App Cell Preview")
    }
}
