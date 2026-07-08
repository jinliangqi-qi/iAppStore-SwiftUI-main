//
//  NetworkManager.swift
//  iAppStore
//
//  Created by peak on 2022/1/25.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import Foundation

/// 网络管理器
/// 提供基于 Async/Await 的网络请求功能，主要用于图片下载等场景
actor NetworkingManager {
    
    static let shared = NetworkingManager()
    
    private init() {}
    
    /// 网络请求错误类型定义
    enum NetworkingError: LocalizedError, Sendable {
        case badURLResponse(url: URL, statusCode: Int)
        case invalidURL
        case timeout
        case emptyData
        case networkUnavailable
        case cancelled
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .badURLResponse(url: let url, statusCode: let code):
                return "[🔥] Bad response from URL: \(url) (status: \(code))"
            case .invalidURL:
                return "[⚠️] Invalid URL"
            case .timeout:
                return "[⏱️] Request timed out"
            case .emptyData:
                return "[📭] Empty data received"
            case .networkUnavailable:
                return "[📶] Network unavailable"
            case .cancelled:
                return "[✋] Request cancelled"
            case .unknown:
                return "[⚠️] Unknown error occurred"
            }
        }
    }
    
    /// 下载数据的方法
    /// - Parameter url: 要下载的URL
    /// - Returns: 返回下载的数据
    /// - Throws: 下载失败时抛出NetworkingError
    func download(url: URL, maxRetries: Int = 2) async throws -> Data {
        for attempt in 0...maxRetries {
            do {
                return try await downloadOnce(url: url)
            } catch {
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(pow(2, Double(attempt)) * 100_000_000))
                    continue
                }
                throw error
            }
        }
        throw NetworkingError.unknown
    }
    
    private func downloadOnce(url: URL) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkingError.unknown
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                throw NetworkingError.badURLResponse(url: url, statusCode: httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkingError.emptyData
            }
            
            return data
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw NetworkingError.timeout
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkingError.networkUnavailable
            case .cancelled:
                throw NetworkingError.cancelled
            default:
                throw error
            }
        } catch {
            throw error
        }
    }
}
