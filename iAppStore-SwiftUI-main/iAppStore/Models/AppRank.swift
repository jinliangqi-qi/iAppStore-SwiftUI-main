//
//  AppRank.swift
//  iAppStore
//
//  Created by HTC on 2021/12/18.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - AppRankM
/// App排行榜API响应的根模型
/// 包含iTunes Store RSS Feed的完整数据结构
struct AppRankM: Codable {
    /// RSS Feed数据
    let feed: Feed
}

// MARK: - Feed
/// RSS Feed数据结构
/// 包含排行榜的元数据和App条目列表
struct Feed: Codable {
    /// Feed作者信息
    let author: Author
    /// App排行榜条目数组
    let entry: [AppRank]
    /// Feed图标和ID信息
    let icon, id: Title
    /// Feed相关链接
    let link: [FeedLink]
    /// Feed权限、标题和更新时间信息
    let rights, title, updated: Title
}

// MARK: - Author
/// Feed作者信息
struct Author: Codable {
    /// 作者名称和URI
    let name, uri: Title
}

// MARK: - Title
/// 通用标题结构，包含标签文本
struct Title: Codable {
    /// 标签文本内容
    let label: String
}

// MARK: - Entry
/// App排行榜条目数据模型
/// 包含单个App在排行榜中的完整信息
struct AppRank: Codable {
    /// App分类信息
    let category: Category
    /// App唯一标识信息
    let id: ID
    /// 开发者信息
    let imArtist: IMArtist
    /// 内容类型信息
    let imContentType: IMContentType
    /// App图标图片数组（不同尺寸）
    let imImage: [IMImage]
    /// App名称
    let imName: Title
    /// App价格信息
    let imPrice: IMPrice
    /// App发布日期
    let imReleaseDate: IMReleaseDate
//    let link: [EntryLink]
    /// App描述摘要
    let summary: Title?
    /// 权限信息
    let rights: Title?
    /// App标题
    let title: Title
    
    /// 排名（计算属性，基于数组索引）
    var rank: Int {
        return 1 // 默认值，实际使用时会在列表中设置
    }
    
    /// 自定义JSON键值映射
    /// 将iTunes API的特殊键名映射为Swift属性名
     enum CodingKeys: String, CodingKey {
         case category, id, rights, summary, title//, link
         case imArtist = "im:artist"
         case imContentType = "im:contentType"
         case imImage = "im:image"
         case imName = "im:name"
         case imPrice = "im:price"
         case imReleaseDate = "im:releaseDate"
     }
}

         
// MARK: - Category
struct Category: Codable {
    let attributes: CategoryAttributes
}

// MARK: - CategoryAttributes
struct CategoryAttributes: Codable {
    let imID, label: String
    let scheme: String
    let term: String
    
    //自定义键值名
     enum CodingKeys: String, CodingKey {
        case label, scheme, term
        case imID = "im:id" //关键字替换
    }
}

// MARK: - ID
struct ID: Codable {
    let attributes: IDAttributes
    let label: String
}

// MARK: - IDAttributes
struct IDAttributes: Codable {
    let imBundleID, imID: String
    
    // 自定义键值名
     enum CodingKeys: String, CodingKey {
        case imID = "im:id"
        case imBundleID = "im:bundleId"
    }
}

// MARK: - IMArtist
struct IMArtist: Codable {
    let attributes: IMArtistAttributes?
    let label: String
}

// MARK: - IMArtistAttributes
struct IMArtistAttributes: Codable {
    let href: String
}

// MARK: - IMContentType
struct IMContentType: Codable {
    let attributes: IMContentTypeAttributes
}

// MARK: - IMContentTypeAttributes
struct IMContentTypeAttributes: Codable {
    let label, term: String
}

// MARK: - IMImage
struct IMImage: Codable {
    let attributes: IMImageAttributes
    let label: String
}

// MARK: - IMImageAttributes
struct IMImageAttributes: Codable {
    let height: String
}

// MARK: - IMPrice
struct IMPrice: Codable {
    let attributes: IMPriceAttributes
    let label: String
}

// MARK: - IMPriceAttributes
struct IMPriceAttributes: Codable {
    let amount, currency: String
}

// MARK: - IMReleaseDate
struct IMReleaseDate: Codable {
    let attributes: Title
    let label: String
}

// MARK: - EntryLink
struct EntryLink: Codable {
    let attributes: PurpleAttributes
    let imDuration: Title?
}

// MARK: - PurpleAttributes
struct PurpleAttributes: Codable {
    let href: String
    let rel, type: String
    let imAssetType, title: String?
}

// MARK: - FeedLink
struct FeedLink: Codable {
    let attributes: FluffyAttributes
}

// MARK: - FluffyAttributes
struct FluffyAttributes: Codable {
    let href: String
    let rel: String
    let type: String?
}

// MARK: - AppRank Extension
extension AppRank {
    /// 示例数据，用于预览和测试
    static let example = AppRank(
        category: Category(
            attributes: CategoryAttributes(
                imID: "6002",
                label: "娱乐",
                scheme: "https://itunes.apple.com/us/genre/mobile-software-applications/id6002?mt=8",
                term: "Entertainment"
            )
        ),
        id: ID(
            attributes: IDAttributes(
                imBundleID: "com.example.app",
                imID: "123456789"
            ),
            label: "https://itunes.apple.com/us/app/example-app/id123456789?mt=8&uo=2"
        ),
        imArtist: IMArtist(
            attributes: IMArtistAttributes(href: "https://itunes.apple.com/us/artist/example-developer/id987654321?uo=2"),
            label: "示例开发者"
        ),
        imContentType: IMContentType(
            attributes: IMContentTypeAttributes(
                label: "应用程序",
                term: "Application"
            )
        ),
        imImage: [
            IMImage(
                attributes: IMImageAttributes(height: "53"),
                label: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/example/53x53bb.png"
            ),
            IMImage(
                attributes: IMImageAttributes(height: "75"),
                label: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/example/75x75bb.png"
            ),
            IMImage(
                attributes: IMImageAttributes(height: "100"),
                label: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/example/100x100bb.png"
            )
        ],
        imName: Title(label: "示例应用"),
        imPrice: IMPrice(
            attributes: IMPriceAttributes(amount: "0.00000", currency: "USD"),
            label: "免费"
        ),
        imReleaseDate: IMReleaseDate(
            attributes: Title(label: "2023-12-01T00:00:00-07:00"),
            label: "2023年12月1日"
        ),
        summary: Title(label: "这是一个示例应用的描述，用于展示应用的主要功能和特色。"),
        rights: Title(label: "© 2023 示例开发者"),
        title: Title(label: "示例应用 - 示例开发者")
    )
}

