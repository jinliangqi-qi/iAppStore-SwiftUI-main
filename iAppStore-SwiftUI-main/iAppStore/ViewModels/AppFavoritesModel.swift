//
//  AppFavoritesModel.swift
//  iAppStore
//
//  App收藏管理器
//  负责管理用户收藏的App列表，使用UserDefaults进行本地存储
//  兼容 iOS 15+ / macOS 12+ / iPadOS / Swift 6
//
//  Created by iHTCboy on 2023/6/24.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//


import Foundation

/// App收藏管理器
/// 负责管理用户收藏的App列表，使用UserDefaults进行本地存储
@MainActor
class AppFavoritesModel: ObservableObject {
    
    /// 单例实例
    public static let shared = AppFavoritesModel()
    
    /// 收藏的App详情列表
    @Published var favorites: [AppDetail] = []
    
    /// 是否正在加载
    @Published var isLoading = false
    
    /// 错误消息
    @Published var errorMessage: String?
    
    /// 搜索指定App是否已收藏
    /// - Parameter appId: App ID
    /// - Returns: 收藏记录，如果未收藏则返回nil
    func search(_ appId: String) -> AppFavorite? {
        let favorites = appFavorites()
        return favorites.first(where: { $0.appId == appId })
    }

    /// 添加App到收藏列表
    /// 如果App已存在则更新，否则新增
    /// - Parameter app: 要收藏的App信息
    func add(_ app: AppFavorite) {
        var favorites = appFavorites()
        if let index = favorites.firstIndex(where: { $0.appId == app.appId }) {
            favorites[index] = app
        } else {
            favorites.append(app)
        }
        saveFavorites(favorites)
    }
    
    /// 从收藏列表中删除指定App
    /// - Parameter appId: 要删除的App ID
    /// - Returns: 删除结果（1：删除成功，0：删除失败，-1：未找到删除元素）
    @discardableResult
    func remove(appId: String) -> Int {
        var favorites = appFavorites()
        if let index = favorites.firstIndex(where: { $0.appId == appId }) {
            favorites.remove(at: index)
            saveFavorites(favorites)
            return 1
        }
        return -1
    }

    /// 获取所有收藏的App列表（仅ID和地区）
    /// 从UserDefaults中读取并解码收藏数据
    /// - Returns: 收藏的App列表
    func appFavorites() -> [AppFavorite] {
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.data(forKey: "AppFavorites") {
            if let decodedData = try? JSONDecoder().decode([AppFavorite].self, from: data) {
                return decodedData
            }
        }
        return []
    }

    /// 保存收藏列表到UserDefaults
    /// 将收藏数据编码后存储到本地
    /// - Parameter favorites: 要保存的收藏列表
    func saveFavorites(_ favorites: [AppFavorite]) {
        let userDefaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favorites) {
            userDefaults.set(encodedData, forKey: "AppFavorites")
        }
    }
    
    /// 获取所有收藏App的详细信息
    /// 从网络获取每个收藏App的详情数据
    func fetchFavoritesDetails() async {
        isLoading = true
        errorMessage = nil
        favorites = []
        
        let favoriteIds = appFavorites()
        if favoriteIds.isEmpty {
            isLoading = false
            return
        }
        
        var details: [AppDetail] = []
        
        for favorite in favoriteIds {
            let regionId = TSMGConstants.regionTypeListIds[favorite.regionName] ?? "cn"
            let result: Result<AppDetailM, APIService.APIError> = await APIService.shared.request(
                endpoint: .lookupApp(appid: favorite.appId, country: regionId)
            )
            
            if case .success(let response) = result {
                if let appDetail = response.results.first {
                    details.append(appDetail)
                }
            }
        }
        
        favorites = details
        isLoading = false
    }
    
    /// 检查App是否已收藏
    /// - Parameter appId: App ID
    /// - Returns: 是否已收藏
    func isFavorite(appId: String) -> Bool {
        return search(appId) != nil
    }
}
