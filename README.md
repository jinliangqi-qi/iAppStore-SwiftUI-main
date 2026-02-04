# iAppStore - SwiftUI App Store Client

iAppStore 是一个基于 SwiftUI 开发的现代化 iOS 应用程序，旨在模拟和扩展 App Store 的核心功能。它允许用户浏览实时应用排行榜、搜索应用以及订阅感兴趣的应用以获取更新通知。

本项目展示了如何使用 Swift 6 和 SwiftUI 构建复杂的应用程序，集成了现代并发编程 (Async/Await)、网络请求封装以及响应式 UI 设计。

## ✨ 功能特性 (Features)

*   **多维度排行榜 (Rankings)**
    *   支持查看 **Today** (热门)、**游戏**、**App** 三大板块的实时榜单。
    *   支持筛选不同分类：免费榜、付费榜、畅销榜。
    *   支持切换设备类型：iPhone / iPad。
    *   支持切换国家/地区：查看不同区域的 App Store 榜单。
*   **强大的搜索功能 (Search)**
    *   基于 iTunes Search API 的实时应用搜索。
    *   查看搜索结果详情。
*   **应用订阅管理 (App Subscription)**
    *   关注特定应用，追踪其版本更新和价格变动。
    *   本地化存储订阅列表，随时查看关注应用的最新状态。
*   **应用详情页 (App Details)**
    *   展示应用详细信息，包括图标、截图、描述、版本号等。
    *   支持分享应用信息。
*   **现代化 UI/UX**
    *   纯 SwiftUI 编写，适配深色模式 (Dark Mode)。
    *   流畅的转场动画和交互体验。

## 🛠 技术栈 (Tech Stack)

*   **语言**: Swift 6
*   **UI 框架**: SwiftUI
*   **网络**: URLSession, Async/Await
*   **架构**: MVVM (Model-View-ViewModel)
*   **平台要求**: 
    *   iOS 16.0+
    *   macOS 14.0+
    *   iPadOS 16.0+

## 📂 项目结构 (Project Structure)

```
iAppStore/
├── Core/               # 核心组件与通用逻辑
│   ├── Components/     # 通用 UI 组件 (Button, Cell, LoadingView 等)
│   └── Theme/          # 应用主题配置
├── Models/             # 数据模型 (Codable)
│   ├── AppDetail.swift # 应用详情模型
│   ├── AppRank.swift   # 排行榜数据模型
│   └── ...
├── Network/            # 网络层
│   ├── APIService.swift    # iTunes API 请求封装
│   ├── NetworkManager.swift
│   └── ...
├── ViewModels/         # 业务逻辑 (MVVM)
│   ├── AppRankModel.swift
│   ├── AppDetailModel.swift
│   └── ...
├── Shared/             # 共享资源
│   ├── Common/         # 常量定义
│   ├── UI/             # 基础 UI 工具
│   └── extensions/     # Swift 扩展
├── components/         # 功能模块视图
│   ├── rankLists/      # 排行榜相关视图
│   ├── search/         # 搜索相关视图
│   └── subscription/   # 订阅管理相关视图
└── iAppStoreApp.swift  # 应用入口与主 TabView
```

## 🚀 安装与运行 (Installation & Setup)

1.  **克隆项目**
    ```bash
    git clone https://github.com/your-repo/iAppStore-SwiftUI.git
    cd iAppStore-SwiftUI
    ```

2.  **打开项目**
    使用 Xcode 打开 `iAppStore.xcodeproj` 文件。

3.  **构建与运行**
    *   选择目标模拟器 (例如 iPhone 15 Pro)。
    *   按下 `Cmd + R` 运行项目。

## 🌐 API 说明 (API Reference)

本项目使用 Apple iTunes Store RSS Feed 和 Search API 作为数据源。主要封装在 `APIService.swift` 中：

*   **Base URL**: `https://itunes.apple.com/`
*   **Endpoints**:
    *   `rss/topfreeapplications`: 免费应用榜单
    *   `rss/topPaidApplications`: 付费应用榜单
    *   `rss/topGrossingApplications`: 畅销应用榜单
    *   `search`: 应用搜索
    *   `lookup`: 应用详情查询

## 📝 版权信息 (License)

Copyright © 2021 37 Mobile Games. All rights reserved.
