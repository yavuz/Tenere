//
//  Config.swift
//  Yuka
//
//  Created by yavuz on 08/06/15.
//  Copyright (c) 2015 yuka. All rights reserved.
//

import Foundation
//import SwiftyJSON

class ConfigApp {
    
    
    func readConfigFile()->NSDictionary {
        //let jsonData: NSData = /* get your json data */
        let filepath = NSBundle.mainBundle().pathForResource("config", ofType: "json")
        var jsonData = NSData()
        do {
            jsonData = try NSData(contentsOfFile: filepath!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }

        var jsonDict = NSDictionary()
        do {
            jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return jsonDict
        //let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSDictionary
        /*
        
        let json = SwiftyJSON.JSON(data: jsonData!)
        var items = []
        return json*/
        /*
        for(key: String, SearchData: JSON) in json {
            
            println(SearchData);
            //var ObjectData = [String: String]()
            
            //ObjectData["name"] = SearchData["title"].stringValue
            //ObjectData["url"] = SearchData["rsslink"].stringValue
            //ObjectData["favicon"] = SearchData["favicon"].stringValue
            //let identifier = SearchData["identifier"].stringValue
            //var ident = SearchData["rsslink"].stringValue
            //ObjectData["identifier"] = ident.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            //let searchname = turkishSlug(name).lowercaseString
            //self.items.append(ObjectData)
        }
*/
    }
    
    func setConfigDefaultVariable(configVariable:NSDictionary) {
        // config degiskenleri set edilecek
        Defaults["appconfig"] = configVariable
    }
    
    func readSourcesFile()->NSArray {
        //let jsonData: NSData = /* get your json data */
        let filepath = NSBundle.mainBundle().pathForResource("config", ofType: "json")
        var jsonData = NSData()
        do {
            jsonData = try NSData(contentsOfFile: filepath!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        var jsonDict = NSDictionary()
        do {
            jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        //let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSArray
        
        return jsonDict["menu"]! as! NSArray
    }
    
}