//
//  AppSubscribe.swift
//  iAppStore
//
//  Created by HTC on 2021/12/22.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import Foundation

// MARK: - 日期格式化工具
private enum DateFormatters {
    /// 完整日期时间格式化器
    static let fullDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    /// 简短日期时间格式化器
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter
    }()
    
    /// 将时间戳格式化为完整日期字符串
    static func formatFull(_ timestamp: TimeInterval) -> String {
        fullDateTime.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    /// 将时间戳格式化为简短日期字符串
    static func formatShort(_ timestamp: TimeInterval) -> String {
        shortDateTime.string(from: Date(timeIntervalSince1970: timestamp))
    }
}

/// App订阅数据模型
/// 用于存储用户订阅的App更新信息
struct AppSubscribe: Codable, Sendable {
    /// App的唯一标识ID
    let appId: String
    /// App所属的地区名称
    let regionName: String
    /// 订阅类型（如"版本更新"、"价格变动"等）
    let subscribeType: String
    /// 当前版本号
    let currentVersion: String
    /// 新版本号（可选）
    let newVersion: String?
    /// 开始检查时间戳
    let startTimeStamp: TimeInterval
    /// 结束检查时间戳（可选）
    let endCheckTimeStamp: TimeInterval?
    /// 是否已完成
    let isFinished: Bool
    /// App图标URL（可选）
    let iconURL: String?
    /// App名称
    let trackName: String
    
    // 使用 CodingKeys 保持向后兼容性（兼容旧数据中的拼写错误 "subscripeType"）
    enum CodingKeys: String, CodingKey {
        case appId
        case regionName
        case subscribeType = "subscripeType"  // 兼容旧数据的拼写错误
        case currentVersion
        case newVersion
        case startTimeStamp
        case endCheckTimeStamp
        case isFinished
        case iconURL
        case trackName
    }
    
    // MARK: - 兼容性计算属性
    
    var version: String { currentVersion }
    
    var versionDate: String {
        DateFormatters.formatFull(startTimeStamp)
    }
    
    var subscribeDate: String {
        DateFormatters.formatFull(startTimeStamp)
    }
    
    /// 格式化的订阅时间（MM-dd HH:mm格式）
    var subscribeTime: String {
        DateFormatters.formatShort(startTimeStamp)
    }
    
    /// 格式化的版本发布时间（MM-dd HH:mm格式）
    var versionTime: String {
        DateFormatters.formatShort(startTimeStamp)
    }
    
    /// App图标URL（100x100像素）
    var artworkUrl100: String {
        iconURL ?? "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/6b/66/82/6b66823d-931a-6bae-c4c1-c2dfe9f8e0f0/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/100x100bb.jpg"
    }
    
    /// 兼容性属性
    var artworkURL100: String { artworkUrl100 }
    
    // MARK: - 工厂方法
    
    /// 创建新的订阅模型
    /// - Parameters:
    ///   - appId: App的唯一标识ID
    ///   - regionName: App所属地区名称
    ///   - subscribeType: 订阅类型
    ///   - version: App版本号
    ///   - versionDate: 版本发布日期
    /// - Returns: 返回新创建的AppSubscribe实例
    static func createModel(appId: String, regionName: String, subscribeType: String, version: String, versionDate: String) -> AppSubscribe {
        AppSubscribe(
            appId: appId,
            regionName: regionName,
            subscribeType: subscribeType,
            currentVersion: version,
            newVersion: nil,
            startTimeStamp: Date().timeIntervalSince1970,
            endCheckTimeStamp: nil,
            isFinished: false,
            iconURL: nil,
            trackName: ""
        )
    }
    
    /// 更新订阅模型
    /// - Parameters:
    ///   - app: 原始订阅模型
    ///   - checkTime: 检查时间戳
    ///   - isFinished: 是否已完成
    ///   - newVersion: 新版本号（可选）
    /// - Returns: 返回更新后的AppSubscribe实例
    static func updateModel(app: AppSubscribe, checkTime: TimeInterval, isFinished: Bool, _ newVersion: String?) -> AppSubscribe {
        AppSubscribe(
            appId: app.appId,
            regionName: app.regionName,
            subscribeType: app.subscribeType,
            currentVersion: app.currentVersion,
            newVersion: newVersion,
            startTimeStamp: app.startTimeStamp,
            endCheckTimeStamp: checkTime,
            isFinished: isFinished,
            iconURL: app.iconURL,
            trackName: app.trackName
        )
    }
}

// MARK: - 类型别名（保持向后兼容，兼容旧代码中的拼写错误）
typealias AppSubscripe = AppSubscribe
