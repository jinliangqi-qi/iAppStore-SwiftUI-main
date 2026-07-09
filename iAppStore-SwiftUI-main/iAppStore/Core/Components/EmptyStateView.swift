//
//  EmptyStateView.swift
//  iAppStore
//
//  通用空状态视图组件
//  用于展示无数据、加载失败、搜索无结果等状态
//  兼容 iOS 26 / macOS / iPadOS / Swift 6
//
//  Created by iAppStore on 2026/02/02.
//  Copyright © 2026 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Empty State Type
/// 空状态类型枚举
enum EmptyStateType: Sendable, Equatable {
    /// 无数据
    case noData
    /// 加载中
    case loading
    /// 网络错误
    case networkError
    /// 搜索无结果
    case noSearchResults
    /// 无订阅
    case noSubscriptions
    /// 无收藏
    case noFavorites
    /// 自定义
    case custom(icon: String, title: String, message: String)
    
    /// 图标名称
    var icon: String {
        switch self {
        case .noData: return "rectangle.on.rectangle.slash"
        case .loading: return "arrow.clockwise"
        case .networkError: return "wifi.exclamationmark"
        case .noSearchResults: return "doc.text.magnifyingglass"
        case .noSubscriptions: return "bell.slash"
        case .noFavorites: return "heart.slash"
        case .custom(let icon, _, _): return icon
        }
    }
    
    /// 标题
    var title: String {
        switch self {
        case .noData: return "暂无数据"
        case .loading: return "正在加载"
        case .networkError: return "网络错误"
        case .noSearchResults: return "无搜索结果"
        case .noSubscriptions: return "暂无订阅"
        case .noFavorites: return "暂无收藏"
        case .custom(_, let title, _): return title
        }
    }
    
    /// 描述信息
    var message: String {
        switch self {
        case .noData: return "请稍后再试或切换筛选条件"
        case .loading: return "请稍候..."
        case .networkError: return "请检查网络连接后重试"
        case .noSearchResults: return "试试其他关键词吧"
        case .noSubscriptions: return "点击右上角添加订阅"
        case .noFavorites: return "收藏的应用会显示在这里"
        case .custom(_, _, let message): return message
        }
    }
}

// MARK: - Empty State View
/// 通用空状态视图组件
struct EmptyStateView: View {
    
    // MARK: - Properties
    
    /// 空状态类型
    let type: EmptyStateType
    /// 重试按钮动作（可选）
    var retryAction: (() -> Void)?
    /// 重试按钮标题
    var retryTitle: String = "重试"
    /// 是否显示动画
    var showAnimation: Bool = true
    
    // MARK: - State
    
    @State private var isAnimating = false
    @State private var iconScale: CGFloat = 0.8
    @State private var contentOpacity: Double = 0
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            // 图标
            iconView
            
            // 文字内容
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(type.title)
                    .font(AppTheme.Typography.title3)
                    .foregroundStyle(AppTheme.Colors.Text.primary)
                
                Text(type.message)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.Text.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)
            }
            
            // 重试按钮
            if let action = retryAction {
                AnimatedButton(
                    title: retryTitle,
                    icon: "arrow.clockwise",
                    style: .secondary,
                    width: 140,
                    action: action
                )
                .padding(.top, AppTheme.Spacing.md)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(contentOpacity)
        .onAppear {
            if showAnimation {
                withAnimation(AppTheme.Animation.spring) {
                    iconScale = 1.0
                    contentOpacity = 1.0
                }
            } else {
                iconScale = 1.0
                contentOpacity = 1.0
            }
        }
    }
    
    // MARK: - Icon View
    
    @ViewBuilder
    private var iconView: some View {
        ZStack {
            // 背景圆环
            Circle()
                .fill(AppTheme.Colors.Background.secondary)
                .frame(width: 120, height: 120)
            
            // 图标
            if case .loading = type {
                // 加载动画
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
            } else {
                Image(systemName: type.icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(AppTheme.Colors.Text.tertiary)
                    .symbolEffect(.pulse, options: .repeating, isActive: showAnimation && type == .loading)
            }
        }
        .scaleEffect(iconScale)
    }
}

// MARK: - Loading View (Enhanced)
/// 增强版加载视图
struct AnimatedLoadingView: View {
    
    var message: String = "正在加载..."
    @State private var rotation: Double = 0
    @State private var dotCount = 0
    
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // 自定义加载动画
            ZStack {
                // 外圈
                Circle()
                    .stroke(AppTheme.Colors.primary.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                // 旋转弧
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AppTheme.Colors.primary,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(rotation))
            }
            
            // 加载文字
            Text(message + String(repeating: ".", count: dotCount))
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.Text.secondary)
                .frame(minWidth: 100)
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
}

// MARK: - Preview
#Preview("Empty States") {
    ScrollView {
        VStack(spacing: 40) {
            EmptyStateView(type: .noData, retryAction: {})
                .frame(height: 300)
            
            EmptyStateView(type: .networkError, retryAction: {})
                .frame(height: 300)
            
            EmptyStateView(type: .noSearchResults)
                .frame(height: 300)
            
            EmptyStateView(type: .noSubscriptions)
                .frame(height: 300)
            
            AnimatedLoadingView()
                .frame(height: 200)
        }
    }
}
