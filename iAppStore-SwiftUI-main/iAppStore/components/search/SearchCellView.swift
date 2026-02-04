//
//  SearchCellView.swift
//  iAppStore
//
//  Created by HTC on 2021/12/25.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI
import Foundation

struct SearchCellView: View {
    
    var index: Int
    var item: AppDetail
    @State @AppStorage("kIsShowAppDataSize") private var isShowAppDataSize = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Number
            Text("\(index + 1)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .leading)
            
            // App Icon
            AsyncImage(url: URL(string: item.artworkUrl100 ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // App Info
            VStack(alignment: .leading, spacing: 4) {
                // App Name
                Text(item.trackName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                // App Description or Data Size
                if isShowAppDataSize {
                    Text("占用大小：\(item.fileSizeMB)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Text("最低支持系统：\(item.minimumOsVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(item.description.replacingOccurrences(of: "\n", with: ""))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                // Category and Artist
                HStack {
                    Text((item.genres).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                    
                    if item.price != 0.0 {
                        Text(item.formattedPrice ?? "-")
                            .font(.caption)
                            .foregroundStyle(.pink)
                    }
                }
                
                Text(item.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Price and Get Button
            VStack(spacing: 8) {
                // Price
                if item.price == 0.0 {
                    Text("免费")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(item.formattedPrice ?? "-")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Get Button
                Button(action: {
                    // Handle app download
                }) {
                    Text("获取")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .contextMenu {
            Button("复制 App ID") {
                String(item.trackId).copyToClipboard()
            }
            Button("复制 Bundle ID") {
                item.bundleId.copyToClipboard()
            }
            Button("在 App Store 中查看") {
                if let appUrl = URL(string: item.trackViewUrl) {
                    openURL(appUrl)
                }
            }
        }
    }
}



#Preview {
    VStack {
        SearchCellView(index: 0, item: AppDetail.example)
    }
    .background(Color(.systemGroupedBackground))
}
