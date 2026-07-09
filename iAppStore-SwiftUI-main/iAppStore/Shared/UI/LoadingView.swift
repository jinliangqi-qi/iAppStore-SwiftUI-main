//
//  LoadingView.swift
//  iAppStore
//
//  加载视图组件
//  包含常规加载动画和 Shimmer 骨架屏效果
//  兼容 iOS 15+ / macOS 12+ / iPadOS / Swift 6
//
//  Created by peak on 2022/1/30.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//


import SwiftUI

// MARK: - Loading View
/// 标准加载视图组件
struct LoadingView: View {
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    @State private var loadingText: [String] = "Loading...".map { String($0) }
    @State private var counter: Int = 1
    @State private var showLoadingText = false
    
    var body: some View {
        VStack {
            if showLoadingText {
                ProgressView()
                animateText
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { showLoadingText.toggle() }
        .onReceive(timer) { _ in
            withAnimation(.spring()) {
                let lastIndex = loadingText.count - 1
                counter = counter == lastIndex ? 0 : counter + 1
            }
        }
    }
    
    var animateText: some View {
        HStack(spacing: 1) {
            ForEach(loadingText.indices, id: \.self) { index in
                Text(loadingText[index])
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.secondary)
                    .offset(y: counter == index ? -5 : 0)
            }
        }
        .offset(y: 12)
    }
}

// MARK: - Enhanced Loading View
/// 增强型加载视图，支持自定义消息
struct EnhancedLoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppTheme.Colors.primary)
            
            if !message.isEmpty {
                Text(message)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.Text.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Shimmer Effect
/// Shimmer 闪烁动画效果
struct Shimmer: ViewModifier {
    @State private var phase = 0.0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.3), location: 0.5),
                            .init(color: .clear, location: 1)
                        ]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 200)
                .animation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false),
                    value: phase
                )
            )
            .onAppear { phase = 1 }
    }
}

extension View {
    /// 添加 Shimmer 闪烁效果
    func shimmer() -> some View {
        self.modifier(Shimmer())
    }
}

// MARK: - Skeleton Row
/// 骨架屏行组件
struct SkeletonRow: View {
    let showRank: Bool
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            if showRank {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.Background.gray5)
                    .frame(width: 32, height: 24)
                    .shimmer()
            }
            
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.appIcon)
                .fill(AppTheme.Colors.Background.gray5)
                .frame(width: 64, height: 64)
                .shimmer()
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.Background.gray5)
                    .frame(height: 20)
                    .shimmer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Colors.Background.gray5)
                    .frame(height: 14)
                    .shimmer()
                
                HStack(spacing: AppTheme.Spacing.sm) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.Colors.Background.gray5)
                        .frame(width: 60, height: 20)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.Colors.Background.gray5)
                        .frame(width: 40, height: 14)
                        .shimmer()
                }
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.Colors.Background.gray5)
                .frame(width: 60, height: 32)
                .shimmer()
        }
        .padding(.horizontal, AppTheme.Spacing.default)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.Background.primary)
    }
}

// MARK: - Skeleton List
/// 骨架屏列表组件
struct SkeletonList: View {
    let count: Int
    let showRank: Bool
    
    init(count: Int = 5, showRank: Bool = true) {
        self.count = count
        self.showRank = showRank
    }
    
    var body: some View {
        LazyVStack(spacing: 1) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonRow(showRank: showRank)
            }
        }
        .background(AppTheme.Colors.Background.primary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        .padding(.horizontal, AppTheme.Spacing.default)
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}

// MARK: - Preview
#Preview {
    LoadingView()
}


#Preview("Skeleton Row") {
    SkeletonRow(showRank: true)
}

#Preview("Skeleton List") {
    SkeletonList(count: 5)
}
