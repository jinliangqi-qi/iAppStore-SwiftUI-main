//
//  SearchComponents.swift
//  iAppStore
//
//  搜索页面组件
//  包含搜索标签、发现行、搜索结果单元格、流式布局等组件
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/15.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Search Tag
/// 搜索标签组件
struct SearchTag: View {
    let title: String
    var icon: String?
    var iconColor: Color?
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(iconColor ?? AppTheme.Colors.Text.tertiary)
                }
                
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.Text.primary)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AppTheme.Animation.press, value: isPressed)
    }
}

// MARK: - Discover Row
/// 发现行组件
struct DiscoverRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // 图标
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)
            
            // 标题
            Text(title)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.Text.primary)
            
            Spacer()
            
            // 箭头
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.Text.tertiary)
        }
        .padding(.horizontal, AppTheme.Spacing.default)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.Background.primary)
    }
}

// MARK: - Search Result Cell
/// 搜索结果单元格组件
struct SearchResultCell: View {
    let index: Int
    let item: AppDetail
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // App图标
            AppIconView(
                url: item.artworkUrl100,
                size: 64,
                showBorder: true
            )
            
            // App信息
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(item.trackName)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.Text.primary)
                    .lineLimit(1)
                
                Text(item.artistName)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.Text.secondary)
                    .lineLimit(1)
                
                // 评分
                if item.averageUserRating > 0 {
                    HStack(spacing: 4) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { star in
                                Image(systemName: star < Int(item.averageUserRating) ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        }
                        
                        Text(String(format: "%.1f", item.averageUserRating))
                            .font(AppTheme.Typography.caption2)
                            .foregroundStyle(AppTheme.Colors.Text.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 获取按钮
            getButton
        }
        .padding(.vertical, AppTheme.Spacing.xs)
    }
    
    /// 获取按钮
    private var getButton: some View {
        Button {
            if let url = URL(string: item.trackViewUrl) {
                openURL(url)
            }
        } label: {
            Text((item.price ?? 0) == 0 ? "获取" : item.formattedPrice ?? "")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle((item.price ?? 0) == 0 ? .white : AppTheme.Colors.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    (item.price ?? 0) == 0
                        ? AnyShapeStyle(AppTheme.Colors.primary)
                        : AnyShapeStyle(AppTheme.Colors.primary.opacity(0.12))
                )
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Flow Layout
/// 流式布局组件
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                maxHeight = max(maxHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + maxHeight)
        }
    }
}

// MARK: - Region Picker Sheet
/// 地区选择器视图
struct RegionPickerSheet: View {
    @Binding var selectedRegion: String
    let onRegionChanged: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    /// 常用地区
    private let popularRegions = ["中国", "美国", "日本", "韩国", "英国", "德国"]
    
    var body: some View {
        NavigationStack {
            List {
                // 常用地区
                Section("常用地区") {
                    ForEach(popularRegions, id: \.self) { region in
                        regionRow(region)
                    }
                }
                
                // 所有地区
                Section("所有地区") {
                    ForEach(TSMGConstants.regionTypeLists, id: \.self) { region in
                        if !popularRegions.contains(region) {
                            regionRow(region)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("选择地区")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// 地区行视图
    private func regionRow(_ region: String) -> some View {
        HStack {
            Text(region)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.Text.primary)
            
            Spacer()
            
            if region == selectedRegion {
                Image(systemName: "checkmark")
                    .font(.body)
                    .foregroundStyle(AppTheme.Colors.primary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if region != selectedRegion {
                selectedRegion = region
                onRegionChanged()
            }
            dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SearchTag(title: "微信", icon: "clock") {}
        DiscoverRow(title: "今日推荐", icon: "star.fill", color: .orange)
    }
    .padding()
}
