//
//  HTMLString.swift
//  News
//
//  Created by yavuz on 25/10/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation

extension String {
    static func stringByRemovingHTMLEntities(string: String) -> String {
        var result = string
        
        result = result.stringByReplacingOccurrencesOfString("<p>", withString: "\n\n", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("</p>", withString: "", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("<i>", withString: "", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("</i>", withString: "", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#38;", withString: "&", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#62;", withString: ">", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#x27;", withString: "'", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#x2F;", withString: "/", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&quot;", withString: "\"", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#60;", withString: "<", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&lt;", withString: "<", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("<pre><code>", withString: "", options: .CaseInsensitiveSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("</code></pre>", withString: "", options: .CaseInsensitiveSearch, range: nil)

        var regex = NSRegularExpression()
        do {
            regex = try NSRegularExpression(pattern: "<a[^>]+href=\"(.*?)\"[^>]*>.*?</a>",
                options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            print("Something went wrong!")
        }
        
        result = regex.stringByReplacingMatchesInString(result, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, result.utf16.count), withTemplate: "$1")
        
        return result
    }
    
    static func ReplaceHTMLTag(htmlString:String,mypattern:String,mytemplate:String) -> String {
        var hString = htmlString
        
        
        var regex = NSRegularExpression()
        do {
            regex = try NSRegularExpression(pattern: mypattern,
                options: NSRegularExpressionOptions.CaseInsensitive)
        } catch {
            print("Something went wrong!")
        }
        
        hString = regex.stringByReplacingMatchesInString(hString, options: NSMatchingOptions.Anchored, range: NSMakeRange(0, hString.utf16.count), withTemplate: mytemplate)
        return hString
    }
    
    static func RemoveHTMLStyle(hString:String) ->String {
        var myHTMLString = hString
        var pattern1 = "<img[^>]+src=\"(.*?)\"[^>]*>"
        myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: pattern1, mytemplate: "<img src=\"$1\" class=\"yukanewsimage\" />")
        
        pattern1 = "<a[^>]+href=\"(.*?)\"[^>]*>(.*?)</a>"
        myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: pattern1, mytemplate: "<a href=\"$1\">$2</a>")
        
        // ul lerin stylerini sil
        pattern1 = "<ul[^>]*>(.*?)</ul>"
        myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: pattern1, mytemplate: "<ul>$1</ul>")
        
        // li lerin stylerini sil
        pattern1 = "<li[^>]*>(.*?)</li>"
        myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: pattern1, mytemplate: "<li>$1</li>")
        
        // div lerin stylerini sil
        pattern1 = "<div[^>]*>(.*?)</div>"
        myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: pattern1, mytemplate: "<div>$1</div>")
        
        // p lerin stylerini sil
        pattern1 = "<p[^>]*>(.*?)</p>"
        myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: pattern1, mytemplate: "<p>$1</p>")
        
        // butun textleri div icine almak
        pattern1 = "(^|>)(?:([^<]+)($|<[^>]+))?"
        myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: pattern1, mytemplate: "$1<div class=\"textClass\">$2</div>$3")
        
        //bos divleri temizle
        //pattern1 = "<div class=\"textClass\"> </div>"
        //myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: pattern1, mytemplate: "")

        return myHTMLString
    }
    
    static func FindImageTag(Summary:String,Enclosures:String,Image:String) -> [String:String] {
        var nimage:String = ""
        var status:String = "no"
        var tempSummary:String!
        
        // if enclosures not empty
        if !Enclosures.isEmpty {
            nimage = Enclosures
            status = "enclosures"
        }
        
        if nimage.isEmpty && !Image.isEmpty {
            nimage = Image
            status = "image"
        }
        //println(Summary)
        if !Summary.isEmpty {
            //println("summarye girdi")
            var tempimage:String = ""
            if !nimage.isEmpty {
                tempimage = nimage// as String
            }
            
            tempSummary = Summary.stringByReplacingOccurrencesOfString("src=\"//", withString: "src=\"http://")
            tempSummary = tempSummary.stringByReplacingOccurrencesOfString("src=\"://", withString: "src=\"http://")

            nimage = scanTag(tempSummary, startTag: "src=\"", endTag: "\"") as String
            
            if nimage.isEmpty {
                nimage = scanTag(tempSummary, startTag: "src=\'", endTag: "\'") as String
            }

            if !nimage.isEmpty && (tempimage == nimage || tempimage.isEmpty){
                status = "summary"
            } else {
                nimage = tempimage
            }
        }
        
        if nimage.isEmpty {
            nimage = String()
            status = "no"
        }
        
        return ["image":nimage,"status":status]
    }
}