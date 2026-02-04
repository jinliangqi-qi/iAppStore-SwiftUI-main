//
//  QRCodeView.swift
//  iAppStore
//
//  Created by iHTCboy on 2023/6/24.
//  Copyright © 2023 37 Mobile Games. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    
    let title: String
    let subTitle: String
    let qrCodeContent: String
    @Binding var isShowingQRCode: Bool
    @State var showShareSheet = false
    
    var body: some View {
        VStack {
            
            HStack {
                Button {
                    showShareSheet.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.up.fill").imageScale(.large)
                }
                .frame(width: 60, height: 60, alignment: .center)
                .padding([.top, .leading], 8)
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [generateQRCode(from: qrCodeContent)])
                }
                
                Spacer()
                
                Text(title)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                Button {
                    isShowingQRCode = false
                } label: {
                    Image(systemName: "xmark.circle.fill").imageScale(.large)
                }
                .frame(width: 60, height: 60, alignment: .center)
                .padding([.top, .trailing], 8)
            }
            
            Spacer()
            
            // 使用 SwiftUI Image 显示二维码
            qrCodeImage
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .padding([.leading, .trailing], 50)
                .frame(maxWidth: 500)
            
            Text(subTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(.tint)
            
            Spacer()
        }
    }
    
    /// 生成二维码的 SwiftUI Image
    private var qrCodeImage: Image {
        let data = qrCodeContent.data(using: .utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let outputImage = filter.outputImage {
                let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
                let context = CIContext()
                
                if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                    return Image(uiImage: UIImage(cgImage: cgImage))
                }
            }
        }
        
        return Image(systemName: "qrcode")
    }
    
    /// 生成二维码 UIImage（用于分享）
    private func generateQRCode(from string: String) -> UIImage {
        let data = string.data(using: .utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let outputImage = filter.outputImage {
                let context = CIContext()
                let scale = UIScreen.main.scale
                
                let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
                
                if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                    return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
                }
            }
        }
        
        return UIImage(systemName: "qrcode") ?? UIImage()
    }
}

#Preview {
    QRCodeView(title: "扫一扫下载", subTitle: "App Store 上的凡人修仙传", qrCodeContent: "https://apps.apple.com/cn/app/69437212", isShowingQRCode: .constant(false))
}
