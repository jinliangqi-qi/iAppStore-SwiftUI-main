//
//  AppRankModel.swift
//  iAppStore
//
//  Created by HTC on 2021/12/18.
//

import Foundation
import Combine
import SwiftUI

/// App排行榜数据管理器
/// 负责获取和管理iTunes Store排行榜数据，支持网络状态监控
@MainActor
class AppRankModel: ObservableObject {
    
    /// 排行榜标题
    @Published var rankTitle: String = "排行榜"
    /// 排行榜更新时间
    @Published var rankUpdated: String = ""
    /// 排行榜App列表数据
    @Published var results: [AppRank] = []
    
    /// 警告消息内容
    @Published var alertMsg: String = ""
    /// 是否显示警告弹窗
    @Published var isShowAlert: Bool = false
    /// Combine订阅管理器
    private var cancelable = Set<AnyCancellable>()
    
    /// 数据加载状态
    @Published var isLoading: Bool = false
    
    /// 初始化方法
    /// 设置网络状态监听器
    init() {
        self.addSubscriber()
    }
    
    /// 添加网络状态监听器
    /// 监控网络连接状态变化，并相应更新UI状态
    private func addSubscriber() {
        NetworkStateChecker.shared.publisher
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // 完成处理，暂无特殊操作
            } receiveValue: { [weak self] path in
                Task { @MainActor in
                    switch path.status {
                    case .satisfied:
                        // 网络连接正常
                        self?.isShowAlert = false
                        print("network satisfied.")
                    case .unsatisfied:
                        // 网络连接断开
                        self?.isShowAlert = true
                        self?.alertMsg = "Network unconnected."
                        print("network unsatisfied.")
                    case .requiresConnection:
                        // 网络需要连接
                        self?.isShowAlert = true
                        self?.alertMsg = "Network require connection."
                        print("network require connection.")
                    @unknown default:
                        break
                    }
                }
            }
            .store(in: &cancelable)
    }
    
    /// 获取排行榜数据
    /// - Parameters:
    ///   - rankName: 排行榜类型名称（如"免费榜"、"付费榜"等）
    ///   - categoryName: 分类名称（如"所有类别"、"游戏"等）
    ///   - regionName: 地区名称（如"中国"、"美国"等）
    func fetchRankData(_ rankName: String, _ categoryName: String, _ regionName: String) {
        
        // 根据名称获取对应的ID
        let rankId = TSMGConstants.rankingTypeListIds[rankName]!
        let categoryId = TSMGConstants.categoryTypeListIds[categoryName]!
        let regionId = TSMGConstants.regionTypeListIds[regionName] ?? "cn"
        var endpoint: APIService.Endpoint
        
        // 根据排行榜类型选择对应的API端点
        switch rankId {
        case "topFreeApplications":
            endpoint = APIService.Endpoint.topFreeApplications(cid: categoryId, country: regionId, limit: 200)
        case "topFreeiPadApplications":
            endpoint = APIService.Endpoint.topFreeiPadApplications(cid: categoryId, country: regionId, limit: 200)
        case "topPaidApplications":
            endpoint = APIService.Endpoint.topPaidApplications(cid: categoryId, country: regionId, limit: 200)
        case "topPaidiPadApplications":
            endpoint = APIService.Endpoint.topPaidiPadApplications(cid: categoryId, country: regionId, limit: 200)
        case "topGrossingApplications":
            endpoint = APIService.Endpoint.topGrossingApplications(cid: categoryId, country: regionId, limit: 200)
        case "topGrossingiPadApplications":
            endpoint = APIService.Endpoint.topGrossingiPadApplications(cid: categoryId, country: regionId, limit: 200)
        case "newApplications":
            endpoint = APIService.Endpoint.newApplications(cid: categoryId, country: regionId, limit: 200)
        case "newFreeApplications":
            endpoint = APIService.Endpoint.newFreeApplications(cid: categoryId, country: regionId, limit: 200)
        case "newPaidApplications":
            endpoint = APIService.Endpoint.newPaidApplications(cid: categoryId, country: regionId, limit: 200)
        default:
            // 默认使用免费应用排行榜
            endpoint = APIService.Endpoint.topFreeApplications(cid: categoryId, country: regionId, limit: 200)
        }
        
        // 开始加载数据
        isLoading = true
        
        // 发起API请求
        Task {
            let result: Result<AppRankM, APIService.APIError> = await APIService.shared.request(endpoint: endpoint)
            
            // 结束加载状态
            self.isLoading = false
            
            switch result {
            case let .success(response):
                // 请求成功，更新数据
                self.results = response.feed.entry
                self.rankTitle = response.feed.title.label.components(separatedBy: ["：", ":"]).last ?? "排行榜"
                self.handleUpdated(response.feed.updated.label)
            case .failure(let error):
                // 请求失败，显示错误信息
                print("api reqeust erro: \(error)")
                self.isShowAlert = true
                self.alertMsg = "\(error)";
                break
            }
        }
    }
    
    /// 处理排行榜更新时间格式
    /// 将iTunes API返回的时间字符串转换为本地化的时间格式
    /// - Parameter dateString: iTunes API返回的时间字符串（格式：2021-12-31T17:47:05-07:00）
    private func handleUpdated(_ dateString: String) {
        // 处理时区信息，统一转换为-0800时区
        guard let index = dateString.lastIndex(of: "-") else {
            self.rankUpdated = dateString
            return
        }
        let dateStr = String(dateString[..<index]) + "-0800"
        
        // 创建日期格式化器解析API时间格式
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: dateStr) {
            // 转换为用户友好的时间格式
            let dateformat = DateFormatter()
            dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.rankUpdated = dateformat.string(from: date)
        } else {
            // 解析失败时使用原始字符串
            self.rankUpdated = dateString
        }
    }
    
}
