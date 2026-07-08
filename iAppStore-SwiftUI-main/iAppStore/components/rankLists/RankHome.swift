//
//  RankHome.swift
//  iAppStore
//
//  排行榜首页主视图
//  展示App Store各类排行榜数据，支持筛选和下拉刷新
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/15.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Rank Home View
struct RankHome: View {
    
    // MARK: - Properties
    var tabType: RankTabType = .today
    
    @AppStorage("kRankTypeName") private var rankName: String = "热门免费榜"
    @AppStorage("kRankCategoryName") private var categoryName: String = "所有 App"
    @AppStorage("kRankRegionName") private var regionName: String = "中国"
    @StateObject private var appRankModel = AppRankModel()
    @State private var isFilterExpanded = false
    @State private var isRefreshing = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.Background.grouped.ignoresSafeArea()
                mainContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { filterButton }
            }
            .alert("错误", isPresented: $appRankModel.isShowAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(appRankModel.alertMsg)
            }
        }
        .onAppear { loadDataIfNeeded() }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        if appRankModel.isLoading && appRankModel.results.isEmpty {
            EnhancedLoadingView(message: "正在获取排行榜")
        } else if appRankModel.results.isEmpty {
            EmptyStateView(type: .noData) {
                appRankModel.fetchRankData(rankName, categoryName, regionName)
            }
        } else {
            rankListView
        }
    }
    
    // MARK: - Rank List View
    private var rankListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                headerSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
                if isFilterExpanded {
                    filterSection
                        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)), removal: .opacity))
                }
                rankCardsSection
            }
        }
        .refreshable { await refreshData() }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // 大标题
            HStack {
                Text(tabType.navigationTitle)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.Text.primary)
                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.default)
            .padding(.top, AppTheme.Spacing.sm)
            
            // 时间和地区信息
            HStack {
                Image(systemName: "clock").font(.caption).foregroundStyle(.tertiary)
                Text(appRankModel.rankUpdated.isEmpty ? "正在同步..." : appRankModel.rankUpdated)
                    .font(AppTheme.Typography.caption1).foregroundStyle(AppTheme.Colors.Text.tertiary)
                Spacer()
                Text("\(regionName) · \(categoryName)")
                    .font(AppTheme.Typography.caption1).foregroundStyle(AppTheme.Colors.Text.secondary)
            }
            .padding(.horizontal, AppTheme.Spacing.default)
            filterTagsView
        }
        .padding(.top, AppTheme.Spacing.md).padding(.bottom, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.Background.primary)
    }
    
    // MARK: - Filter Tags View
    private var filterTagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                FilterTag(title: rankName, icon: "chart.bar.fill", isSelected: true) {
                    withAnimation(AppTheme.Animation.spring) { isFilterExpanded.toggle() }
                }
                FilterTag(title: categoryName, icon: "square.grid.2x2", isSelected: false) {
                    withAnimation(AppTheme.Animation.spring) { isFilterExpanded.toggle() }
                }
                FilterTag(title: regionName, icon: "globe.asia.australia.fill", isSelected: false) {
                    withAnimation(AppTheme.Animation.spring) { isFilterExpanded.toggle() }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.default)
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(spacing: 0) {
            Divider()
            RankSortView(rankName: $rankName, categoryName: $categoryName, regionName: $regionName) { newRankName, newCategoryName, newRegionName in
                withAnimation(AppTheme.Animation.spring) { isFilterExpanded = false }
                appRankModel.fetchRankData(newRankName, newCategoryName, newRegionName)
            }
            .padding(AppTheme.Spacing.default)
            .background(AppTheme.Colors.Background.primary)
            Divider()
        }
    }
    
    // MARK: - Rank Cards Section
    private var rankCardsSection: some View {
        LazyVStack(spacing: 1) {
            ForEach(Array(appRankModel.results.enumerated()), id: \.element.imName.label) { index, item in
                NavigationLink {
                    AppDetailView(appId: item.id.attributes.imID, regionName: regionName, item: item, rank: index + 1)
                } label: {
                    ModernRankCell(index: index, item: item, regionName: regionName)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(AppTheme.Colors.Background.primary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        .padding(.horizontal, AppTheme.Spacing.default).padding(.vertical, AppTheme.Spacing.sm)
    }
    
    // MARK: - Filter Button
    private var filterButton: some View {
        Button {
            withAnimation(AppTheme.Animation.spring) { isFilterExpanded.toggle() }
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        } label: {
            Image(systemName: isFilterExpanded ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .font(.system(size: 20)).symbolRenderingMode(.hierarchical).foregroundStyle(AppTheme.Colors.primary)
        }
    }
    
    // MARK: - Helper Methods
    private func loadDataIfNeeded() {
        if appRankModel.results.isEmpty {
            appRankModel.fetchRankData(rankName, categoryName, regionName)
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        appRankModel.fetchRankData(rankName, categoryName, regionName)
        try? await Task.sleep(nanoseconds: 500_000_000)
        isRefreshing = false
    }
}

// MARK: - Preview
#Preview { RankHome(tabType: .today) }
