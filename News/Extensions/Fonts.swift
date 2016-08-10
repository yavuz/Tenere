//
//  Fonts.swift
//  News
//
//  Created by yavuz on 04/12/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation

struct Font {
    static let DEFAULT_SMALL_SIZE: CGFloat = 14
    static let DEFAULT_SIZE: CGFloat = 16
    static let DEFAULT_LARGE_SIZE: CGFloat = 20
    static let READ_TEXT_SIZE: CGFloat = 16
    static let SECONDARY_SIZE: CGFloat = 15
    static let DEFAULT_FONT_NAME: String = "OpenSans-Light"
    static let DEFAULT_FONT_MEDIUM_NAME: String = "OpenSans"
    static let DEFAULT_BOLD_FONT_NAME: String = "OpenSans-Bold"
    static let MENU_FONT_NAME: String = "OpenSans-Light"
    static let ITALIC_FONT_NAME: String = "OpenSans-Light"
    static let WEB_DEFAULT_FONT_NAME: String = "OpenSans-Light"
    static let WEB_TITLE_DEFAULT_FONT_NAME: String = "OpenSans-Bold"
    
    //static let primaryFont = UIFont.systemFontOfSize(PRIMARY_SIZE)
    //static let boldPrimaryFont = UIFont.boldSystemFontOfSize(PRIMARY_SIZE)
    
    static let defaultSmallFont = UIFont(name: ITALIC_FONT_NAME, size: DEFAULT_SMALL_SIZE)
    static let defaultFont = UIFont(name: DEFAULT_FONT_NAME, size: DEFAULT_SIZE)
    static let defaultMediumFont = UIFont(name: DEFAULT_FONT_MEDIUM_NAME, size: DEFAULT_SIZE)
    static let defaultLargeFont = UIFont(name: DEFAULT_FONT_MEDIUM_NAME, size: DEFAULT_LARGE_SIZE)
    static let defaultFontColor = UIColor(rgba: "#333333")
    static let defaultBoldFont = UIFont(name: DEFAULT_BOLD_FONT_NAME, size: DEFAULT_SIZE)
    static let defaultBoldFontColor = UIColor(rgba: "#333333")
    static let menuFont = UIFont(name: MENU_FONT_NAME, size: DEFAULT_SIZE)
    static let menuFontColor = UIColor(rgba: "#222222")

}