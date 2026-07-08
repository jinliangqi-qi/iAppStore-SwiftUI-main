//
//  APIService.swift
//  iAppStore
//
//  iTunes Store API 服务类
//  提供与 iTunes Store API 交互的所有网络请求功能
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/20.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import Foundation

// MARK: - API Service
/// iTunes Store API 服务类
public struct APIService: Sendable {
    
    /// iTunes Store API 基础URL
    let baseURL = "https://itunes.apple.com/"
    
    /// 单例实例
    public static let shared = APIService()
    
    /// JSON解码器
    let decoder = JSONDecoder()
    
    /// API请求错误类型
    public enum APIError: Error, Sendable, LocalizedError {
        case invalidURL
        case noResponse
        case statusCode(Int)
        case jsonDecodingError(error: Error)
        case networkError(error: Error)
        case timeout
        case emptyData
        case unauthorized
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "无效的URL地址"
            case .noResponse:
                return "服务器未响应"
            case .statusCode(let code):
                return "服务器返回错误状态码: \(code)"
            case .jsonDecodingError:
                return "数据解析失败"
            case .networkError(let error):
                return "网络请求失败: \(error.localizedDescription)"
            case .timeout:
                return "请求超时，请稍后重试"
            case .emptyData:
                return "服务器返回空数据"
            case .unauthorized:
                return "未授权访问"
            }
        }
    }
    
    /// API端点枚举
    public enum Endpoint: Sendable {
        case topFreeApplications(cid: String, country: String, limit: Int)
        case topFreeiPadApplications(cid: String, country: String, limit: Int)
        case topPaidApplications(cid: String, country: String, limit: Int)
        case topPaidiPadApplications(cid: String, country: String, limit: Int)
        case topGrossingApplications(cid: String, country: String, limit: Int)
        case topGrossingiPadApplications(cid: String, country: String, limit: Int)
        case newApplications(cid: String, country: String, limit: Int)
        case newFreeApplications(cid: String, country: String, limit: Int)
        case newPaidApplications(cid: String, country: String, limit: Int)
        case searchApp(word: String, country: String, limit: Int)
        case lookupApp(appid: String, country: String)
        case lookupBundleId(appid: String, country: String)

        func url() -> String {
            let url = APIService.shared.baseURL
            switch self {
            case .topFreeApplications(let cid, let country, let limit):
                return url + "rss/topfreeapplications/limit=\(limit)/genre=\(encode(cid))/json?cc=\(encode(country))"
            case .topFreeiPadApplications(let cid, let country, let limit):
                return url + "rss/topFreeiPadApplications/limit=\(limit)/genre=\(encode(cid))/json?cc=\(encode(country))"
            case .topPaidApplications(let cid, let country, let limit):
                return url + "rss/topPaidApplications/limit=\(limit)/genre=\(encode(cid))/json?cc=\(encode(country))"
            case .topPaidiPadApplications(let cid, let country, let limit):
                return url + "rss/topPaidiPadApplications/limit=\(limit)/genre=\(encode(cid))/json?cc=\(encode(country))"
            case .topGrossingApplications(let cid, let country, let limit):
                return url + "rss/topGrossingApplications/limit=\(limit)/genre=\(encode(cid))/json?cc=\(encode(country))"
            case .topGrossingiPadApplications(let cid, let country, let limit):
                return url + "rss/topGrossingiPadApplications/limit=\(limit)/genre=\(encode(cid))/json?cc=\(encode(country))"
            case .newApplications(let cid, let country, let limit):
                return url + "rss/newApplications/limit=\(limit)/genre=\(encode(cid))/json?cc=\(encode(country))"
            case .newFreeApplications(let cid, let country, let limit):
                return url + "rss/newFreeApplications/limit=\(limit)/genre=\(encode(cid))/json?cc=\(encode(country))"
            case .newPaidApplications(let cid, let country, let limit):
                return url + "rss/newPaidApplications/limit=\(limit)/genre=\(encode(cid))/json?cc=\(encode(country))"
            case .searchApp(let word, let country, let limit):
                return url + "search?term=\(encode(word))&country=\(encode(country))&limit=\(limit)&entity=software"
            case .lookupApp(let appid, let country):
                return url + "\(encode(country))/lookup?id=\(encode(appid))"
            case .lookupBundleId(let appid, let country):
                return url + "\(encode(country))/lookup?bundleId=\(encode(appid))"
            }
        }
        
        private func encode(_ string: String) -> String {
            return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
        }
    }
    
    // MARK: - Async Request
    
    /// 使用 async/await 发送请求
    public func request<T: Codable & Sendable>(endpoint: Endpoint, params: [String: String]? = nil) async -> Result<T, APIError> {
        guard let baseURL = URL(string: endpoint.url()),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return .failure(.invalidURL)
        }
        
        if let params = params {
            for (_, value) in params.enumerated() {
                components.queryItems?.append(URLQueryItem(name: value.key, value: value.value))
            }
        }
        
        guard let requestURL = components.url else { return .failure(.invalidURL) }
        
        #if DEBUG
        debugPrint(requestURL)
        #endif
        
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    return .failure(.unauthorized)
                }
                return .failure(.statusCode(httpResponse.statusCode))
            }
            
            guard !data.isEmpty else {
                return .failure(.emptyData)
            }
            
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch let error as DecodingError {
            return .failure(.jsonDecodingError(error: error))
        } catch let error as URLError {
            if error.code == .timedOut {
                return .failure(.timeout)
            }
            return .failure(.networkError(error: error))
        } catch {
            return .failure(.networkError(error: error))
        }
    }
}
