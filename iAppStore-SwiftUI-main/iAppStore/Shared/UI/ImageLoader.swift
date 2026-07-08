//
//  ImageLoader.swift
//  iAppStore
//
//  图片加载器组件
//  使用 SwiftUI AsyncImage + 本地缓存实现高效图片加载
//  兼容 iOS 15+ / macOS 12+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/21.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//


import Foundation
import SwiftUI

// MARK: - Async Image Loader View
/// 异步图片加载视图组件，支持本地缓存和自定义占位符
struct AsyncImageLoader<Placeholder: View, ImageContent: View>: View {
    
    // MARK: - Properties
    private let url: URL?
    private let cacheKey: String
    private let scale: CGFloat
    private let transaction: Transaction
    private let placeholder: () -> Placeholder
    private let image: (Image) -> ImageContent
    private let onLoaded: ((UIImage) -> Void)?
    
    // MARK: - State
    @State private var cachedImage: UIImage?
    @State private var isLoadingFromCache = true
    
    // MARK: - Initialization
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(animation: .default),
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder image: @escaping (Image) -> ImageContent,
        onLoaded: ((UIImage) -> Void)? = nil
    ) {
        self.url = url
        self.cacheKey = url?.absoluteString.md5 ?? ""
        self.scale = scale
        self.transaction = transaction
        self.placeholder = placeholder
        self.image = image
        self.onLoaded = onLoaded
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if let cachedImage = cachedImage, !isLoadingFromCache {
                image(Image(uiImage: cachedImage))
            } else {
                AsyncImage(
                    url: url,
                    scale: scale,
                    transaction: transaction
                ) { phase in
                    switch phase {
                    case .empty:
                        placeholder()
                    case .success(let asyncImage):
                        image(asyncImage)
                            .onAppear {
                                if let uiImage = asyncImage.asUIImage() {
                                    saveToCache(uiImage)
                                    onLoaded?(uiImage)
                                }
                            }
                    case .failure:
                        placeholder()
                    @unknown default:
                        placeholder()
                    }
                }
            }
        }
        .onAppear { loadFromCache() }
    }
    
    // MARK: - Cache Operations
    private func loadFromCache() {
        Task {
            if let cached = await LocalFileManager.instance.getImageAsync(imageName: cacheKey, folderName: "iAppStore_images") {
                cachedImage = cached
            }
            isLoadingFromCache = false
        }
    }
    
    private func saveToCache(_ image: UIImage) {
        LocalFileManager.instance.saveImage(image: image, imageName: cacheKey, folderName: "iAppStore_images")
    }
}

// MARK: - Image Content Extensions
extension Image {
    /// 将 SwiftUI Image 转换为 UIImage
    @MainActor
    func asUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = UITraitCollection.current.displayScale
        return renderer.uiImage
    }
}

// MARK: - Convenience API
extension AsyncImageLoader where Placeholder == Color, ImageContent == Image {
    
    /// 创建简单的异步图片加载器
    /// - Parameters:
    ///   - url: 图片URL
    ///   - placeholderColor: 占位符颜色
    init(url: URL?, placeholderColor: Color = .gray) {
        self.init(
            url: url,
            placeholder: { placeholderColor },
            image: { $0 }
        )
    }
}

// MARK: - AsyncImageLoaderView (Legacy Compatibility)
/// 兼容旧版 ImageLoaderView 的视图组件
struct ImageLoaderView<Placeholder: View, ConfiguredImage: View>: View {
    
    private let url: String?
    private let placeholder: () -> Placeholder
    private let image: (Image) -> ConfiguredImage
    private let completion: ((UIImage) -> Void)?
    
    init(
        url: String?,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder image: @escaping (Image) -> ConfiguredImage,
        completion: ((UIImage) -> Void)? = nil
    ) {
        self.url = url
        self.placeholder = placeholder
        self.image = image
        self.completion = completion
    }
    
    var body: some View {
        AsyncImageLoader(
            url: URL(string: url ?? ""),
            placeholder: placeholder,
            image: image,
            onLoaded: completion
        )
    }
}