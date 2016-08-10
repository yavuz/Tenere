//
//  Device.swift
//  DeviceType
//
//  Created by ZhaoWei on 14-9-28.
//  Copyright (c) 2014年 csdept. All rights reserved.
//

import Foundation
import UIKit

class Device : NSObject {
    
    enum DeviceType: Int
    {
        case DT_UNKNOWN = 0
        case DT_iPhone4S          //iPhone4S、iPhone4
        case DT_iPhone5           //iPhone5、iPhone5C和iPhone5S
        case DT_iPhone6           //iPhone6
        case DT_iPhone6_Plus      //iPhone6 Plus
        case DT_iPad              //iPad1、iPad2
        case DT_iPad_Mini         //iPad mini1
        case DT_iPad_Retina       //New iPad、iPad4和iPad Air
        case DT_iPad_Mini_Retina  //iPad mini2
    }
    
    struct Singleton {
        static let _sharedInstance = Device()
    }
    
    /**
    获取当前设备(单例)
    */
    class var currentDevice : Device {
        return Singleton._sharedInstance
    }
    
    /**
    根据屏幕分辨率判断设备类型
    */
    var deviceType: DeviceType {
        
        if let size = UIScreen.mainScreen().currentMode?.size {
            switch size {
            case CGSizeMake(640 , 960 ) : return .DT_iPhone4S
            case CGSizeMake(640 , 1136) : return .DT_iPhone5
            case CGSizeMake(750 , 1334) : return .DT_iPhone6
            case CGSizeMake(1242, 2208) : return .DT_iPhone6_Plus
            case CGSizeMake(1024, 768 ) : return .DT_iPad
            case CGSizeMake(768 , 1024) : return .DT_iPad_Mini
            case CGSizeMake(2048, 1536) : return .DT_iPad_Retina
            case CGSizeMake(1536, 2048) : return .DT_iPad_Mini_Retina
            default : return .DT_UNKNOWN
            }
        }
        else {
            return .DT_UNKNOWN
        }
    }
    
    /**
    判断当前设备是不是iPhone设备
    */
    func isPhone() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Phone
    }
    
    /**
    判断当前设备是不是iPad设备
    */
    func isPad() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
    /**
    判断当前设备是不是iPad mini
    */
    func isPadMini() -> Bool {
        if isPad() {
            let type = deviceType
            if type == .DT_iPad_Mini || type == .DT_iPad_Mini_Retina {
                return true
            }
        }
        
        return false
    }
    
    /**
    判断当前设备是不是iPad设备，不包括iPad mini
    */
    func isBigPad() -> Bool {
        if isPad() && isPadMini() == false {
            return true
        }
        
        return false
    }
    
    /**
    判断当前设备的系统版本是否大于或者等于#version
    */
    func isGE(version version: String) -> Bool {
        return compare(version: version) != .OrderedAscending
    }
    
    func compare(version version: String) -> NSComparisonResult {
        return UIDevice.currentDevice().systemVersion.compare(version, options: NSStringCompareOptions.NumericSearch)
    }
}

//Test Function
func testDevice()
{
    let device: Device = Device.currentDevice;
    
    //version
    if device.isGE(version: "8.0") {
        print("version >= 8.0")
    }
    else if device.isGE(version: "7.0") {
        print("version == 7.0")
    }
    else {
        print("version < 7.0")
    }
    
    //iPad or iPhone
    if device.isPad() {
        print("iPad")
        
        if device.isPadMini() {
            print("iPad mini")
        }
        else if device.isBigPad() {
            print("9.7-inch iPad")
        }
    }
    else if (device.isPhone()) {
        print("iPhone")
    }
    
    //Device Type
    let type = device.deviceType
    
    switch type {
    case Device.DeviceType.DT_iPhone4S:         print("iPhone4S")
    case Device.DeviceType.DT_iPhone5:          print("iPhone5")
    case Device.DeviceType.DT_iPhone6:          print("iPhone6")
    case Device.DeviceType.DT_iPhone6_Plus:     print("iPhone6_Plus")
    case Device.DeviceType.DT_iPad:             print("iPad")
    case Device.DeviceType.DT_iPad_Mini:        print("iPad_Mini")
    case Device.DeviceType.DT_iPad_Retina:      print("iPad_Retina")
    case Device.DeviceType.DT_iPad_Mini_Retina: print("iPad_Mini_Retina")
    default:                                    print("Unknown")
    }
}

