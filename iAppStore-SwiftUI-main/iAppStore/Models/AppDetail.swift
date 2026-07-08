//
//  AppDetail.swift
//  iAppStore
//
//  Created by peak on 2022/1/25.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation

struct Size: Codable, Sendable {
    let width: Double
    let height: Double
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    static var zero: Size { Size(width: 0, height: 0) }
}

// MARK: - AppDetailM
/// App详情API响应的根模型
/// 包含查询结果数量和App详情数组
struct AppDetailM: Codable {
    /// 查询结果的数量
    let resultCount: Int
    /// App详情数组
    let results: [AppDetail]
}

// MARK: - AppDetail
/// App详情数据模型
/// 包含从iTunes Store API获取的完整App信息
struct AppDetail: Codable {
    /// 内容建议信息数组
    let advisories: [String]?
    /// Apple TV截图URL数组
    let appletvScreenshotUrls: [String]?
    /// 开发者ID
    let artistId: Int
    /// 开发者名称
    let artistName: String
    /// 开发者页面URL
    let artistViewUrl: String?
    /// 100x100像素的App图标URL
    let artworkUrl100: String?
    /// 512x512像素的App图标URL
    let artworkUrl512: String
    /// 60x60像素的App图标URL
    let artworkUrl60: String
    /// 平均用户评分
    let averageUserRating: Float
    /// 当前版本的平均用户评分
    let averageUserRatingForCurrentVersion: Float
    /// App的Bundle ID
    let bundleId: String
    /// 内容分级建议
    let contentAdvisoryRating: String
    /// 货币类型
    let currency: String
    /// 当前版本发布日期
    let currentVersionReleaseDate: String
    /// App描述
    let description: String
    /// App特性数组
    let features: [String]
    /// 文件大小（字节）
    let fileSizeBytes: String?
    /// 格式化的价格字符串
    let formattedPrice: String?
    /// 类别ID数组
    let genreIds: [String]
    /// 类别名称数组
    let genres: [String]
    /// iPad截图URL数组
    let ipadScreenshotUrls: [String]?
    /// 是否启用Game Center
    let isGameCenterEnabled: Bool
    /// 是否启用VPP设备许可
    let isVppDeviceBasedLicensingEnabled: Bool
    /// 内容类型
    let kind: String
    /// 支持的语言代码数组（ISO 2A格式）
    let languageCodesISO2A: [String]
    /// 最低iOS版本要求
    let minimumOsVersion: String
    /// 价格
    let price: Double?
    /// 主要类别ID
    let primaryGenreId: Int
    /// 主要类别名称
    let primaryGenreName: String
    /// 首次发布日期
    let releaseDate: String
    /// 版本更新说明
    let releaseNotes: String?
    /// iPhone截图URL数组
    let screenshotUrls: [String]?
    /// 销售商名称
    let sellerName: String
    /// 销售商URL
    let sellerUrl: String?
    /// 支持的设备类型数组
    let supportedDevices: [String]
    /// App名称（审查后）
    let trackCensoredName: String
    /// 内容分级
    let trackContentRating: String
    /// App的唯一标识ID
    let trackId: Int
    /// App名称
    let trackName: String
    /// App Store页面URL
    let trackViewUrl: String
    /// 用户评分总数
    let userRatingCount: Int
    /// 当前版本的用户评分总数
    let userRatingCountForCurrentVersion: Int
    /// 当前版本号
    let version: String
    /// 包装类型
    let wrapperType: String
    
    
    /// 检查App是否支持iPhone设备
    /// - Returns: 如果支持iPhone则返回true
    var isSupportiPhone: Bool {
        return supportedDevices.contains("iPhone5s-iPhone5s") || supportedDevices.contains("iPhoneX-iPhoneX")
    }
    
    /// 检查App是否支持iPad设备
    /// - Returns: 如果支持iPad则返回true
    var isSupportiPad: Bool {
        return supportedDevices.contains("iPad2Wifi-iPad2Wifi") || supportedDevices.contains("iPadPro-iPadPro")
    }
    
    /// 格式化的发布时间（仅显示日期部分）
    /// - Returns: 返回YYYY-MM-DD格式的日期字符串
    var releaseTime: String {
        return releaseDate.prefix(10).description
    }
    
    var currentVersionReleaseTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: currentVersionReleaseDate) as Date? {
            let dateformat = DateFormatter()
            dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateformat.string(from: date)
        } else {
            return currentVersionReleaseDate
        }
    }
    
    /// 格式化的文件大小（以MB为单位）
    /// - Returns: 返回格式化后的文件大小字符串，如"25.6 MB"
    var fileSizeMB: String {
        guard let fileSizeBytes = fileSizeBytes else { return "0 MB" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSizeBytes) ?? 0)
    }
    
    /// 格式化的平均评分（保留一位小数）
    /// - Returns: 返回格式化后的评分字符串，如"4.5"
    var averageRating: String {
        return String(format: "%.1f", averageUserRating)
    }
    
    /// 截图展示大小（纯Swift类型）
    var screenShotSize: Size {
        let width = 200.0
        let defaultSize = Size(width: width, height: width)
        let url = screenshotUrls?.first ?? ""
        let size = url.imageAppleSize()
        guard size != Size.zero else {
            return defaultSize
        }

        let height = size.height / size.width * width
        return Size(width: width, height: height)
    }
    
    static func getNewModel(_ artistId: String) -> AppDetail? {
        guard let id = Int(artistId) else { return nil }
        return AppDetail(advisories: nil, appletvScreenshotUrls: nil, artistId: id, artistName: "", artistViewUrl: nil, artworkUrl100: nil, artworkUrl512: "", artworkUrl60: "", averageUserRating: 0, averageUserRatingForCurrentVersion: 0, bundleId: "", contentAdvisoryRating: "", currency: "", currentVersionReleaseDate: "", description: "", features: [], fileSizeBytes: nil, formattedPrice: nil, genreIds: [], genres: [], ipadScreenshotUrls: [], isGameCenterEnabled: false, isVppDeviceBasedLicensingEnabled: false, kind: "", languageCodesISO2A: [], minimumOsVersion: "", price: 0, primaryGenreId: 0, primaryGenreName: "", releaseDate: "", releaseNotes: nil, screenshotUrls:nil, sellerName: "", sellerUrl: nil, supportedDevices: [], trackCensoredName: "", trackContentRating: "", trackId: 0, trackName: "", trackViewUrl: "", userRatingCount: 0, userRatingCountForCurrentVersion: 0, version: "", wrapperType: "")
    }
    
    /// 示例数据，用于预览和测试
    static let example = AppDetail(
        advisories: ["偶尔/轻微的成人或性暗示题材", "偶尔/轻微的色情内容或裸露"],
        appletvScreenshotUrls: [],
        artistId: 1170416082,
        artistName: "Beijing Microlive Vision Technology Co., Ltd",
        artistViewUrl: "https://apps.apple.com/cn/developer/id1170416082",
        artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/7a/08/16/7a081643-510b-acdb-d84b-088f8d877d8b/AppIcon-0-0-1x_U007emarketing-0-0-0-6-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/100x100bb.jpg",
        artworkUrl512: "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/7a/08/16/7a081643-510b-acdb-d84b-088f8d877d8b/AppIcon-0-0-1x_U007emarketing-0-0-0-6-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/512x512bb.jpg",
        artworkUrl60: "https://is1-ssl.mzstatic.com/image/thumb/Purple116/v4/7a/08/16/7a081643-510b-acdb-d84b-088f8d877d8b/AppIcon-0-0-1x_U007emarketing-0-0-0-6-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/60x60bb.jpg",
        averageUserRating: 4.88,
        averageUserRatingForCurrentVersion: 4.88,
        bundleId: "com.ss.iphone.ugc.Aweme",
        contentAdvisoryRating: "17+",
        currency: "CNY",
        currentVersionReleaseDate: "2023-05-04T09:57:32Z",
        description: "抖音是一个帮助用户表达自我，记录美好生活的短视频平台。\n\n● 记录美好在抖音\n智能匹配音乐、一键卡点视频，还有超多原创特效、滤镜、场景切换帮你一秒变大片，让你的生活轻松记录在抖音！",
        features: ["iosUniversal"],
        fileSizeBytes: "489774080",
        formattedPrice: "免费",
        genreIds: ["6016"],
        genres: ["娱乐"],
        ipadScreenshotUrls: [
            "https://is4-ssl.mzstatic.com/image/thumb/Purple126/v4/10/4a/c0/104ac064-a13a-735a-ac7e-31a9a8be4c94/539c76eb-f80d-41e4-804e-ff2b366f5925_d40e52455be74f44b5e61e54777e4241.jpeg/552x414bb.jpg"
        ],
        isGameCenterEnabled: false,
        isVppDeviceBasedLicensingEnabled: true,
        kind: "software",
        languageCodesISO2A: ["EN", "ZH"],
        minimumOsVersion: "11.0",
        price: 0.00,
        primaryGenreId: 6016,
        primaryGenreName: "Entertainment",
        releaseDate: "2016-09-26T03:28:56Z",
        releaseNotes: "运用全新的功能，让使用更加安全便捷",
        screenshotUrls: [
            "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/7d/82/93/7d8293e9-795f-5500-eefc-27dc035f70d1/d8e59776-5c71-4d6e-bf7d-c093486df192_b8da317377c04a2b8c2b1f8c9b290603.png/392x696bb.png"
        ],
        sellerName: "Beijing Microlive Vision Technology Co., Ltd",
        sellerUrl: nil,
        supportedDevices: ["iPhone5s-iPhone5s", "iPadAir-iPadAir"],
        trackCensoredName: "抖音",
        trackContentRating: "17+",
        trackId: 1142110895,
        trackName: "抖音",
        trackViewUrl: "https://apps.apple.com/cn/app/id1142110895",
        userRatingCount: 46105612,
        userRatingCountForCurrentVersion: 46105612,
        version: "24.8.0",
        wrapperType: "software"
    )
}
