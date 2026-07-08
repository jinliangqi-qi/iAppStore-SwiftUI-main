//
//  FavoritesHome.swift
//  iAppStore
//
//  App收藏页面主视图
//  展示用户收藏的App列表，支持取消收藏和跳转详情
//  兼容 iOS 15+ / macOS 12+ / iPadOS / Swift 6
//
//  Created by iAppStore on 2026/02/02.
//  Copyright © 2026 37 Mobile Games. All rights reserved.
//


import SwiftUI

// MARK: - Favorites Home View
/// App收藏页面主视图
struct FavoritesHome: View {
    
    // MARK: - State
    @StateObject private var favoritesModel = AppFavoritesModel.shared
    @State private var isRefreshing = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.Background.grouped.ignoresSafeArea()
                mainContent
            }
            .navigationTitle("收藏")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear { loadData() }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        if favoritesModel.isLoading && favoritesModel.favorites.isEmpty {
            skeletonListView
        } else if favoritesModel.favorites.isEmpty {
            emptyStateView
        } else {
            favoritesListView
        }
    }
    
    // MARK: - Skeleton List View
    private var skeletonListView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonRow(showRank: false)
                }
            }
            .background(AppTheme.Colors.Background.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .padding(.horizontal, AppTheme.Spacing.default)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        EmptyStateView(type: .noFavorites) {
            loadData()
        }
    }
    
    // MARK: - Favorites List View
    private var favoritesListView: some View {
        List {
            ForEach(favoritesModel.favorites, id: \.trackId) { app in
                NavigationLink {
                    AppDetailView(
                        appId: String(app.trackId),
                        regionName: "中国",
                        item: nil,
                        rank: nil
                    )
                } label: {
                    FavoriteCell(app: app, onUnfavorite: { unfavorite(app) })
                }
                .listRowInsets(EdgeInsets(top: AppTheme.Spacing.sm, leading: AppTheme.Spacing.default,
                                          bottom: AppTheme.Spacing.sm, trailing: AppTheme.Spacing.default))
                .listRowBackground(AppTheme.Colors.Background.primary)
            }
        }
        .listStyle(.plain)
        .refreshable { await refreshData() }
    }
    
    // MARK: - Helper Methods
    private func loadData() {
        Task {
            await favoritesModel.fetchFavoritesDetails()
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        await favoritesModel.fetchFavoritesDetails()
        try? await Task.sleep(nanoseconds: 500_000_000)
        isRefreshing = false
    }
    
    private func unfavorite(_ app: AppDetail) {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        
        favoritesModel.remove(appId: String(app.trackId))
        
        Task {
            await favoritesModel.fetchFavoritesDetails()
        }
    }
}

// MARK: - Favorite Cell
/// 收藏列表单元格组件
struct FavoriteCell: View {
    let app: AppDetail
    let onUnfavorite: () -> Void
    
    @Environment(\.openURL) private var openURL
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // App图标
            AppIconView(
                url: app.artworkUrl100,
                size: 64,
                showBorder: true
            )
            
            // App信息
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(app.trackName)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.Text.primary)
                    .lineLimit(1)
                
                Text(app.artistName)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.Text.secondary)
                    .lineLimit(1)
                
                if app.averageUserRating > 0 {
                    HStack(spacing: 4) {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { star in
                                Image(systemName: star < Int(app.averageUserRating) ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        }
                        
                        Text(String(format: "%.1f", app.averageUserRating))
                            .font(AppTheme.Typography.caption2)
                            .foregroundStyle(AppTheme.Colors.Text.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 取消收藏按钮和获取按钮
            VStack(spacing: AppTheme.Spacing.sm) {
                Button { onUnfavorite() } label: {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.red)
                        .symbolEffect(.bounce, value: UUID())
                }
                
                AnimatedButton(
                    title: (app.price ?? 0) == 0 ? "获取" : app.formattedPrice ?? "",
                    style: (app.price ?? 0) == 0 ? .get : .purchase
                ) {
                    if let url = URL(string: app.trackViewUrl) {
                        openURL(url)
                    }
                }
            }
        }
        .padding(.vertical, AppTheme.Spacing.xs)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppTheme.Animation.press, value: isPressed)
    }
}

// MARK: - Preview
#Preview {
    FavoritesHome()
}

#Preview("Favorite Cell") {
    List {
        FavoriteCell(app: AppDetail.example, onUnfavorite: {})
    }
    .listStyle(.plain)
}