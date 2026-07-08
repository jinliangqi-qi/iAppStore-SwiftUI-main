//
//  AnimatedButton.swift
//  iAppStore
//
//  带动画效果的按钮组件
//  支持多种样式：主要按钮、次要按钮、获取按钮等
//  兼容 iOS 26 / macOS / iPadOS / Swift 6
//
//  Created by iAppStore on 2026/02/02.
//  Copyright © 2026 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Button Style
/// 按钮样式枚举
enum AppButtonStyle: Sendable {
    /// 主要按钮（蓝色填充）
    case primary
    /// 次要按钮（蓝色边框）
    case secondary
    /// 获取按钮（App Store 风格）
    case get
    /// 购买按钮
    case purchase
    /// 文字按钮
    case text
    /// 图标按钮
    case icon
    /// 危险操作按钮
    case destructive
}

// MARK: - Animated Button
/// 带动画效果的通用按钮组件
struct AnimatedButton: View {
    
    // MARK: - Properties
    
    /// 按钮标题
    let title: String
    /// 按钮图标（可选）
    var icon: String?
    /// 按钮样式
    var style: AppButtonStyle = .primary
    /// 是否禁用
    var isDisabled: Bool = false
    /// 是否加载中
    var isLoading: Bool = false
    /// 按钮宽度（nil 表示自适应）
    var width: CGFloat?
    /// 点击动作
    let action: () -> Void
    
    // MARK: - State
    
    @State private var isPressed = false
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            if !isDisabled && !isLoading {
                // 触觉反馈
                #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                #endif
                action()
            }
        }) {
            buttonContent
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled || isLoading)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AppTheme.Animation.press, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    // MARK: - Button Content
    
    @ViewBuilder
    private var buttonContent: some View {
        switch style {
        case .primary:
            primaryButtonContent
        case .secondary:
            secondaryButtonContent
        case .get:
            getButtonContent
        case .purchase:
            purchaseButtonContent
        case .text:
            textButtonContent
        case .icon:
            iconButtonContent
        case .destructive:
            destructiveButtonContent
        }
    }
    
    /// 主要按钮内容
    private var primaryButtonContent: some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            } else {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
        }
        .font(AppTheme.Typography.headline)
        .foregroundStyle(.white)
        .frame(maxWidth: width ?? .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .background(isDisabled ? Color.gray : AppTheme.Colors.primary)
        .clipShape(Capsule())
    }
    
    /// 次要按钮内容
    private var secondaryButtonContent: some View {
        HStack(spacing: 8) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                    .scaleEffect(0.8)
            } else {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
        }
        .font(AppTheme.Typography.headline)
        .foregroundStyle(isDisabled ? .gray : AppTheme.Colors.primary)
        .frame(maxWidth: width ?? .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .background(
            Capsule()
                .strokeBorder(isDisabled ? Color.gray : AppTheme.Colors.primary, lineWidth: 1.5)
        )
    }
    
    /// 获取按钮内容 (App Store 风格)
    private var getButtonContent: some View {
        HStack(spacing: 4) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                    .scaleEffect(0.7)
            } else {
                Text(title)
            }
        }
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(AppTheme.Colors.primary)
        .clipShape(Capsule())
    }
    
    /// 购买按钮内容
    private var purchaseButtonContent: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(AppTheme.Colors.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppTheme.Colors.primary.opacity(0.12))
            .clipShape(Capsule())
    }
    
    /// 文字按钮内容
    private var textButtonContent: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(title)
        }
        .font(AppTheme.Typography.body)
        .foregroundStyle(isDisabled ? .gray : AppTheme.Colors.primary)
    }
    
    /// 图标按钮内容
    private var iconButtonContent: some View {
        Image(systemName: icon ?? "circle")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(isDisabled ? .gray : AppTheme.Colors.primary)
            .frame(width: 44, height: 44)
            .background(AppTheme.Colors.Background.gray6)
            .clipShape(Circle())
    }
    
    /// 危险操作按钮内容
    private var destructiveButtonContent: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(title)
        }
        .font(AppTheme.Typography.headline)
        .foregroundStyle(.white)
        .frame(maxWidth: width ?? .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .background(AppTheme.Colors.error)
        .clipShape(Capsule())
    }
}

// MARK: - Preview
#Preview("Button Styles") {
    VStack(spacing: 20) {
        AnimatedButton(title: "主要按钮", style: .primary) {}
        AnimatedButton(title: "次要按钮", style: .secondary) {}
        AnimatedButton(title: "获取", style: .get) {}
        AnimatedButton(title: "¥6.00", style: .purchase) {}
        AnimatedButton(title: "文字按钮", icon: "arrow.right", style: .text) {}
        AnimatedButton(title: "", icon: "heart", style: .icon) {}
        AnimatedButton(title: "删除", icon: "trash", style: .destructive) {}
        AnimatedButton(title: "加载中", style: .primary, isLoading: true) {}
        AnimatedButton(title: "禁用", style: .primary, isDisabled: true) {}
    }
    .padding()
}
