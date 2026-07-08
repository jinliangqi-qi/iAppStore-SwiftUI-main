//
//  SubscriptionHome.swift
//  iAppStore
//
//  订阅管理页面主视图
//  管理App版本更新、上架、下架的订阅监控
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/15.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Subscription Home View
struct SubscriptionHome: View {
    
    // MARK: - State
    @State private var isAddPresented = false
    @StateObject private var subscribeVM = AppSubscribeModel()
    @State private var selectedFilter: SubscriptionFilter = .all
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.Background.grouped.ignoresSafeArea()
                if subscribeVM.subscribes.isEmpty { emptyView }
                else { subscriptionListView }
            }
            .navigationTitle("订阅监控")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { addButton }
            }
            .sheet(isPresented: $isAddPresented) {
                SubscriptionAddView(isAddPresented: $isAddPresented, subscribeVM: subscribeVM)
            }
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()
            ZStack {
                Circle().stroke(AppTheme.Colors.primary.opacity(0.2), lineWidth: 2).frame(width: 140, height: 140)
                Circle().fill(AppTheme.Colors.Background.secondary).frame(width: 120, height: 120)
                Image(systemName: "bell.badge")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(AppTheme.Colors.Text.tertiary)
                    .symbolEffect(.pulse, options: .repeating)
            }
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("暂无订阅").font(AppTheme.Typography.title3).foregroundStyle(AppTheme.Colors.Text.primary)
                Text("添加App订阅后，系统会自动监控应用状态变化")
                    .font(AppTheme.Typography.body).foregroundStyle(AppTheme.Colors.Text.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, AppTheme.Spacing.xl)
            }
            AnimatedButton(title: "添加订阅", icon: "plus", style: .primary, width: 160) { isAddPresented = true }
            Spacer()
            featureExplanation
        }
        .padding(.bottom, AppTheme.Spacing.xl)
    }
    
    // MARK: - Feature Explanation
    private var featureExplanation: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text("支持的订阅类型").font(AppTheme.Typography.caption1).foregroundStyle(AppTheme.Colors.Text.tertiary)
            HStack(spacing: AppTheme.Spacing.lg) {
                FeatureItem(icon: "arrow.up.circle.fill", title: "版本更新", color: .blue)
                FeatureItem(icon: "checkmark.circle.fill", title: "应用上架", color: .green)
                FeatureItem(icon: "xmark.circle.fill", title: "应用下架", color: .red)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.default)
    }
    
    // MARK: - Subscription List View
    private var subscriptionListView: some View {
        VStack(spacing: 0) {
            filterSection
            List {
                ForEach(filteredSubscriptions, id: \.startTimeStamp) { item in
                    NavigationLink {
                        AppDetailView(appId: String(item.appId), regionName: item.regionName, item: nil, rank: nil)
                    } label: {
                        SubscriptionCell(item: item)
                    }
                    .listRowInsets(EdgeInsets(top: AppTheme.Spacing.sm, leading: AppTheme.Spacing.default,
                                             bottom: AppTheme.Spacing.sm, trailing: AppTheme.Spacing.default))
                    .listRowBackground(AppTheme.Colors.Background.primary)
                }
                .onDelete { indexSet in deleteSubscriptions(at: indexSet) }
            }
            .listStyle(.plain)
            .refreshable { await refreshSubscriptions() }
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(SubscriptionFilter.allCases, id: \.self) { filter in
                    FilterChip(title: filter.title, count: countForFilter(filter), isSelected: selectedFilter == filter) {
                        withAnimation(AppTheme.Animation.spring) { selectedFilter = filter }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.default).padding(.vertical, AppTheme.Spacing.sm)
        }
        .background(AppTheme.Colors.Background.primary)
    }
    
    /// 筛选后的订阅列表
    private var filteredSubscriptions: [AppSubscribe] {
        switch selectedFilter {
        case .all: return subscribeVM.subscribes
        case .pending: return subscribeVM.subscribes.filter { !$0.isFinished }
        case .completed: return subscribeVM.subscribes.filter { $0.isFinished }
        case .versionUpdate: return subscribeVM.subscribes.filter { $0.subscribeType == "版本更新" }
        case .launch: return subscribeVM.subscribes.filter { $0.subscribeType == "应用上架" }
        case .removal: return subscribeVM.subscribes.filter { $0.subscribeType == "应用下架" }
        }
    }
    
    /// 获取筛选器对应的数量
    private func countForFilter(_ filter: SubscriptionFilter) -> Int {
        switch filter {
        case .all: return subscribeVM.subscribes.count
        case .pending: return subscribeVM.subscribes.filter { !$0.isFinished }.count
        case .completed: return subscribeVM.subscribes.filter { $0.isFinished }.count
        case .versionUpdate: return subscribeVM.subscribes.filter { $0.subscribeType == "版本更新" }.count
        case .launch: return subscribeVM.subscribes.filter { $0.subscribeType == "应用上架" }.count
        case .removal: return subscribeVM.subscribes.filter { $0.subscribeType == "应用下架" }.count
        }
    }
    
    // MARK: - Add Button
    private var addButton: some View {
        Button {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            isAddPresented = true
        } label: {
            Image(systemName: "plus.circle.fill").font(.system(size: 22))
                .foregroundStyle(AppTheme.Colors.primary).symbolEffect(.bounce, value: isAddPresented)
        }
    }
    
    // MARK: - Helper Methods
    private func deleteSubscriptions(at offsets: IndexSet) {
        let indicesToDelete = offsets.map { filteredSubscriptions[$0] }
        for item in indicesToDelete {
            if let index = subscribeVM.subscribes.firstIndex(where: { $0.startTimeStamp == item.startTimeStamp }) {
                subscribeVM.removeAt(indexSet: IndexSet([index]))
            }
        }
    }
    
    private func refreshSubscriptions() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}

// MARK: - Preview
#Preview { SubscriptionHome() }
