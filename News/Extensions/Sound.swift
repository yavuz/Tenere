//
//  Sound.swift
//  Yuka
//
//  Created by yavuz on 28/03/15.
//  Copyright (c) 2015 yuka. All rights reserved.
//

import Foundation
import AudioToolbox

class AppSound {
    
    var audioEffect : SystemSoundID = 0
    init(name : String, type: String) {
        let path  = NSBundle.mainBundle().pathForResource(name, ofType: type)!
        let pathURL = NSURL(fileURLWithPath: path)
        AudioServicesCreateSystemSoundID(pathURL, &audioEffect)
    }
    
    func play() {
        AudioServicesPlaySystemSound(audioEffect)
    }
}