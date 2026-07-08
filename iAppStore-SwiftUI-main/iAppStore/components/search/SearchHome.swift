//
//  SearchHome.swift
//  iAppStore
//
//  搜索页面主视图
//  提供App搜索功能，支持实时搜索和地区筛选
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/15.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Search Home View
struct SearchHome: View {
    
    // MARK: - State
    @State private var searchText = ""
    @AppStorage("kSearchRegionName") private var regionName: String = "中国"
    @State private var isRegionPickerPresented = false
    @FocusState private var isSearchFocused: Bool
    @StateObject private var appModel = AppDetailModel()
    @AppStorage("searchHistory") private var searchHistoryRaw: String = ""
    private var searchHistory: [String] {
        get {
            guard let data = searchHistoryRaw.data(using: .utf8),
                  let array = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return array
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                searchHistoryRaw = string
            }
        }
    }
    private let hotSearchTerms = ["微信", "抖音", "王者荣耀", "支付宝", "淘宝", "京东", "美团", "饿了么"]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.Background.grouped.ignoresSafeArea()
                mainContent
            }
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { regionButton }
            }
            .sheet(isPresented: $isRegionPickerPresented) {
                RegionPickerSheet(selectedRegion: $regionName, onRegionChanged: {
                    if !searchText.isEmpty { performSearch() }
                })
            }
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            searchBar
            if searchText.isEmpty {
                searchSuggestionsView
            } else if appModel.isLoading {
                EnhancedLoadingView(message: "正在搜索").frame(maxHeight: .infinity)
            } else if appModel.results.isEmpty {
                EmptyStateView(type: .noSearchResults)
            } else {
                searchResultsList
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "magnifyingglass").font(.body).foregroundStyle(AppTheme.Colors.Text.tertiary)
                TextField("游戏、App、故事等", text: $searchText)
                    .font(AppTheme.Typography.body).focused($isSearchFocused).submitLabel(.search)
                    .onSubmit { performSearch(); saveSearchHistory() }
                if !searchText.isEmpty {
                    Button {
                        withAnimation(AppTheme.Animation.fast) { searchText = ""; appModel.results = [] }
                    } label: {
                        Image(systemName: "xmark.circle.fill").font(.body).foregroundStyle(AppTheme.Colors.Text.tertiary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md).padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.Background.gray6).clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
            
            if isSearchFocused || !searchText.isEmpty {
                Button("取消") {
                    withAnimation(AppTheme.Animation.fast) { searchText = ""; appModel.results = []; isSearchFocused = false }
                    hideKeyboard()
                }
                .font(AppTheme.Typography.body).foregroundStyle(AppTheme.Colors.primary)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .padding(.horizontal, AppTheme.Spacing.default).padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.Background.primary)
        .animation(AppTheme.Animation.fast, value: isSearchFocused)
    }
    
    // MARK: - Region Button
    private var regionButton: some View {
        Button { isRegionPickerPresented = true } label: {
            HStack(spacing: 4) {
                Image(systemName: "globe.asia.australia.fill").font(.caption)
                Text(regionName).font(AppTheme.Typography.caption1)
            }
            .foregroundStyle(AppTheme.Colors.primary)
        }
    }
    
    // MARK: - Search Suggestions View
    private var searchSuggestionsView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                if !searchHistory.isEmpty { searchHistorySection }
                hotSearchSection
            }
            .padding(.vertical, AppTheme.Spacing.default)
        }
    }
    
    // MARK: - Search History Section
    private var searchHistorySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("最近搜索").font(AppTheme.Typography.headline).foregroundStyle(AppTheme.Colors.Text.primary)
                Spacer()
                Button {
                    withAnimation(AppTheme.Animation.default) {
                        searchHistory = []
                    }
                } label: {
                    Text("清除").font(AppTheme.Typography.subheadline).foregroundStyle(AppTheme.Colors.primary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.default)
            
            FlowLayout(spacing: AppTheme.Spacing.sm) {
                ForEach(searchHistory.prefix(10), id: \.self) { term in
                    SearchTag(title: term, icon: "clock") { searchText = term; performSearch() }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.default)
        }
    }
    
    // MARK: - Hot Search Section
    private var hotSearchSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("热门搜索").font(AppTheme.Typography.headline)
                .foregroundStyle(AppTheme.Colors.Text.primary).padding(.horizontal, AppTheme.Spacing.default)
            
            FlowLayout(spacing: AppTheme.Spacing.sm) {
                ForEach(Array(hotSearchTerms.enumerated()), id: \.offset) { index, term in
                    SearchTag(title: term, icon: index < 3 ? "flame.fill" : nil, iconColor: index < 3 ? .orange : nil) {
                        searchText = term; performSearch(); saveSearchHistory()
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.default)
        }
    }
    
    // MARK: - Search Results List
    private var searchResultsList: some View {
        List {
            ForEach(Array(appModel.results.enumerated()), id: \.element.trackId) { index, item in
                NavigationLink {
                    AppDetailView(appId: String(item.trackId), regionName: regionName, item: nil, rank: nil)
                } label: {
                    SearchResultCell(index: index, item: item)
                }
                .listRowInsets(EdgeInsets(top: AppTheme.Spacing.sm, leading: AppTheme.Spacing.default,
                                         bottom: AppTheme.Spacing.sm, trailing: AppTheme.Spacing.default))
                .listRowBackground(AppTheme.Colors.Background.primary)
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
    }
    
    // MARK: - Helper Methods
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        appModel.searchAppData(nil, searchText, regionName)
    }
    
    private func saveSearchHistory() {
        guard !searchText.isEmpty else { return }
        var history = searchHistory
        history.removeAll { $0 == searchText }
        history.insert(searchText, at: 0)
        if history.count > 20 { history = Array(history.prefix(20)) }
        searchHistory = history
    }
    
    private func hideKeyboard() {
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

// MARK: - Preview
#Preview { SearchHome() }
