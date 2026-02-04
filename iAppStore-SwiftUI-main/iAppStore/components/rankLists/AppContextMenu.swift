//
//  AppContextMenu.swift
//  iAppStore
//
//  Created by iHTCboy on 2022/1/9.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

struct AppContextMenu: View {
    
    let appleID: String?
    let bundleID: String?
    let appUrl: String?
    let developerUrl: String?
    var showAppDataSize: Bool = true
    
    @AppStorage("kIsShowAppDataSize") private var isShowAppDataSize = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack {
            if let appleID = appleID {
                CreateMenuItem(text: "复制 App ID", imgName: "doc.on.doc.fill") {
                    appleID.copyToClipboard()
                }
            }
            
            if let bundleID = bundleID {
                CreateMenuItem(text: "复制 App 包名", imgName: "shippingbox.fill") {
                    bundleID.copyToClipboard()
                }
            }
            
            if let appUrl = appUrl {
                CreateMenuItem(text: "复制 App 商店链接", imgName: "link.circle.fill") {
                    appUrl.copyToClipboard()
                }
                
                CreateMenuItem(text: "从 App Store 打开 App", imgName: "paperplane.fill") {
                    if let url = URL(string: appUrl) {
                        openURL(url)
                    }
                }
            }
            
            if let developerUrl = developerUrl {
                CreateMenuItem(text: "复制开发者商店链接", imgName: "person.circle.fill") {
                    developerUrl.copyToClipboard()
                }
                
                CreateMenuItem(text: "打开开发者商店主页", imgName: "person.crop.circle.fill") {
                    if let url = URL(string: developerUrl) {
                        openURL(url)
                    }
                }
            }
            
            if showAppDataSize {
                CreateMenuItem(text: "\(isShowAppDataSize ? "隐藏" : "显示") App 大小和最低支持系统", imgName: "arrow.down.app.fill") {
                    isShowAppDataSize.toggle()
                }
            }
        }
    }
    
    
    func CreateMenuItem(text: String, imgName: String, onAction: (() -> Void)?) -> some View {
        Button(action: {
            onAction?()
        }) {
            HStack {
                Text(text)
                Image(systemName: imgName)
                    .imageScale(.small)
                    .foregroundColor(.primary)
            }
        }
    }
}




#Preview {
    AppContextMenu(appleID: "123456", bundleID: "iAppStore", appUrl: "https://juejin.cn/user/1002387318511214", developerUrl: "https://juejin.cn/user/1002387318511214", showAppDataSize: true)
}
