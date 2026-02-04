//
//  Constants.swift
//  iAppStore
//
//  应用常量配置
//  地区常量已提取到 RegionConstants.swift
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/20.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import Foundation

// MARK: - App Constants
struct TSMGConstants: Sendable {
    
    // MARK: - Ranking Type Lists
    /// 排行榜类型列表
    static let rankingTypeLists: [String] = [
        "热门免费榜",
        "热门付费榜",
        "畅销榜",
        "新上架榜",
        "新上架的免费榜",
        "新上架的付费榜",
        "热门免费 iPad 榜",
        "热门付费 iPad 榜",
        "畅销的 iPad 榜",
    ]
    
    // MARK: - Ranking Type IDs
    /// 排行榜类型对应的 API ID
    static let rankingTypeListIds: [String: String] = [
        "热门免费榜": "topFreeApplications",
        "热门付费榜": "topPaidApplications",
        "畅销榜": "topGrossingApplications",
        "新上架榜": "newApplications",
        "新上架的免费榜": "newFreeApplications",
        "新上架的付费榜": "newPaidApplications",
        "热门免费 iPad 榜": "topFreeiPadApplications",
        "热门付费 iPad 榜": "topPaidiPadApplications",
        "畅销的 iPad 榜": "topGrossingiPadApplications",
    ]
    
    // MARK: - Category Type Lists
    /// 应用分类列表
    static let categoryTypeLists: [String] = [
        "所有 App",
        "游戏",
        "社交",
        "效率",
        "图书",
        "商务",
        "娱乐",
        "音乐",
        "教育",
        "财务",
        "天气",
        "工具",
        "旅游",
        "体育",
        "购物",
        "生活",
        "医疗",
        "导航",
        "新闻",
        "美食佳饮",
        "健康健美",
        "报刊杂志",
        "参考资料",
        "摄影与录像",
        "图形和设计",
        "软件开发工具",
    ]
    
    // MARK: - Category Type IDs
    /// 应用分类对应的 API ID
    static let categoryTypeListIds: [String: String] = [
        "所有 App": "0",
        "游戏": "6014",
        "社交": "6005",
        "效率": "6007",
        "工具": "6002",
        "娱乐": "6016",
        "购物": "6024",
        "音乐": "6011",
        "新闻": "6009",
        "图书": "6018",
        "教育": "6017",
        "财务": "6015",
        "天气": "6001",
        "旅游": "6003",
        "体育": "6004",
        "生活": "6012",
        "医疗": "6020",
        "导航": "6010",
        "商务": "6000",
        "美食佳饮": "6023",
        "健康健美": "6013",
        "报刊杂志": "6021",
        "参考资料": "6006",
        "摄影与录像": "6008",
        "图形和设计": "6027",
        "软件开发工具": "6026",
    ]
    
    // MARK: - Region Type Aliases (兼容旧代码)
    /// 地区列表 - 引用 TSMGRegionConstants
    static var regionTypeLists: [String] {
        TSMGRegionConstants.regionTypeLists
    }
    
    /// 地区 ID 映射 - 引用 TSMGRegionConstants
    static var regionTypeListIds: [String: String] {
        TSMGRegionConstants.regionTypeListIds
    }
}
