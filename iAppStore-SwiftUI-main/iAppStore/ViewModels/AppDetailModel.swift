//
//  AppDetailModel.swift
//  iAppStore
//
//  Created by HTC on 2021/12/18.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import Foundation

/// App详情数据管理器
/// 负责获取和管理App详情信息，支持通过App ID或关键词搜索
@MainActor
class AppDetailModel: ObservableObject {
    
    /// 当前选中的App详情信息
    @Published var app: AppDetail? = nil
    
    /// 搜索结果列表
    @Published var results: [AppDetail] = []
    
    /// 加载状态标识
    @Published var isLoading: Bool = false
    
    /// 搜索App数据
    /// 支持通过App ID或关键词搜索App信息
    /// - Parameters:
    ///   - appId: App ID（可选）
    ///   - keyWord: 搜索关键词（可选）
    ///   - regionName: 地区名称
    func searchAppData(_ appId: String?, _ keyWord: String?, _ regionName: String) {
        
        let regionId = TSMGConstants.regionTypeListIds[regionName] ?? "cn"
        
        guard let appid = appId, !appid.isEmpty else {
            guard let word = keyWord, !word.isEmpty, let encodeword = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
            }
            performSearch(endpoint: APIService.Endpoint.searchApp(word: encodeword, country: regionId, limit: 200), regionId: regionId, isAppIdQuery: false, keyWord: word)
            return
        }
        
        performSearch(endpoint: APIService.Endpoint.lookupApp(appid: appid, country: regionId), regionId: regionId, isAppIdQuery: true, keyWord: nil)
    }
    
    private func performSearch(endpoint: APIService.Endpoint, regionId: String, isAppIdQuery: Bool, keyWord: String?) {
        isLoading = true
        
        Task { [weak self] in
            guard let self = self else { return }
            let result: Result<AppDetailM, APIService.APIError> = await APIService.shared.request(endpoint: endpoint)
            
            self.isLoading = false
            
            switch result {
            case let .success(response):
                self.results = response.results
                
                if isAppIdQuery {
                    self.app = response.results.first
                }
                
                if let word = keyWord {
                    await self.lookupBundleId(word: word, regionId: regionId)
                }
            case .failure(_):
                break
            }
        }
    }
    
    /// 通过Bundle ID查询App信息
    /// 用于补充关键词搜索结果，提高搜索准确性
    /// - Parameters:
    ///   - word: 搜索关键词（作为Bundle ID使用）
    ///   - regionId: 地区ID
    func lookupBundleId(word: String, regionId: String) async {
        // URL编码处理
        guard let bundleId = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        // 创建Bundle ID查询端点
        let endpoint = APIService.Endpoint.lookupBundleId(appid: bundleId, country: regionId)
        
        // 发起API请求
        let result: Result<AppDetailM, APIService.APIError> = await APIService.shared.request(endpoint: endpoint)
        switch result {
        case let .success(response):
            // 如果找到匹配的App，插入到结果列表顶部
            if let app = response.results.first {
                self.results.insert(app, at: 0)
            }
        case .failure(_):
            break
        }
    }
    
    /// 通过App ID查询App详情
    /// 用于获取指定App的详细信息并添加到结果列表
    /// - Parameters:
    ///   - appId: App ID
    ///   - regionName: 地区名称
    func lookupAppId(_ appId: String, _ regionName: String) {
        // 获取地区ID
        let regionId = TSMGConstants.regionTypeListIds[regionName] ?? "cn"
        let endpoint = APIService.Endpoint.lookupApp(appid: appId, country: regionId)
        
        // 发起API请求
        Task {
            let result: Result<AppDetailM, APIService.APIError> = await APIService.shared.request(endpoint: endpoint)
            switch result {
            case let .success(response):
                // 如果找到App信息，添加到结果列表末尾
                if let app = response.results.first {
                    self.results.append(app)
                }
            case .failure(_):
                break
            }
        }
    }
}
