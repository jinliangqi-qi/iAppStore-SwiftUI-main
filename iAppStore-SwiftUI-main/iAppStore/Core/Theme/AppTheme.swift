//
//  AppTheme.swift
//  iAppStore
//
//  iAppStore 应用主题配置
//  定义全局颜色、字体、间距等设计规范
//  兼容 iOS 26 / macOS / iPadOS / Swift 6
//
//  Created by iAppStore on 2026/02/02.
//  Copyright © 2026 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - App Theme
/// 应用主题配置，统一管理设计规范
@MainActor
enum AppTheme {
    
    // MARK: - Colors
    /// 主题色系统
    enum Colors {
        /// 主色调 - App Store 蓝
        static let primary = Color.blue
        /// 次要色调
        static let secondary = Color(uiColor: .secondaryLabel)
        /// 强调色
        static let accent = Color.blue
        /// 成功状态
        static let success = Color.green
        /// 警告状态
        static let warning = Color.orange
        /// 错误状态
        static let error = Color.red
        
        /// 背景色
        enum Background {
            static let primary = Color(uiColor: .systemBackground)
            static let secondary = Color(uiColor: .secondarySystemBackground)
            static let tertiary = Color(uiColor: .tertiarySystemBackground)
            static let grouped = Color(uiColor: .systemGroupedBackground)
            static let groupedSecondary = Color(uiColor: .secondarySystemGroupedBackground)
        }
        
        /// 文字色
        enum Text {
            static let primary = Color(uiColor: .label)
            static let secondary = Color(uiColor: .secondaryLabel)
            static let tertiary = Color(uiColor: .tertiaryLabel)
            static let placeholder = Color(uiColor: .placeholderText)
        }
        
        /// 分隔线
        static let separator = Color(uiColor: .separator)
        
        /// 渐变色
        static let primaryGradient = LinearGradient(
            colors: [Color.blue, Color.blue.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        /// 卡片渐变色（自适应深色模式）
        static let cardGradient = LinearGradient(
            colors: [Color(uiColor: .systemBackground), Color(uiColor: .systemBackground).opacity(0.95)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Typography
    /// 字体系统
    enum Typography {
        /// 大标题
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        /// 标题1
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        /// 标题2
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        /// 标题3
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        /// 正文 - 加粗
        static let headline = Font.system(size: 17, weight: .semibold)
        /// 正文
        static let body = Font.system(size: 17, weight: .regular)
        /// 说明文字
        static let callout = Font.system(size: 16, weight: .regular)
        /// 次要内容
        static let subheadline = Font.system(size: 15, weight: .regular)
        /// 脚注
        static let footnote = Font.system(size: 13, weight: .regular)
        /// 说明
        static let caption1 = Font.system(size: 12, weight: .regular)
        /// 小说明
        static let caption2 = Font.system(size: 11, weight: .regular)
        
        /// 排名数字
        static let rankNumber = Font.system(size: 20, weight: .bold, design: .rounded)
        /// 价格
        static let price = Font.system(size: 14, weight: .semibold)
    }
    
    // MARK: - Spacing
    /// 间距系统
    enum Spacing {
        /// 极小 4pt
        static let xs: CGFloat = 4
        /// 小 8pt
        static let sm: CGFloat = 8
        /// 中等 12pt
        static let md: CGFloat = 12
        /// 默认 16pt
        static let `default`: CGFloat = 16
        /// 大 20pt
        static let lg: CGFloat = 20
        /// 超大 24pt
        static let xl: CGFloat = 24
        /// 特大 32pt
        static let xxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    /// 圆角系统
    enum CornerRadius {
        /// 小圆角 8pt
        static let small: CGFloat = 8
        /// 中等圆角 12pt
        static let medium: CGFloat = 12
        /// 大圆角 16pt
        static let large: CGFloat = 16
        /// App图标圆角 20pt
        static let appIcon: CGFloat = 20
        /// 卡片圆角 24pt
        static let card: CGFloat = 24
        /// 胶囊形
        static let capsule: CGFloat = 100
    }
    
    // MARK: - Icon Sizes
    /// 图标尺寸
    enum IconSize {
        /// 小图标 24pt
        static let small: CGFloat = 24
        /// 中等图标 44pt
        static let medium: CGFloat = 44
        /// 大图标 64pt
        static let large: CGFloat = 64
        /// 超大图标 80pt
        static let xLarge: CGFloat = 80
        /// App详情图标 120pt
        static let detail: CGFloat = 120
    }
    
    // MARK: - Shadows
    /// 阴影系统
    enum Shadow {
        /// 轻微阴影
        static let light = ShadowStyle(
            color: Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 2
        )
        /// 中等阴影
        static let medium = ShadowStyle(
            color: Color.black.opacity(0.1),
            radius: 12,
            x: 0,
            y: 4
        )
        /// 重阴影
        static let heavy = ShadowStyle(
            color: Color.black.opacity(0.15),
            radius: 20,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Animation
    /// 动画配置
    enum Animation {
        /// 快速动画
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.2)
        /// 默认动画
        static let `default` = SwiftUI.Animation.easeInOut(duration: 0.3)
        /// 慢速动画
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        /// 弹性动画
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        /// 轻弹性动画
        static let lightSpring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
        /// 按压效果动画
        static let press = SwiftUI.Animation.spring(response: 0.2, dampingFraction: 0.6)
    }
}

// MARK: - Shadow Style
/// 阴影样式定义
struct ShadowStyle: Sendable {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions
extension View {
    /// 应用轻微阴影
    func lightShadow() -> some View {
        let shadow = AppTheme.Shadow.light
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    /// 应用中等阴影
    func mediumShadow() -> some View {
        let shadow = AppTheme.Shadow.medium
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    /// 应用重阴影
    func heavyShadow() -> some View {
        let shadow = AppTheme.Shadow.heavy
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    /// 卡片样式
    func cardStyle() -> some View {
        self
            .background(AppTheme.Colors.Background.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .lightShadow()
    }
    
    /// 按压缩放效果
    func pressableStyle(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(AppTheme.Animation.press, value: isPressed)
    }
}
