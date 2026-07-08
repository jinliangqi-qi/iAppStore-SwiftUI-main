//
//  iAppStoreApp.swift
//  iAppStore
//
//  iAppStore 应用程序的主入口点
//  使用SwiftUI的App协议定义应用程序的生命周期和主要场景
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/15.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - App Entry Point
/// iAppStore应用程序的主入口点
@main
struct iAppStoreApp: App {
    
    /// 应用程序初始化方法
    /// 在应用启动时设置全局UI外观
    init() {
        setupAppearance()
    }
    
    /// 应用程序的主场景定义
    var body: some Scene {
        WindowGroup {
            MainTabView()
            // 移除 .preferredColorScheme(.light)，支持系统深色模式
        }
    }
    
    /// 设置应用程序的全局UI外观
    private func setupAppearance() {
        // 导航栏外观配置
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor.systemBackground
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        
        // 标签栏外观配置
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // 全局色调
        UIWindow.appearance().tintColor = UIColor.systemBlue
    }
}

// MARK: - Main Tab View
/// 主TabView，使用现代SwiftUI设计和动画效果
struct MainTabView: View {
    
    /// 当前选中的标签页
    @State private var selectedTab: AppTab = .today
    /// 上一个选中的标签页（用于动画）
    @State private var previousTab: AppTab = .today
    /// 标签页切换动画触发
    @State private var tabSwitchTrigger = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tab.contentView
                    .tabItem {
                        TabItemView(tab: tab, isSelected: selectedTab == tab)
                    }
                    .tag(tab)
            }
        }
        .tint(AppTheme.Colors.primary)
        .onChange(of: selectedTab) { oldValue, newValue in
            // 触觉反馈
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
            
            previousTab = oldValue
            withAnimation(AppTheme.Animation.spring) {
                tabSwitchTrigger.toggle()
            }
        }
    }
}

// MARK: - App Tab
/// 标签页枚举定义
enum AppTab: String, CaseIterable, Sendable {
    case today = "Today"
    case games = "游戏"
    case apps = "App"
    case search = "搜索"
    case subscription = "订阅"
    
    /// 标签页图标
    var icon: String {
        switch self {
        case .today: return "doc.text.image"
        case .games: return "gamecontroller"
        case .apps: return "square.stack.3d.up"
        case .search: return "magnifyingglass"
        case .subscription: return "bell"
        }
    }
    
    /// 选中状态图标
    var selectedIcon: String {
        switch self {
        case .today: return "doc.text.image.fill"
        case .games: return "gamecontroller.fill"
        case .apps: return "square.stack.3d.up.fill"
        case .search: return "sparkle.magnifyingglass"
        case .subscription: return "bell.badge.fill"
        }
    }
    
    /// 标签页对应的内容视图
    @MainActor @ViewBuilder
    var contentView: some View {
        switch self {
        case .today:
            TodayTabView()
        case .games:
            GamesTabView()
        case .apps:
            AppsTabView()
        case .search:
            SearchTabView()
        case .subscription:
            SubscriptionTabView()
        }
    }
}

// MARK: - Tab Item View
/// 自定义Tab项视图（带动画效果）
struct TabItemView: View {
    let tab: AppTab
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                .font(.system(size: 22))
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.bounce, value: isSelected)
            
            Text(tab.rawValue)
                .font(.caption2)
        }
    }
}

// MARK: - Tab Content Views
/// Today页面视图 - 热门排行榜
struct TodayTabView: View {
    var body: some View {
        RankHome(tabType: .today)
    }
}

/// 游戏页面视图 - 游戏排行榜
struct GamesTabView: View {
    var body: some View {
        RankHome(tabType: .games)
    }
}

/// App页面视图 - 应用排行榜
struct AppsTabView: View {
    var body: some View {
        RankHome(tabType: .apps)
    }
}

/// 搜索页面视图
struct SearchTabView: View {
    var body: some View {
        SearchHome()
    }
}

/// 订阅页面视图
struct SubscriptionTabView: View {
    var body: some View {
        SubscriptionHome()
    }
}

// MARK: - Tab Type (for RankHome differentiation)
/// 排行榜类型枚举，用于区分不同Tab页面的默认筛选
enum RankTabType: Sendable {
    case today  // 综合排行
    case games  // 游戏排行
    case apps   // 应用排行
    
    /// 默认排行榜类型
    var defaultRankName: String {
        switch self {
        case .today: return "热门免费榜"
        case .games: return "热门免费游戏"
        case .apps: return "热门免费 App"
        }
    }
    
    /// 默认分类
    var defaultCategory: String {
        switch self {
        case .today: return "所有 App"
        case .games: return "游戏"
        case .apps: return "应用软件"
        }
    }
    
    /// 导航标题
    var navigationTitle: String {
        switch self {
        case .today: return "Today"
        case .games: return "游戏"
        case .apps: return "App"
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}
