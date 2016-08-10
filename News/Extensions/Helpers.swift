//
//  Helpers.swift
//  News
//
//  Created by yavuz on 06/12/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation


// Grabbed from comments on
// http://codewithchris.com/common-mistakes-with-adding-custom-fonts-to-your-ios-app/
func listAllAvailableFonts() {
    for family: AnyObject in UIFont.familyNames() {
        print("\(family)")
        for font: AnyObject in UIFont.fontNamesForFamilyName(family as! NSString as String) {
            print(" \(font)")
        }
    }
}

func slug(text:String) -> String {
    var stext = text.stringByReplacingOccurrencesOfString("ğ", withString: "g", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ü", withString: "u", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ş", withString: "s", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ç", withString: "c", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ö", withString: "o", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ı", withString: "i", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("â", withString: "a", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("û", withString: "u", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ğ", withString: "g", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ü", withString: "u", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ş", withString: "s", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ç", withString: "c", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ö", withString: "o", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("İ", withString: "i", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("î", withString: "i", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("?", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("!", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString(".", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("'", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("\\", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString(":", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)

    stext = stext.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    
    stext = stext.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
    return stext;
}

func readFile(fileName: String, fileType: String) -> String{
    let path = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)
    var contents = String()
    
    do {
        contents = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
    } catch {
        print("error")
    }
    
    
    //var contents = String(contentsOfFile:path!, encoding: NSUTF8StringEncoding, error: nil)

    return contents
}

//--- Convert SDate to Date String ---//
func dateformatterDate(date: NSDate) -> NSString {
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy H:m:s"
    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
    
    return dateFormatter.stringFromDate(date)
}


func validateUrl(candidate:String) ->Bool {
    let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
    let urlTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@",urlRegEx)
    return urlTest.evaluateWithObject(candidate)
}

func turkishSlug(text:String) -> String {
    var stext = text.stringByReplacingOccurrencesOfString("ğ", withString: "g", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ü", withString: "u", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ş", withString: "s", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ç", withString: "c", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ö", withString: "o", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("ı", withString: "i", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ğ", withString: "g", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ü", withString: "u", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ş", withString: "s", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ç", withString: "c", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("Ö", withString: "o", options: NSStringCompareOptions.LiteralSearch, range: nil)
    stext = stext.stringByReplacingOccurrencesOfString("İ", withString: "i", options: NSStringCompareOptions.LiteralSearch, range: nil)
    
    stext = stext.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    
    return stext;
}

func textField(textField: UITextField,
    shouldChangeCharactersInRange range: NSRange,
    replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
        let components = string.componentsSeparatedByCharactersInSet(inverseSet)
        let filtered = components.joinWithSeparator("")
        return string == filtered
        
}

// word limit
func textCharacterLimit(text:String,range:Int) ->String {
    var myStringArr = text.componentsSeparatedByString(" ")
    var rdata = ""
    let limit = range
    for var a=0; a < limit; a++ {
        if a < myStringArr.count {
            rdata += myStringArr[a]+" "
        }
    }
    return rdata
}

func convertCountryCode(var code:String) -> String {
    if code == "en" { code="us" }
    return code.uppercaseString
}

extension String {
    var pathExtension: String? {
        return NSString(string: self).pathExtension
    }
    var lastPathComponent: String? {
        return NSString(string: self).lastPathComponent
    }
}
/*
func getBase64FromFile(fileName:String,ofType:String) {
    var filePath:String = NSBundle.mainBundle().pathForResource(fileName, ofType: ofType)!
    var sdata = NSData(contentsOfFile: filePath, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)

    var base64Encoded = sdata?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    return base64Encoded
}*/

/*
func getURLData(DataURL:String) -> NSString {
    let url = NSURL(string: DataURL)
    let request = NSURLRequest(URL: url!)
    var RData:NSString!
    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
        RData = NSString(data: data, encoding: NSUTF8StringEncoding)
        println(RData)
    }
    
    return RData
}
*/