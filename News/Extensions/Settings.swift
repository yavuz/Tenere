//
//  Settings.swift
//  Yuka
//
//  Created by yavuz on 29/03/15.
//  Copyright (c) 2015 yuka. All rights reserved.
//

import Foundation

public func StatusSounds()->Bool {
    if Defaults.hasKey("appsounds") {
        if Defaults["appsounds"].int == 1 {
            return true
        } else {
            return false
        }
    }
    return false
}

public func StatusAutoRefresh()->Bool {
    if Defaults.hasKey("appautorefresh") {
        if Defaults["appautorefresh"].int == 1 {
            return true
        } else {
            return false
        }
    }
    return false
}