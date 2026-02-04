//
//  NetworkManager.swift
//  iAppStore
//
//  Created by peak on 2022/1/25.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation
import Combine

/// 基于Combine框架的网络管理器
/// 提供响应式的网络请求功能，主要用于图片下载等场景
class NetworkingManager {
   
    /// 网络请求错误类型定义
    enum NetworkingError: LocalizedError {
        /// URL响应错误，包含出错的URL
        case badURLResponse(url: URL)
        /// 未知错误
        case unknown
        
        /// 错误描述信息
        var errorDescription: String? {
            switch self {
            case .badURLResponse(url: let url): 
                return "[🔥] Bad response from URL: \(url)"
            case .unknown: 
                return "[⚠️] Unknown error occured"
            }
        }
    }
    
    /// 下载数据的静态方法，返回Combine Publisher
    /// - Parameter url: 要下载的URL
    /// - Returns: 返回AnyPublisher，成功时包含Data，失败时包含Error
    /// - Note: 自动重试2次，适用于图片等资源的下载
    static func download(url: URL) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap({ try handleURLResponse(output: $0, url: url) })
            .retry(2) // 失败时自动重试2次
            .eraseToAnyPublisher()
    }
    
    /// 处理URL响应的静态方法
    /// - Parameters:
    ///   - output: URLSession数据任务的输出
    ///   - url: 请求的URL，用于错误信息
    /// - Returns: 成功时返回响应数据
    /// - Throws: 当HTTP状态码不在200-299范围内时抛出NetworkingError.badURLResponse
    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        // 检查HTTP响应状态码是否在成功范围内（200-299）
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
                  throw NetworkingError.badURLResponse(url: url)
              }
        return output.data
    }
    
    /// 处理Combine完成事件的静态方法
    /// - Parameter completion: Combine的完成事件
    /// - Note: 用于统一处理网络请求的完成状态，包括成功和失败
    static func handleCompletion(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            // 请求成功完成，无需特殊处理
            break
        case .failure(let error):
            // 请求失败，打印错误信息
            print(error.localizedDescription)
        }
    }
}
