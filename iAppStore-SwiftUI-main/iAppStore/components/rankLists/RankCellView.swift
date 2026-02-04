//
//  RankCellView.swift
//  iAppStore
//
//  Created by HTC on 2021/12/17.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import SwiftUI

struct RankCellView: View {
    
    var item: AppRank
    var isShowAppDataSize: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Number
            Text("\(item.rank)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .leading)
            
            // App Icon
            AsyncImage(url: URL(string: item.imImage.last?.label ?? "")) { image in
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
                Text(item.imName.label)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                // App Summary or Data Size
                if isShowAppDataSize {
                    let dataSize = item.imContentType.attributes.term
                    if !dataSize.isEmpty {
                        Text(dataSize)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                } else {
                    Text(item.summary?.label ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                // Category
                Text(item.category.attributes.label)
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Price and Get Button
            VStack(spacing: 8) {
                // Price
                let price = item.imPrice.label
                if !price.isEmpty {
                    Text(price)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("免费")
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
    }
}



#Preview {
    VStack {
        RankCellView(item: AppRank.example, isShowAppDataSize: false)
        RankCellView(item: AppRank.example, isShowAppDataSize: true)
    }
    .background(Color(.systemGroupedBackground))
}
