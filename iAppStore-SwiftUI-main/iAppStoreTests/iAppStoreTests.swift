//
//  iAppStoreTests.swift
//  iAppStoreTests
//
//  单元测试
//  覆盖 Models 的 Codable 解码、ViewModels 逻辑、常量映射等
//
//  Created by HTC on 2021/12/15.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//


import XCTest
@testable import iAppStore

final class iAppStoreTests: XCTestCase {

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    // MARK: - AppDetail Model Tests

    func testAppDetailExampleData() throws {
        let app = AppDetail.example

        XCTAssertEqual(app.trackName, "抖音")
        XCTAssertEqual(app.artistName, "Beijing Microlive Vision Technology Co., Ltd")
        XCTAssertEqual(app.bundleId, "com.ss.iphone.ugc.Aweme")
        XCTAssertEqual(app.trackId, 1142110895)
        XCTAssertEqual(app.primaryGenreName, "Entertainment")
        XCTAssertEqual(app.version, "24.8.0")
    }

    func testAppDetailCodableRoundTrip() throws {
        let original = AppDetail.example
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppDetail.self, from: encoded)

        XCTAssertEqual(decoded.trackId, original.trackId)
        XCTAssertEqual(decoded.trackName, original.trackName)
        XCTAssertEqual(decoded.bundleId, original.bundleId)
        XCTAssertEqual(decoded.version, original.version)
    }

    func testAppDetailReleaseTime() throws {
        let app = AppDetail.example
        XCTAssertEqual(app.releaseTime, "2016-09-26")
    }

    func testAppDetailCurrentVersionReleaseTime() throws {
        let app = AppDetail.example
        // 确保日期格式化不返回空字符串
        XCTAssertFalse(app.currentVersionReleaseTime.isEmpty)
    }

    func testAppDetailFileSizeMB() throws {
        let app = AppDetail.example
        XCTAssertFalse(app.fileSizeMB.isEmpty)
        XCTAssertTrue(app.fileSizeMB.contains("MB"))
    }

    func testAppDetailAverageRating() throws {
        let app = AppDetail.example
        XCTAssertEqual(app.averageRating, "4.9")
    }

    func testAppDetailIsSupportDevice() throws {
        let app = AppDetail.example
        XCTAssertTrue(app.isSupportiPhone)
        XCTAssertTrue(app.isSupportiPad)
    }

    // MARK: - AppRank Model Tests

    func testAppRankExampleData() throws {
        let rank = AppRank.example

        XCTAssertEqual(rank.imName.label, "示例应用")
        XCTAssertEqual(rank.id.attributes.imID, "123456789")
        XCTAssertEqual(rank.id.attributes.imBundleID, "com.example.app")
        XCTAssertEqual(rank.category.attributes.label, "娱乐")
    }

    func testAppRankCodableRoundTrip() throws {
        let original = AppRank.example
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppRank.self, from: encoded)

        XCTAssertEqual(decoded.imName.label, original.imName.label)
        XCTAssertEqual(decoded.id.attributes.imID, original.id.attributes.imID)
        XCTAssertEqual(decoded.imPrice.attributes.amount, original.imPrice.attributes.amount)
    }

    // MARK: - AppFavorite Model Tests

    func testAppFavoriteCodable() throws {
        let favorite = AppFavorite(appId: "123456", regionName: "中国")
        let encoded = try JSONEncoder().encode(favorite)
        let decoded = try JSONDecoder().decode(AppFavorite.self, from: encoded)

        XCTAssertEqual(decoded.appId, "123456")
        XCTAssertEqual(decoded.regionName, "中国")
    }

    func testAppFavoritesModelAddRemove() throws {
        let model = AppFavoritesModel.shared

        // 添加收藏
        let favorite = AppFavorite(appId: "test_\(UUID().uuidString)", regionName: "中国")
        model.add(favorite)
        XCTAssertNotNil(model.search(favorite.appId))

        // 移除收藏
        let result = model.remove(appId: favorite.appId)
        XCTAssertEqual(result, 1)
        XCTAssertNil(model.search(favorite.appId))
    }

    // MARK: - TSMGConstants Tests

    func testRankingTypeListIdsCount() throws {
        XCTAssertEqual(TSMGConstants.rankingTypeLists.count, TSMGConstants.rankingTypeListIds.count)
    }

    func testCategoryTypeListIdsCount() throws {
        XCTAssertEqual(TSMGConstants.categoryTypeLists.count, TSMGConstants.categoryTypeListIds.count)
    }

    func testRankingTypeListIdsMapping() throws {
        for name in TSMGConstants.rankingTypeLists {
            XCTAssertNotNil(TSMGConstants.rankingTypeListIds[name], "排行榜类型「\(name)」缺少对应的 API ID")
        }
    }

    func testCategoryTypeListIdsMapping() throws {
        for name in TSMGConstants.categoryTypeLists {
            XCTAssertNotNil(TSMGConstants.categoryTypeListIds[name], "分类「\(name)」缺少对应的 API ID")
        }
    }

    func testRegionTypeListIdsMapping() throws {
        for name in TSMGConstants.regionTypeLists {
            XCTAssertNotNil(TSMGConstants.regionTypeListIds[name], "地区「\(name)」缺少对应的 ID")
        }
    }

    // MARK: - APIService.Endpoint Tests

    func testEndpointSearchURL() throws {
        let endpoint = APIService.Endpoint.searchApp(word: "微信", country: "cn", limit: 10)
        let url = endpoint.url()
        XCTAssertTrue(url.contains("search?term="))
        XCTAssertTrue(url.contains("country=cn"))
        XCTAssertTrue(url.contains("limit=10"))
    }

    func testEndpointLookupURL() throws {
        let endpoint = APIService.Endpoint.lookupApp(appid: "123456", country: "cn")
        let url = endpoint.url()
        XCTAssertTrue(url.contains("cn/lookup?id=123456"))
    }

    func testEndpointTopFreeApplicationsURL() throws {
        let endpoint = APIService.Endpoint.topFreeApplications(cid: "6014", country: "cn", limit: 200)
        let url = endpoint.url()
        XCTAssertTrue(url.contains("rss/topfreeapplications/limit=200"))
        XCTAssertTrue(url.contains("genre=6014"))
        XCTAssertTrue(url.contains("cc=cn"))
    }

    // MARK: - APIError Tests

    func testAPIErrorDescriptions() throws {
        XCTAssertNotNil(APIService.APIError.invalidURL.errorDescription)
        XCTAssertNotNil(APIService.APIError.noResponse.errorDescription)
        XCTAssertNotNil(APIService.APIError.timeout.errorDescription)
        XCTAssertNotNil(APIService.APIError.emptyData.errorDescription)
        XCTAssertNotNil(APIService.APIError.unauthorized.errorDescription)
        XCTAssertNotNil(APIService.APIError.statusCode(404).errorDescription)
    }

    // MARK: - NetworkingError Tests

    func testNetworkingErrorDescriptions() throws {
        XCTAssertNotNil(NetworkingManager.NetworkingError.invalidURL.errorDescription)
        XCTAssertNotNil(NetworkingManager.NetworkingError.timeout.errorDescription)
        XCTAssertNotNil(NetworkingManager.NetworkingError.emptyData.errorDescription)
        XCTAssertNotNil(NetworkingManager.NetworkingError.networkUnavailable.errorDescription)
        XCTAssertNotNil(NetworkingManager.NetworkingError.cancelled.errorDescription)
    }

    // MARK: - Size Model Tests

    func testSizeModel() throws {
        let size = Size(width: 100, height: 200)
        XCTAssertEqual(size.width, 100)
        XCTAssertEqual(size.height, 200)

        let zero = Size.zero
        XCTAssertEqual(zero.width, 0)
        XCTAssertEqual(zero.height, 0)

        XCTAssertNotEqual(size.width, zero.width)
    }

    // MARK: - Performance Test

    func testPerformanceExample() throws {
        self.measure {
            for _ in 0..<1000 {
                let _ = AppDetail.example.averageRating
            }
        }
    }
}
