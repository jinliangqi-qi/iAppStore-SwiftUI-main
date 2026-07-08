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
    public enum APIError: Error, Sendable {
        case noResponse
        case jsonDecodingError(error: Error)
        case networkError(error: Error)
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
        guard let url = URL(string: endpoint.url()),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return .failure(.noResponse)
        }
        
        if let params = params {
            for (_, value) in params.enumerated() {
                components.queryItems?.append(URLQueryItem(name: value.key, value: value.value))
            }
        }
        
        guard let requestURL = components.url else { return .failure(.noResponse) }
        
        #if DEBUG
        debugPrint(requestURL)
        #endif
        
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.noResponse)
            }
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch let error as DecodingError {
            return .failure(.jsonDecodingError(error: error))
        } catch {
            return .failure(.networkError(error: error))
        }
    }
    
    // MARK: - Legacy Methods (Deprecated)
    
    @available(*, deprecated, message: "Use async request() instead")
    public func POST<T: Codable & Sendable>(endpoint: Endpoint, params: [String: String]?,
                         completionHandler: @escaping @Sendable (Result<T, APIError>) -> Void) {
        guard let url = URL(string: endpoint.url()),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completionHandler(.failure(.noResponse)); return
        }
        
        if let params = params {
            for (_, value) in params.enumerated() {
                components.queryItems?.append(URLQueryItem(name: value.key, value: value.value))
            }
        }
        guard let requestURL = components.url else { completionHandler(.failure(.noResponse)); return }
        
        var request = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { DispatchQueue.main.async { completionHandler(.failure(.noResponse)) }; return }
            guard error == nil else { DispatchQueue.main.async { completionHandler(.failure(.networkError(error: error!))) }; return }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async { completionHandler(.failure(.noResponse)) }; return
            }
            do {
                let object = try self.decoder.decode(T.self, from: data)
                DispatchQueue.main.async { completionHandler(.success(object)) }
            } catch let error {
                DispatchQueue.main.async { completionHandler(.failure(.jsonDecodingError(error: error))) }
            }
        }.resume()
    }
    
    @available(*, deprecated, message: "Use async request() instead")
    public func GET_JSON(endpoint: Endpoint, params: [String: String]?,
                    completionHandler: @escaping @Sendable (Result<Dictionary<String, Any>, APIError>) -> Void) {
        guard let url = URL(string: endpoint.url()),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completionHandler(.failure(.noResponse)); return
        }
        
        if let params = params {
            for (_, value) in params.enumerated() {
                components.queryItems?.append(URLQueryItem(name: value.key, value: value.value))
            }
        }
        guard let requestURL = components.url else { completionHandler(.failure(.noResponse)); return }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { DispatchQueue.main.async { completionHandler(.failure(.noResponse)) }; return }
            guard error == nil else { DispatchQueue.main.async { completionHandler(.failure(.networkError(error: error!))) }; return }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async { completionHandler(.failure(.noResponse)) }; return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                guard let object = json as? Dictionary<String, Any> else {
                    let error = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
                    DispatchQueue.main.async { completionHandler(.failure(.jsonDecodingError(error: error))) }; return
                }
                DispatchQueue.main.async { completionHandler(.success(object)) }
            } catch let error {
                DispatchQueue.main.async { completionHandler(.failure(.jsonDecodingError(error: error))) }
            }
        }.resume()
    }
}
