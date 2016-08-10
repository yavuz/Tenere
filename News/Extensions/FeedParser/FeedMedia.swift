//
//  FeedEnclosure.swift
//
//  Created by Nacho on 12/10/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

class FeedMedia: NSObject {
    var url: String
    var type: String
    
    init(url: String, type: String) {
        self.url = url
        self.type = type
    }
}
