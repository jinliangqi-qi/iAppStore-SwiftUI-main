//
//  SubscriptionAddView.swift
//  iAppStore
//
//  添加订阅视图
//  支持添加版本更新、应用上架、应用下架三种订阅类型
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/27.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Subscription Add View
struct SubscriptionAddView: View {
    
    // MARK: - Properties
    @Binding var isAddPresented: Bool
    @StateObject var subscribeVM: AppSubscribeModel
    
    // MARK: - State
    @State private var subscribeType = 0
    @State private var appleIdText = ""
    @State private var regionName = "中国"
    @State private var isRegionPickerExpanded = false
    @State private var alertType: SubscribeAddAlertType?
    @StateObject private var detailVM = AppDetailModel()
    @FocusState private var isTextFieldFocused: Bool
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.Background.grouped.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        subscribeTypeSection
                        regionSection
                        appIdSection
                        if subscribeType != 1 && detailVM.app != nil { searchResultPreview }
                        confirmButton.padding(.top, AppTheme.Spacing.lg)
                    }
                    .padding(AppTheme.Spacing.default)
                }
            }
            .navigationTitle("添加订阅")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { isAddPresented = false }
                }
            }
            .alert("提示", isPresented: Binding(get: { alertType != nil }, set: { if !$0 { alertType = nil } })) {
                Button("确认", role: .cancel) { alertType = nil }
            } message: {
                Text(alertType?.message ?? "")
            }
        }
    }
    
    // MARK: - Subscribe Type Section
    private var subscribeTypeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label("订阅类型", systemImage: "bell.badge")
                .font(AppTheme.Typography.headline).foregroundStyle(AppTheme.Colors.Text.primary)
            HStack(spacing: AppTheme.Spacing.md) {
                SubscribeTypeCard(title: "版本更新", icon: "arrow.up.circle.fill", color: .blue, isSelected: subscribeType == 0) {
                    withAnimation(AppTheme.Animation.spring) { subscribeType = 0; clearSearchResult() }
                }
                SubscribeTypeCard(title: "应用上架", icon: "checkmark.circle.fill", color: .green, isSelected: subscribeType == 1) {
                    withAnimation(AppTheme.Animation.spring) { subscribeType = 1; clearSearchResult() }
                }
                SubscribeTypeCard(title: "应用下架", icon: "xmark.circle.fill", color: .red, isSelected: subscribeType == 2) {
                    withAnimation(AppTheme.Animation.spring) { subscribeType = 2; clearSearchResult() }
                }
            }
            Text(subscribeTypeDescription).font(AppTheme.Typography.caption1)
                .foregroundStyle(AppTheme.Colors.Text.tertiary).padding(.top, AppTheme.Spacing.xs)
        }
        .padding(AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
    
    private var subscribeTypeDescription: String {
        switch subscribeType {
        case 0: return "监控应用版本更新，当有新版本发布时通知您"
        case 1: return "监控新应用上架，当应用在 App Store 上架时通知您"
        case 2: return "监控应用下架状态，当应用从 App Store 下架时通知您"
        default: return ""
        }
    }
    
    // MARK: - Region Section
    private var regionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label("App 地区", systemImage: "globe.asia.australia.fill")
                .font(AppTheme.Typography.headline).foregroundStyle(AppTheme.Colors.Text.primary)
            Button {
                withAnimation(AppTheme.Animation.spring) { isRegionPickerExpanded.toggle() }
            } label: {
                HStack {
                    Text(regionName).font(AppTheme.Typography.body).foregroundStyle(AppTheme.Colors.Text.primary)
                    Spacer()
                    Image(systemName: isRegionPickerExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption).foregroundStyle(AppTheme.Colors.Text.tertiary)
                }
                .padding(AppTheme.Spacing.md).background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
            }
            .buttonStyle(PlainButtonStyle())
            if isRegionPickerExpanded { regionPickerList.transition(.opacity.combined(with: .move(edge: .top))) }
        }
        .padding(AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
    
    private var regionPickerList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(TSMGConstants.regionTypeLists, id: \.self) { region in
                    HStack {
                        Text(region).font(AppTheme.Typography.body)
                            .foregroundStyle(region == regionName ? AppTheme.Colors.primary : AppTheme.Colors.Text.primary)
                        Spacer()
                        if region == regionName {
                            Image(systemName: "checkmark").font(.body).foregroundStyle(AppTheme.Colors.primary)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md).padding(.vertical, AppTheme.Spacing.sm)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(AppTheme.Animation.spring) { regionName = region; isRegionPickerExpanded = false }
                    }
                    if region != TSMGConstants.regionTypeLists.last { Divider() }
                }
            }
        }
        .frame(maxHeight: 250).background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
    }
    
    // MARK: - App ID Section
    private var appIdSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label("App ID", systemImage: "number")
                .font(AppTheme.Typography.headline).foregroundStyle(AppTheme.Colors.Text.primary)
            HStack(spacing: AppTheme.Spacing.sm) {
                TextField(subscribeType == 1 ? "请输入新 App 的 ID" : "请输入 App ID 进行搜索", text: $appleIdText)
                    .font(AppTheme.Typography.body).keyboardType(.numberPad).focused($isTextFieldFocused)
                    .padding(AppTheme.Spacing.md).background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                    .onSubmit { performSearch() }
                if subscribeType != 1 {
                    Button { performSearch() } label: {
                        Group {
                            if detailVM.isLoading { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)) }
                            else { Image(systemName: "magnifyingglass") }
                        }
                        .frame(width: 20, height: 20).foregroundStyle(.white).padding(AppTheme.Spacing.md)
                        .background(AppTheme.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                    }
                    .buttonStyle(PlainButtonStyle()).disabled(detailVM.isLoading)
                }
            }
            Text(subscribeType == 1 ? "输入即将上架应用的 App ID（可在开发者后台查看）" : "输入 App ID 后点击搜索确认应用信息")
                .font(AppTheme.Typography.caption1).foregroundStyle(AppTheme.Colors.Text.tertiary)
        }
        .padding(AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
    
    // MARK: - Search Result Preview
    private var searchResultPreview: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Label("搜索结果", systemImage: "checkmark.circle")
                .font(AppTheme.Typography.headline).foregroundStyle(.green)
            if let app = detailVM.app {
                HStack(spacing: AppTheme.Spacing.md) {
                    AppIconView(url: app.artworkUrl100, size: 64, showBorder: true)
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(app.trackName).font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.Text.primary).lineLimit(1)
                        Text(app.artistName).font(AppTheme.Typography.subheadline)
                            .foregroundStyle(AppTheme.Colors.Text.secondary).lineLimit(1)
                        Text("当前版本: v\(app.version)").font(AppTheme.Typography.caption1)
                            .foregroundStyle(AppTheme.Colors.Text.tertiary)
                    }
                    Spacer()
                }
                .padding(AppTheme.Spacing.md).background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
            }
            Text("请确认此 App 是您要订阅的应用").font(AppTheme.Typography.caption1)
                .foregroundStyle(AppTheme.Colors.Text.tertiary)
        }
        .padding(AppTheme.Spacing.default)
        .background(AppTheme.Colors.Background.primary)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    // MARK: - Confirm Button
    private var confirmButton: some View {
        AnimatedButton(title: "确认添加", icon: "plus.circle.fill", style: .primary) { handleConfirm() }
    }
    
    // MARK: - Helper Methods
    private func performSearch() {
        guard !appleIdText.isEmpty else { alertType = .searchEmptyError; return }
        hideKeyboard()
        if subscribeType != 1 { detailVM.searchAppData(appleIdText, nil, regionName) }
    }
    
    private func handleConfirm() {
        if appleIdText.isEmpty || (subscribeType != 1 && detailVM.app == nil) { alertType = .parameterError; return }
        if subscribeVM.subscribeExist(appId: appleIdText) { alertType = .existCheckError; return }
        subscribeVM.addSubscribe(appId: appleIdText, regionName: regionName, subscribeType: subscribeType, appDetail: detailVM.app)
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        isAddPresented = false
    }
    
    private func clearSearchResult() { detailVM.app = nil }
    
    private func hideKeyboard() {
        isTextFieldFocused = false
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

// MARK: - Preview
#Preview { SubscriptionAddView(isAddPresented: .constant(true), subscribeVM: AppSubscribeModel()) }
