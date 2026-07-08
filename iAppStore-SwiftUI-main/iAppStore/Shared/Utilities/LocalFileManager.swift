//
//  LocalFileManager.swift
//  iAppStore
//
//  本地文件管理器
//  负责图片缓存和模型数据的本地存储
//  图片存储在 caches 目录，模型数据存储在 applicationSupport 目录
//  兼容 iOS 15+ / macOS 12+ / iPadOS / Swift 6
//
//  Created by peak on 2022/1/25.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//


import Foundation
import SwiftUI

final class LocalFileManager: Sendable {
    static let instance = LocalFileManager()
    private init() {}
    
    private let fileQueue = DispatchQueue(label: "com.iappstore.filemanager", qos: .default, attributes: .concurrent)
    
    // MARK: - Image Operations (Caches Directory)
    
    func saveImage(image: UIImage, imageName: String, folderName: String) {
        fileQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.createFolderIfNeeded(folderName: folderName, directory: .caches)
            
            guard let data = image.pngData(),
                  let url = self.getURLForImage(imageName: imageName, folderName: folderName)
            else {
                return
            }
            
            do {
                try data.write(to: url, options: .atomic)
            } catch let error {
                print("Error saving image. ImageName: \(imageName) \(error)")
            }
        }
    }
    
    func getImage(imageName: String, folderName: String) -> UIImage? {
        var result: UIImage?
        fileQueue.sync { [weak self] in
            guard let self = self else { return }
            guard let url = self.getURLForImage(imageName: imageName, folderName: folderName),
                  FileManager.default.fileExists(atPath: url.path) else {
                      return
                  }
            result = UIImage(contentsOfFile: url.path)
        }
        return result
    }
    
    // MARK: - Model Operations (Application Support Directory)
    
    func saveModel<T: Encodable>(model: [T], modelName: String, folderName: String) {
        fileQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.createFolderIfNeeded(folderName: folderName, directory: .applicationSupport)
            
            guard let url = self.getURLForModel(modelName: modelName, folderName: folderName) else {
                return
            }
            
            do {
                let data = try JSONEncoder().encode(model)
                try data.write(to: url, options: .atomic)
            } catch let error {
                print("Error save model. ModelName: \(modelName) \(error)")
            }
        }
    }
    
    func getModel<T: Decodable>(modelName: String, folderName: String) -> [T] {
        var result: [T] = []
        fileQueue.sync { [weak self] in
            guard let self = self else { return }
            guard let url = self.getURLForModel(modelName: modelName, folderName: folderName),
                  FileManager.default.fileExists(atPath: url.path) else {
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                result = try JSONDecoder().decode([T].self, from: data)
            } catch {
                print("Error get model, error: \(error)")
            }
        }
        return result
    }
    
    // MARK: - Async Image Operations
    
    /// 异步获取图片
    func getImageAsync(imageName: String, folderName: String) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            fileQueue.async {
                guard let url = self.getURLForImage(imageName: imageName, folderName: folderName),
                      FileManager.default.fileExists(atPath: url.path) else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: UIImage(contentsOfFile: url.path))
            }
        }
    }
    
    // MARK: - Private Helpers
    
    /// 存储目录类型
    private enum StorageDirectory {
        case caches
        case applicationSupport
    }
    
    private func createFolderIfNeeded(folderName: String, directory: StorageDirectory) {
        guard let url = getURLForFolder(folderName: folderName, directory: directory) else {
            return
        }
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Error creating directory. FolderName: \(folderName). \(error)")
            }
        }
    }
    
    private func getURLForFolder(folderName: String, directory: StorageDirectory) -> URL? {
        let baseURL: URL?
        switch directory {
        case .caches:
            baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        case .applicationSupport:
            baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        }
        guard let url = baseURL, !folderName.isEmpty else {
            return nil
        }
        return url.appendingPathComponent(folderName)
    }
    
    private func getURLForImage(imageName: String, folderName: String) -> URL? {
        guard let folderURL = getURLForFolder(folderName: folderName, directory: .caches), !imageName.isEmpty else {
            return nil
        }
        return folderURL.appendingPathComponent(imageName + ".png")
    }
    
    private func getURLForModel(modelName: String, folderName: String) -> URL? {
        guard let folderURL = getURLForFolder(folderName: folderName, directory: .applicationSupport), !modelName.isEmpty else {
            return nil
        }
        return folderURL.appendingPathComponent(modelName + ".model")
    }
}
