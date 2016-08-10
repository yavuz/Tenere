//
//  HTMLScanner.swift
//  News
//
//  Created by yavuz on 25/10/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation

func scanTag(f:NSString, startTag: NSString, endTag: NSString) -> NSString {
    
    let test = NSScanner(string: f as String)
    var result: NSString? = ""
    
    test.scanUpToString(startTag as String, intoString: nil)
    test.scanString(startTag as String, intoString: nil)
    test.scanUpToString(endTag as String, intoString: &result)
    return result!
}