//
//  AppFavorite.swift
//  iAppStore
//
//  Created by HTC on 2021/12/22.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import Foundation

/// App收藏数据模型
/// 用于存储用户收藏的App信息
struct AppFavorite: Codable {
    /// App的唯一标识ID
    let appId: String
    /// App所属的地区名称（如"中国"、"美国"等）
    let regionName: String
}
