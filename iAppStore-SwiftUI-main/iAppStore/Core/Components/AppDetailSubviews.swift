//
//  AppDetailSubviews.swift
//  iAppStore
//
//  App详情页面子视图组件
//  从 AppDetailContentView.swift 提取的视图组件，用于代码拆分
//  兼容 iOS 26 / macOS 14+ / iPadOS / Swift 6
//
//  Created by HTC on 2021/12/23.
//  Copyright © 2022 37 Mobile Games. All rights reserved.
//

import SwiftUI

// MARK: - AppDetailTextView
/// 详情文本行组件
struct AppDetailTextView: View {
    var key: String
    var value: String
    
    var body: some View {
        HStack {
            Text(key).font(.subheadline)
            Text(value).font(.subheadline).fontWeight(.bold)
        }.padding(1)
    }
}

// MARK: - AppDetailScreenShowView
/// 截图展示视图
struct AppDetailScreenShowView: View {
    @StateObject var appModel: AppDetailModel
    @State private var extendiPadShot: Bool = false
    
    private var app: AppDetail? { appModel.app }
    private var isSupportiPhone: Bool { app?.isSupportiPhone ?? false }
    private var isSupportiPad: Bool { app?.isSupportiPad ?? false }
    
    var body: some View {
        HStack {
            Text("预览").font(.title3).fontWeight(.bold).padding([.top, .leading], 12)
            Spacer()
        }
        
        VStack(alignment: .leading) {
            if app != nil && isSupportiPhone {
                AppDetailScreenShotView(screenshotUrls: app?.screenshotUrls, imageSize: app?.screenShotSize)
                
                HStack {
                    Image(systemName: "iphone.gen3").foregroundColor(.gray).font(.body)
                    if isSupportiPad && !extendiPadShot {
                        Image(systemName: "ipad.gen2").foregroundColor(.gray).font(.body)
                        Text("iPhone 和 iPad App").foregroundColor(.gray).font(.footnote).fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.down").foregroundColor(.gray).font(.body)
                    } else {
                        Text("iPhone").foregroundColor(.gray).font(.footnote).fontWeight(.medium)
                        Spacer()
                    }
                }
                .background(Color.tsmg_systemBackground)
                .padding([.leading, .trailing], 12)
                .padding([.top, .bottom], 10)
                .onTapGesture {
                    if isSupportiPad { extendiPadShot = true }
                }
            }
        }.padding(.bottom, 5)
        
        VStack(alignment: .leading) {
            if (app != nil && extendiPadShot)
                || (app != nil && !isSupportiPhone && isSupportiPad) {
                AppDetailScreenShotView(screenshotUrls: app?.ipadScreenshotUrls, imageSize: app?.screenShotSize)
                
                HStack {
                    Image(systemName: "ipad.gen2").foregroundColor(.gray).font(.body)
                    Text("iPad").foregroundColor(.gray).font(.footnote).fontWeight(.medium)
                    Spacer()
                }
                .padding([.leading, .trailing], 12)
                .padding([.top, .bottom], 10)
            }
        }.padding(.bottom, 5)
        
        Divider().padding(.bottom, 12).padding([.leading, .trailing], 10)
    }
}

// MARK: - AppDetailScreenShotView
/// 单个截图滚动视图
struct AppDetailScreenShotView: View {
    var screenshotUrls: [String]?
    var imageSize: CGSize?
    @State private var selectedShot: Bool = false
    @State private var selectedImgUrl: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                if let urls = screenshotUrls {
                    ForEach(urls.indices, id: \.self) { index in
                        let url = urls[index]
                        Button(action: {
                            selectedImgUrl = url.imageAppleScale()
                            selectedShot = true
                        }) {
                            ImageLoaderView(
                                url: url.imageAppleScale(),
                                placeholder: {
                                    Image("icon_placeholder")
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(11)
                                        .frame(width: imageSize?.width)
                                },
                                image: {
                                    $0.resizable()
                                        .scaledToFit()
                                        .cornerRadius(11)
                                        .overlay(RoundedRectangle(cornerRadius: 11)
                                            .stroke(Color.gray, lineWidth: 0.1)
                                            .frame(width: imageSize?.width, height: imageSize?.height))
                                        .frame(width: imageSize?.width, height: imageSize?.height)
                                }
                            )
                        }
                        .padding([.leading, .trailing], 3)
                        .sheet(isPresented: $selectedShot) {
                            AppDetailBigImageShowView(selectedShot: $selectedShot, selectedImgUrl: $selectedImgUrl)
                        }
                    }
                }
            }
        }.padding([.leading, .trailing], 8)
    }
}

// MARK: - AppDetailBigImageShowView
/// 大图预览视图
struct AppDetailBigImageShowView: View {
    @Binding var selectedShot: Bool
    @Binding var selectedImgUrl: String?
    @State var showSheet = false
    @State private var shareImage: UIImage?
    
    var body: some View {
        HStack {
            Button {
                showSheet.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up.fill").imageScale(.large)
            }
            .frame(width: 60, height: 60, alignment: .center)
            .padding([.top, .leading], 8)
            .sheet(isPresented: $showSheet) {
                if let urlString = selectedImgUrl,
                   let url = URL(string: urlString),
                   let data = try? Data(contentsOf: url),
                   let img = UIImage(data: data) {
                    ShareSheet(items: [img])
                }
            }
            
            Spacer()
            
            Button {
                selectedShot = false
            } label: {
                Image(systemName: "xmark.circle.fill").imageScale(.large)
            }
            .frame(width: 60, height: 60, alignment: .center)
            .padding([.top, .trailing], 8)
        }
        
        Spacer()
        
        ImageLoaderView(
            url: selectedImgUrl,
            placeholder: {
                Image("icon_placeholder").resizable().scaledToFit()
            },
            image: {
                $0.resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 0.1))
            },
            completion: { img in
                DispatchQueue.main.async { shareImage = img }
            }
        ).padding([.leading, .trailing], 5)
        
        Spacer()
    }
}

// MARK: - MoreParagraphView
/// 可展开的段落视图
struct MoreParagraphView: View {
    let text: String?
    @State private var showMoreText = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack {
                Text(paragraphText)
                    .font(.subheadline)
                    .lineLimit(showMoreText ? .max : 3)
                Spacer()
            }
            if !showMoreText {
                Button("更多") {
                    withAnimation { showMoreText = true }
                }
                .font(.subheadline)
                .foregroundColor(Color.blue)
                .background(Color.tsmg_systemBackground)
                .offset(x: 5, y: 0)
                .shadow(color: .tsmg_systemBackground.opacity(0.9), radius: 3, x: -12)
            }
        }
    }
    
    private var paragraphText: String {
        text ?? ""
    }
}

// MARK: - AppDetailFooterCellView
/// 底部信息单元格视图
struct AppDetailFooterCellView: View {
    var name: String
    var description: String
    var extendText: String?
    @State private var isShowExtendText = false
    
    var body: some View {
        Group {
            if extendText == nil {
                HStack {
                    Text(name).font(.subheadline).foregroundColor(.gray)
                    Spacer()
                    Text(description).font(.subheadline)
                }
            } else {
                if isShowExtendText {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(name).font(.subheadline).foregroundColor(.gray)
                            Text(description).font(.subheadline)
                            if extendText != nil && description != extendText {
                                Text(extendText ?? "").font(.subheadline)
                            }
                        }
                        Spacer()
                    }
                } else {
                    HStack {
                        Text(name).font(.subheadline).foregroundColor(.gray)
                        Spacer()
                        Text(description).font(.subheadline)
                        Image(systemName: "chevron.down").foregroundColor(.gray).font(.body)
                    }
                    .background(Color.tsmg_systemBackground)
                    .onTapGesture { isShowExtendText = true }
                }
            }
        }
        .padding([.top, .bottom], 10)
        .padding([.leading, .trailing], 12)

        Divider().padding(.top, 5).padding([.leading, .trailing], 10)
    }
}
