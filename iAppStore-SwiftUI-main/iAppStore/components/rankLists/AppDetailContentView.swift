//
//  AppDetailContentView.swift
//  iAppStore
//
//  App 详情内容主视图
//  子视图组件已提取到 Core/Components/AppDetailSubviews.swift
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/23.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - Alert Type
enum AppDetailAlertType: Identifiable {
    case copyBundleId
    var id: Int { hashValue }
}

// MARK: - Main Content View
struct AppDetailContentView: View {
    @StateObject var appModel = AppDetailModel()
    @State private var alertType: AppDetailAlertType?

    var body: some View {
        if appModel.app == nil {
            Rectangle()
                .overlay(Color(uiColor: .systemGroupedBackground))
                .cornerRadius(20)
                .padding(.all)
                .animation(.easeInOut, value: appModel.app == nil)
                .transition(.opacity)
        } else {
            ScrollView {
                // Header Section
                AppDetailHeaderView(appModel: appModel, alertType: $alertType)
                    .contextMenu {
                        AppContextMenu(
                            appleID: String(appModel.app?.trackId ?? 0),
                            bundleID: appModel.app?.bundleId,
                            appUrl: appModel.app?.trackViewUrl,
                            developerUrl: appModel.app?.artistViewUrl,
                            showAppDataSize: false
                        )
                    }
                
                // ScreenShot View
                AppDetailScreenShowView(appModel: appModel)
                
                // Content View
                AppDetailContentSectionView(appModel: appModel)
                
                // Footer Section
                AppDetailFooterView(appModel: appModel)
            }
            .alert(item: $alertType) { type in
                switch type {
                case .copyBundleId:
                    appModel.app?.bundleId.copyToClipboard()
                    return Alert(
                        title: Text("提示"),
                        message: Text("包名内容复制成功！"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

// MARK: - Header Section
struct AppDetailHeaderView: View {
    @StateObject var appModel: AppDetailModel
    @Binding var alertType: AppDetailAlertType?
    
    var body: some View {
        ZStack {
            // 背景模糊图
            ImageLoaderView(
                url: appModel.app?.artworkUrl100,
                placeholder: {},
                image: {
                    $0.resizable()
                        .blur(radius: 50, opaque: true)
                        .overlay(Color.black.opacity(0.25))
                        .animation(.easeInOut, value: appModel.app == nil)
                        .transition(.opacity)
                }
            )
            
            if appModel.app == nil {
                Rectangle().foregroundStyle(Color(uiColor: .systemBackground)).padding(.all)
                    .animation(.easeInOut, value: appModel.app == nil).transition(.opacity)
            }
            
            HStack(alignment: .top) {
                // 左侧 - 图标和评分
                VStack(alignment: .center) {
                    ImageLoaderView(
                        url: appModel.app?.artworkUrl512,
                        placeholder: {
                            Image("icon_placeholder")
                                .resizable()
                                .renderingMode(.original)
                                .cornerRadius(20)
                                .frame(width: 100, height: 100)
                        },
                        image: {
                            $0.resizable()
                                .renderingMode(.original)
                                .cornerRadius(20)
                                .frame(width: 100, height: 100)
                        }
                    )
                    
                    Spacer().frame(height: 15)
                    Text("v\(appModel.app?.version ?? "")").foregroundStyle(AppTheme.Colors.Background.primary)
                    Spacer()
                    Text(appModel.app?.averageRating ?? "")
                        .foregroundStyle(AppTheme.Colors.Background.primary)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("满分5分").font(.footnote)
                        .foregroundStyle(AppTheme.Colors.Background.primary.opacity(0.5)).fontWeight(.heavy)
                    Spacer()
                }
                
                Spacer().frame(width: 20)
                
                // 右侧 - 详情信息
                VStack(alignment: .leading) {
                    AppDetailTextView(key: "价格", value: appModel.app?.formattedPrice ?? "")
                    AppDetailTextView(key: "分级", value: appModel.app?.contentAdvisoryRating ?? "")
                    AppDetailTextView(key: "分类", value: (appModel.app?.genres ?? []).joined(separator: ","))
                    AppDetailTextView(key: "App ID", value: String(appModel.app?.trackId ?? 0))
                    
                    HStack {
                        Text("包名").font(.subheadline)
                        Button(appModel.app?.bundleId ?? "") { alertType = .copyBundleId }
                            .buttonStyle(.bordered)
                    }
                    
                    AppDetailTextView(key: "开发者", value: appModel.app?.artistName ?? "")
                    AppDetailTextView(key: "上架时间", value: appModel.app?.releaseTime ?? "")
                }.foregroundStyle(AppTheme.Colors.Background.primary)
                
                Spacer()
            }
            .padding([.leading, .trailing], 12)
            .padding([.top, .bottom], 18)
        }.frame(alignment: .top)
    }
}

// MARK: - Content Section
struct AppDetailContentSectionView: View {
    @StateObject var appModel: AppDetailModel
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        // Description
        MoreParagraphView(text: appModel.app?.description)
            .padding([.leading, .trailing], 10)
            .padding(.bottom, 12)
        
        // Developer Info
        HStack {
            VStack(alignment: .leading) {
                Text(appModel.app?.artistName ?? "").foregroundColor(.blue).font(.subheadline)
                Spacer().frame(height: 5)
                Text("开发者").font(.footnote).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right.circle").foregroundColor(.gray).font(.body)
        }
        .background(AppTheme.Colors.Background.primary)
        .padding(12)
        .onTapGesture {
            if let urlString = appModel.app?.artistViewUrl, let url = URL(string: urlString) {
                openURL(url)
            }
        }
        
        Divider().padding(.bottom, 15).padding([.leading, .trailing], 10)
        
        // 新功能
        HStack {
            Text("新功能").font(.title3).fontWeight(.bold).padding(.leading, 12)
            Spacer()
        }
        
        HStack {
            Text("版本 \(appModel.app?.version ?? "")").foregroundColor(.gray).font(.subheadline).padding(.leading, 12)
            Spacer()
            Text(appModel.app?.currentVersionReleaseTime ?? "").foregroundColor(.gray).font(.subheadline).padding(.trailing, 12)
        }.padding(.top, 10)
        
        MoreParagraphView(text: appModel.app?.releaseNotes)
            .padding([.leading, .trailing], 12)
            .padding(.bottom, 10)
        
        Divider().padding(.bottom, 15).padding([.leading, .trailing], 10)
    }
}

// MARK: - Footer View
struct AppDetailFooterView: View {
    @StateObject var appModel: AppDetailModel
    
    var body: some View {
        HStack {
            Text("信息").font(.title3).fontWeight(.bold).padding([.top, .leading], 12)
            Spacer()
        }
        
        Group {
            AppDetailFooterCellView(name: "评分", description: appModel.app?.averageRating ?? "")
            AppDetailFooterCellView(name: "评论", description: String(appModel.app?.userRatingCount ?? 0) + "条")
            AppDetailFooterCellView(name: "占用大小", description: appModel.app?.fileSizeMB ?? "")
            AppDetailFooterCellView(name: "最低支持系统", description: appModel.app?.minimumOsVersion ?? "")
            AppDetailFooterCellView(name: "类别", description: (appModel.app?.genres ?? []).joined(separator: "、"))
            AppDetailFooterCellView(name: "供应商", description: appModel.app?.sellerName ?? "", extendText: appModel.app?.artistName ?? "")
        }
        
        Group {
            AppDetailFooterCellView(name: "兼容性", description: "\(appModel.app?.supportedDevices.count ?? 0)种", 
                                    extendText: (appModel.app?.supportedDevices ?? []).joined(separator: "\n"))
            AppDetailFooterCellView(name: "支持语言", description: "\(appModel.app?.languageCodesISO2A.count ?? 0)种", 
                                    extendText: (appModel.app?.languageCodesISO2A ?? []).joined(separator: "、"))
            AppDetailFooterCellView(name: "年龄分级", description: appModel.app?.contentAdvisoryRating ?? "", 
                                    extendText: (appModel.app?.advisories ?? []).joined(separator: "\n"))
            AppDetailFooterCellView(name: "更新时间", description: appModel.app?.currentVersionReleaseTime ?? "")
            AppDetailFooterCellView(name: "上架时间", description: appModel.app?.releaseTime ?? "")
        }
        
        Spacer().frame(height: 30)
    }
}

// MARK: - Preview
#Preview {
    let model = AppDetailModel()
    return NavigationStack {
        AppDetailContentView(appModel: model)
    }
    .onAppear {
        model.searchAppData("1669437212", nil, "中国")
    }
}
