//
//  ShareSheet.swift
//  iAppStore
//
//  Created by iHTCboy on 2022/1/9.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

/// 现代化的分享视图
struct ShareSheet: View {
    var items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    var body: some View {
        ShareSheetRepresentable(items: items, excludedActivityTypes: excludedActivityTypes)
    }
}

/// UIKit 桥接实现（SwiftUI 的 ShareLink 不支持任意 Any 类型，如 UIImage）
private struct ShareSheetRepresentable: UIViewControllerRepresentable {
    var items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
