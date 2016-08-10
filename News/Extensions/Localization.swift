import Foundation


public func localizedString(string: String) -> String {
    
    let languageSelected:String = StatusLanguage()
    let langpath:String = NSBundle.mainBundle() .pathForResource(languageSelected, ofType:"lproj")!
    let langBundle:NSBundle = NSBundle(path:langpath)!
    let langString:String = langBundle.localizedStringForKey(string, value:"", table: nil)
    return langString
    //return NSLocalizedString(string, comment: "")
}

extension String {
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

public func ChangeLanguage(lang:String)->Void {
    NSUserDefaults.standardUserDefaults().setObject([lang], forKey: "AppleLanguages")
    NSUserDefaults.standardUserDefaults().synchronize()
    Defaults["applang"] = lang // => "white"
    
    /*
    let language = "tr"
    let path = NSBundle.mainBundle().pathForResource(language, ofType: "lproj")
    let bundle = NSBundle(path: path!)
    let string = bundle?.localizedStringForKey("key", value: nil, table: nil)
    */
}

public func StatusLanguage()->String {
    if Defaults.hasKey("applang") {
        return Defaults["applang"].string!
    }
    return "en"
}