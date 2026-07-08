//
//  AppIconView.swift
//  iAppStore
//
//  通用App图标组件
//  支持异步加载、占位图、圆角等功能
//  兼容 iOS 26 / macOS / iPadOS / Swift 6
//
//  Created by iAppStore on 2026/02/02.
//  Copyright © 2026 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - App Icon View
/// 通用App图标视图组件
/// 提供一致的App图标展示样式，支持多种尺寸
struct AppIconView: View {
    
    // MARK: - Properties
    
    /// 图标URL
    let url: String?
    /// 图标尺寸
    let size: CGFloat
    /// 圆角大小（默认根据尺寸自动计算）
    var cornerRadius: CGFloat?
    /// 是否显示边框
    var showBorder: Bool = false
    /// 是否添加阴影
    var showShadow: Bool = false
    
    // MARK: - Computed Properties
    
    /// 计算圆角大小（App Store 风格：约为尺寸的 22%）
    private var calculatedCornerRadius: CGFloat {
        cornerRadius ?? (size * 0.22)
    }
    
    // MARK: - Body
    
    var body: some View {
        AsyncImageLoader(
            url: URL(string: url ?? ""),
            placeholder: { placeholderView },
            image: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        )
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: calculatedCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: calculatedCornerRadius, style: .continuous)
                .strokeBorder(Color.black.opacity(0.1), lineWidth: showBorder ? 0.5 : 0)
        )
        .if(showShadow) { view in
            view.lightShadow()
        }
        .accessibilityLabel("应用图标")
        .accessibilityHidden(url == nil)
    }
    
    // MARK: - Placeholder Views
    
    /// 加载中占位视图
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: calculatedCornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [AppTheme.Colors.Background.gray5, AppTheme.Colors.Background.gray6],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "app.fill")
                    .font(.system(size: size * 0.3))
                    .foregroundStyle(.tertiary)
            )
            .shimmer()
    }
    
    /// 加载失败占位视图
    private var errorPlaceholderView: some View {
        RoundedRectangle(cornerRadius: calculatedCornerRadius, style: .continuous)
            .fill(AppTheme.Colors.Background.gray5)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: size * 0.3))
                    .foregroundStyle(.tertiary)
            )
    }
}

// MARK: - View Extensions
extension View {
    /// 条件性修饰器
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview
#Preview("App Icons") {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            AppIconView(
                url: "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/c6/91/90/c69190cc-b245-f35c-a7f1-7f3b10d6c3e0/AppIcon-0-1x_U007emarketing-0-7-0-85-220.png/100x100bb.jpg",
                size: 40
            )
            
            AppIconView(
                url: "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/c6/91/90/c69190cc-b245-f35c-a7f1-7f3b10d6c3e0/AppIcon-0-1x_U007emarketing-0-7-0-85-220.png/100x100bb.jpg",
                size: 60,
                showBorder: true
            )
            
            AppIconView(
                url: "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/c6/91/90/c69190cc-b245-f35c-a7f1-7f3b10d6c3e0/AppIcon-0-1x_U007emarketing-0-7-0-85-220.png/100x100bb.jpg",
                size: 80,
                showShadow: true
            )
        }
        
        // 占位图状态
        HStack(spacing: 16) {
            AppIconView(url: nil, size: 60)
            AppIconView(url: "invalid", size: 60)
        }
    }
    .padding()
}
