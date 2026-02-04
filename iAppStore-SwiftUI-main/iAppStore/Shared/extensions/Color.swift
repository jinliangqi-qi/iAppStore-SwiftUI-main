//
//  Color.swift
//  iAppStore
//
//  Created by HTC on 2021/12/15.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    public static var tsmg_blue: Color {
        Color("tsmg_blue", bundle: nil)
    }
    
    // MARK: - System Background Colors (SwiftUI Native)
    
    static var tsmg_systemBackground: Color {
        Color(uiColor: .systemBackground)
    }
    
    static var tsmg_secondarySystemBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
    
    static var tsmg_tertiarySystemBackground: Color {
        Color(uiColor: .tertiarySystemBackground)
    }
    
    // MARK: - Grouped Background Colors
    
    static var tsmg_systemGroupedBackground: Color {
        Color(uiColor: .systemGroupedBackground)
    }
    
    static var tsmg_secondarySystemGroupedBackground: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }
    
    static var tsmg_tertiarySystemGroupedBackground: Color {
        Color(uiColor: .tertiarySystemGroupedBackground)
    }
    
    // MARK: - Label Colors
    
    static var tsmg_label: Color {
        Color(uiColor: .label)
    }
    
    static var tsmg_secondaryLabel: Color {
        Color(uiColor: .secondaryLabel)
    }
    
    static var tsmg_tertiaryLabel: Color {
        Color(uiColor: .tertiaryLabel)
    }
    
    static var tsmg_placeholderText: Color {
        Color(uiColor: .placeholderText)
    }
}
