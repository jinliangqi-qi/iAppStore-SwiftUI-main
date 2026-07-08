//
//  AppSubscribeModel.swift
//  iAppStore
//
//  Created by HTC on 2022/1/1.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation
@preconcurrency import Combine

/// App订阅管理器
/// 负责管理App订阅功能，包括版本更新、上架、下架等状态监控
@MainActor
class AppSubscribeModel: ObservableObject {
        
    /// 订阅列表
    /// 当数据发生变化时自动保存到本地文件
    @Published private(set) var subscribes: [AppSubscribe] {
        didSet {
            saveSubscribes()
        }
    }
    
    /// 定时器取消器
    private var timerCancellable: AnyCancellable?
    
    /// 检查间隔时间（秒）
    private let interval: TimeInterval = 30
    
    /// 请求间隔时间（秒）- 用于避免并发请求风暴
    private let requestDelay: TimeInterval = 2
    
    /// 是否正在检查中
    private var isChecking = false
    
    /// 本地存储模型名称（保持与旧数据兼容，兼容旧代码中的拼写错误 "Subscripe"）
    private let modelName = "AppSubscripeModel"
    
    /// 本地存储文件夹名称（保持与旧数据兼容，兼容旧代码中的拼写错误 "Subscripe"）
    private let folderName = "AppSubscripe"
    
    /// 初始化方法
    /// 加载本地存储的订阅记录并启动定时检查
    init() {
        // 从本地文件加载历史订阅记录
        subscribes = LocalFileManager.instance.getModel(modelName: modelName, folderName: folderName)
        
        // 使用 Combine Timer 替代传统 Timer，避免内存泄漏
        timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handleTimerTick()
                }
            }
    }
    
    /// 析构方法
    /// 清理定时器资源
    nonisolated deinit {
        // 定时器会随着对象销毁自动取消
    }
    
    /// 清理资源（手动调用）
    func cleanup() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    // MARK: Public
    
    /// 删除指定位置的订阅
    /// - Parameter indexSet: 要删除的索引集合
    func removeAt(indexSet: IndexSet) {
        subscribes.remove(atOffsets: indexSet)
    }
    
    /// 添加新的App订阅
    /// - Parameters:
    ///   - appId: App ID
    ///   - regionName: 地区名称
    ///   - subscribeType: 订阅类型（0:版本更新, 1:应用上架, 2:应用下架）
    ///   - appDetail: App详情信息（可选）
    func addSubscribe(appId: String, regionName: String, subscribeType: Int, appDetail: AppDetail?) {
        let subscribeTypeString = subscribeType == 0 ? "版本更新" : (subscribeType == 1 ? "应用上架" : "应用下架")
        let subscribe = AppSubscribe(
            appId: appId,
            regionName: regionName,
            subscribeType: subscribeTypeString,
            currentVersion: appDetail?.version ?? "",
            newVersion: nil as String?,
            startTimeStamp: Date().timeIntervalSince1970,
            endCheckTimeStamp: nil as TimeInterval?,
            isFinished: false,
            iconURL: appDetail?.artworkUrl100,
            trackName: appDetail?.trackName ?? ""
        )
        
        subscribes.append(subscribe)
    }
    
    /// 检查指定App是否已存在订阅
    /// - Parameter appId: App ID
    /// - Returns: 是否存在订阅
    func subscribeExist(appId: String) -> Bool {
        return subscribes.contains(where: { $0.appId == appId })
    }
    
    // MARK: Private
    
    private func handleTimerTick() {
        guard !isChecking else { return }
        isChecking = true
        
        Task { [weak self] in
            guard let self = self else { return }
            let pendingSubscribes = self.subscribes.enumerated().filter { !$0.element.isFinished }
            
            for (index, app) in pendingSubscribes {
                await self.checkStatus(app, index: index)
                try? await Task.sleep(nanoseconds: UInt64(self.requestDelay * 1_000_000_000))
            }
            
            self.isChecking = false
        }
    }
    
    private func checkStatus(_ app: AppSubscribe, index: Int) async {
        let regionId = TSMGConstants.regionTypeListIds[app.regionName] ?? "cn"
        let endpoint: APIService.Endpoint = APIService.Endpoint.lookupApp(appid: app.appId, country: regionId)
        
        let result: Result<AppDetailM, APIService.APIError> = await APIService.shared.request(endpoint: endpoint)
        
        switch result {
        case let .success(response):
            switch app.subscribeType {
                case "版本更新":
                    if response.resultCount > 0, let model = response.results.first {
                        if app.currentVersion != model.version {
                            let new = AppSubscribe.updateModel(app: app, checkTime: Date().timeIntervalSince1970, isFinished: true, model.version)
                            self.subscribes[index] = new
                            return
                        }
                    }
                    
                    let new = AppSubscribe.updateModel(app: app, checkTime: Date().timeIntervalSince1970, isFinished: false, nil)
                    self.subscribes[index] = new
                    
                case "应用上架":
                    if response.resultCount > 0, let model = response.results.first {
                        let new = AppSubscribe.updateModel(app: app, checkTime: Date().timeIntervalSince1970, isFinished: true, model.version)
                        self.subscribes[index] = new
                    } else {
                        let new = AppSubscribe.updateModel(app: app, checkTime: Date().timeIntervalSince1970, isFinished: false, nil)
                        self.subscribes[index] = new
                    }
                    
                case "应用下架":
                    if response.resultCount == 0 {
                        let new = AppSubscribe.updateModel(app: app, checkTime: Date().timeIntervalSince1970, isFinished: true, nil)
                        self.subscribes[index] = new
                    } else {
                        let new = AppSubscribe.updateModel(app: app, checkTime: Date().timeIntervalSince1970, isFinished: false, nil)
                        self.subscribes[index] = new
                    }
                    
                default:
                    break
            }
        case .failure(_):
            break
        }
    }
    
    private func saveSubscribes() {
        LocalFileManager.instance.saveModel(model: subscribes, modelName: modelName, folderName: folderName)
    }
    
}

// MARK: - 类型别名（保持向后兼容，兼容旧代码中的拼写错误）
typealias AppSubscripeModel = AppSubscribeModel
