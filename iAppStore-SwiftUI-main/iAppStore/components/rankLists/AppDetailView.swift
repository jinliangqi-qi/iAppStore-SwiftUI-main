//
//  AppDetailView.swift
//  iAppStore
//
//  App详情页面主视图
//  展示应用详细信息、截图预览、描述等
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/17.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - App Detail View
/// App详情页面主视图
struct AppDetailView: View {
    
    // MARK: - Properties
    let appId: String
    let regionName: String
    let item: AppRank?
    let rank: Int?
    
    // MARK: - State
    @StateObject private var appModel = AppDetailModel()
    @State private var isShowingQRCode = false
    @State private var isAppFavorites = false
    @State private var showFullDescription = false
    @State private var selectedScreenshotIndex: Int?
    @Environment(\.openURL) private var openURL
    
    // MARK: - Body
    var body: some View {
        ZStack {
            AppTheme.Colors.Background.grouped.ignoresSafeArea()
            
            Group {
                if appModel.isLoading && appModel.app == nil {
                    loadingView
                } else if let app = appModel.app {
                    detailScrollView(app: app)
                } else {
                    EmptyStateView(type: .networkError) {
                        appModel.searchAppData(appId, nil, regionName)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .navigationBarTrailing) { toolbarButtons } }
        .sheet(isPresented: $isShowingQRCode) { qrCodeSheet }
        .onAppear { loadData() }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.default) {
                HStack(alignment: .top, spacing: AppTheme.Spacing.default) {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.appIcon)
                        .fill(AppTheme.Colors.Background.gray5).frame(width: 120, height: 120).shimmer()
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        RoundedRectangle(cornerRadius: 4).fill(AppTheme.Colors.Background.gray5).frame(height: 24).shimmer()
                        RoundedRectangle(cornerRadius: 4).fill(AppTheme.Colors.Background.gray5).frame(width: 120, height: 16).shimmer()
                        Spacer()
                        RoundedRectangle(cornerRadius: 20).fill(AppTheme.Colors.Background.gray5).frame(height: 44).shimmer()
                    }
                }
                .padding(AppTheme.Spacing.lg)
            }
            .background(AppTheme.Colors.Background.primary)
            Spacer()
        }
    }
    
    // MARK: - Detail Scroll View
    private func detailScrollView(app: AppDetail) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                appHeaderSection(app: app)
                quickInfoSection(app: app)
                // 优先显示 iPhone 截图，如果没有则显示 iPad 截图
                let iphoneScreenshots = app.screenshotUrls ?? []
                let ipadScreenshots = app.ipadScreenshotUrls ?? []
                if !iphoneScreenshots.isEmpty {
                    screenshotsSection(screenshots: iphoneScreenshots, deviceType: "iPhone")
                } else if !ipadScreenshots.isEmpty {
                    screenshotsSection(screenshots: ipadScreenshots, deviceType: "iPad")
                }
                descriptionSection(app: app)
                if let releaseNotes = app.releaseNotes, !releaseNotes.isEmpty {
                    whatsNewSection(app: app, notes: releaseNotes)
                }
                informationSection(app: app)
                developerSection(app: app)
                Color.clear.frame(height: 50)
            }
        }
    }
    
    // MARK: - Header Section
    private func appHeaderSection(app: AppDetail) -> some View {
        VStack(spacing: AppTheme.Spacing.default) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.default) {
                AppIconView(url: app.artworkUrl512, size: 120, showBorder: true, showShadow: true)
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(app.trackName).font(AppTheme.Typography.title2)
                        .foregroundStyle(AppTheme.Colors.Text.primary).lineLimit(2)
                    Text(app.artistName).font(AppTheme.Typography.subheadline)
                        .foregroundStyle(AppTheme.Colors.Text.secondary)
                    if app.averageUserRating > 0 {
                        RatingStarsView(rating: Double(app.averageUserRating), count: app.userRatingCount)
                    }
                    Spacer()
                    Button {
                        if let url = URL(string: app.trackViewUrl) { openURL(url) }
                    } label: {
                        Text((app.price ?? 0) == 0 ? "获取" : app.formattedPrice ?? "")
                            .font(AppTheme.Typography.headline).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, AppTheme.Spacing.md)
                            .background(AppTheme.Colors.primary).clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(AppTheme.Colors.Background.primary)
    }
    
    // MARK: - Quick Info Section
    private func quickInfoSection(app: AppDetail) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                QuickInfoItem(title: "评分", value: String(format: "%.1f", app.averageUserRating),
                              subtitle: FormatHelper.formatRatingCount(app.userRatingCount) + "个评分")
                Divider().frame(height: 40)
                QuickInfoItem(title: "年龄", value: app.contentAdvisoryRating, subtitle: "岁")
                Divider().frame(height: 40)
                QuickInfoItem(title: "排行榜", value: rank != nil ? "#\(rank!)" : "-", subtitle: app.primaryGenreName)
                Divider().frame(height: 40)
                QuickInfoItem(title: "开发者", value: "", subtitle: app.sellerName, icon: "person.crop.square")
                Divider().frame(height: 40)
                QuickInfoItem(title: "语言", value: app.languageCodesISO2A.first ?? "ZH",
                              subtitle: "\(app.languageCodesISO2A.count)种语言")
                Divider().frame(height: 40)
                QuickInfoItem(title: "大小", value: FormatHelper.formatFileSize(app.fileSizeBytes ?? "0"), subtitle: "")
            }
            .padding(.horizontal, AppTheme.Spacing.default)
        }
        .padding(.vertical, AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
    }
    
    // MARK: - Screenshots Section
    private func screenshotsSection(screenshots: [String], deviceType: String = "iPhone") -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                SectionHeader(title: "预览", icon: "photo.on.rectangle.angled")
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: deviceType == "iPhone" ? "iphone" : "ipad")
                        .font(.caption).foregroundStyle(AppTheme.Colors.Text.tertiary)
                    Text(deviceType).font(AppTheme.Typography.caption1)
                        .foregroundStyle(AppTheme.Colors.Text.tertiary)
                }
                .padding(.trailing, AppTheme.Spacing.lg)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(Array(screenshots.enumerated()), id: \.offset) { index, url in
                        ScreenshotCard(url: url) { selectedScreenshotIndex = index }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
        .padding(.vertical, AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
    }
    
    // MARK: - Description Section
    private func descriptionSection(app: AppDetail) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(title: "描述", icon: "text.alignleft")
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(app.description).font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.Text.primary)
                    .lineLimit(showFullDescription ? nil : 4)
                    .animation(AppTheme.Animation.default, value: showFullDescription)
                if app.description.count > 200 {
                    Button {
                        withAnimation(AppTheme.Animation.spring) { showFullDescription.toggle() }
                    } label: {
                        Text(showFullDescription ? "收起" : "更多")
                            .font(AppTheme.Typography.body).foregroundStyle(AppTheme.Colors.primary)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.vertical, AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
    }
    
    // MARK: - What's New Section
    private func whatsNewSection(app: AppDetail, notes: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                SectionHeader(title: "新功能", icon: "sparkles")
                Spacer()
                Text("版本 \(app.version)").font(AppTheme.Typography.caption1)
                    .foregroundStyle(AppTheme.Colors.Text.tertiary).padding(.trailing, AppTheme.Spacing.lg)
            }
            Text(notes).font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.Text.primary).padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.vertical, AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
    }
    
    // MARK: - Information Section
    private func informationSection(app: AppDetail) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(title: "信息", icon: "info.circle")
            VStack(spacing: AppTheme.Spacing.md) {
                InfoRow(title: "提供者", value: app.sellerName)
                InfoRow(title: "大小", value: FormatHelper.formatFileSize(app.fileSizeBytes ?? "0"))
                InfoRow(title: "类别", value: app.genres.joined(separator: ", "))
                InfoRow(title: "兼容性", value: "需要 iOS \(app.minimumOsVersion) 或更高版本")
                InfoRow(title: "语言", value: app.languageCodesISO2A.prefix(5).joined(separator: ", ") + (app.languageCodesISO2A.count > 5 ? " 等" : ""))
                InfoRow(title: "年龄分级", value: app.contentAdvisoryRating)
                InfoRow(title: "价格", value: app.formattedPrice ?? "免费")
                InfoRow(title: "App ID", value: String(app.trackId))
                InfoRow(title: "Bundle ID", value: app.bundleId)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.vertical, AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
    }
    
    // MARK: - Developer Section
    private func developerSection(app: AppDetail) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            SectionHeader(title: "开发者", icon: "person.fill")
            HStack {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(app.artistName).font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.Text.primary)
                    Text("开发者").font(AppTheme.Typography.caption1)
                        .foregroundStyle(AppTheme.Colors.Text.secondary)
                }
                Spacer()
                Button {
                    if let url = URL(string: app.artistViewUrl ?? "") { openURL(url) }
                } label: {
                    Image(systemName: "chevron.right").font(.body)
                        .foregroundStyle(AppTheme.Colors.Text.tertiary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
        .padding(.vertical, AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
    }
    
    // MARK: - Toolbar Buttons
    private var toolbarButtons: some View {
        HStack(spacing: AppTheme.Spacing.default) {
            Button { handleFavorite() } label: {
                Image(systemName: isAppFavorites ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundStyle(isAppFavorites ? .red : AppTheme.Colors.primary)
                    .symbolEffect(.bounce, value: isAppFavorites)
            }
            .accessibilityLabel(isAppFavorites ? "取消收藏" : "收藏")
            .accessibilityHint(isAppFavorites ? "从收藏列表中移除" : "添加到收藏列表")
            Button { isShowingQRCode = true } label: {
                Image(systemName: "qrcode").font(.system(size: 18)).foregroundStyle(AppTheme.Colors.primary)
            }
            .accessibilityLabel("二维码")
            .accessibilityHint("显示下载二维码")
        }
    }
    
    // MARK: - QR Code Sheet
    private var qrCodeSheet: some View {
        QRCodeView(
            title: "扫一扫下载",
            subTitle: "App Store 上的 " + (item?.imName.label ?? appModel.app?.trackName ?? ""),
            qrCodeContent: item?.id.label ?? appModel.app?.trackViewUrl ?? "error",
            isShowingQRCode: $isShowingQRCode
        )
    }
    
    // MARK: - Helper Methods
    private func loadData() {
        isAppFavorites = AppFavoritesModel.shared.search(appId) != nil
        if appModel.app == nil { appModel.searchAppData(appId, nil, regionName) }
    }
    
    private func handleFavorite() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        if isAppFavorites { AppFavoritesModel.shared.remove(appId: appId) }
        else { AppFavoritesModel.shared.add(AppFavorite(appId: appId, regionName: regionName)) }
        withAnimation(AppTheme.Animation.spring) { isAppFavorites.toggle() }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack { AppDetailView(appId: "1669437212", regionName: "中国", item: nil, rank: nil) }
}
