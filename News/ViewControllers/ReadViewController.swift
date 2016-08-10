//
//  ReadViewController.swift
//  News
//
//  Created by yavuz on 09/10/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ReadViewController: UIViewController, WKScriptMessageHandler {
    var newsid:String!
    var webView:WKWebView = WKWebView()
    var webView2:WKWebView = WKWebView()
    let db = SQLiteDB.sharedInstance()
    var isLoadWebView:Bool = false
    var device: Device = Device.currentDevice
    var BottomBar:UIView!
    var containerAnimationView:UIView!
    var upnewsid:String!
    var downnewsid:String!
    var webViewState:String = "webview1"
    var webViewCommon:WKWebView!
    var upButton:UIButton!
    var downButton:UIButton!
    var shareButton:UIButton!
    var readButton:UIButton!
    var topBorder:UIView!
    var firstTouch:Bool = false
    var newslink:String!
    var RTLState:Bool = false
    var AppColors = NSDictionary()

    override func viewDidLoad() {
        /*
        self.view.layoutMargins = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0)
        */
        
        let ConfigData = Defaults["appconfig"].dictionary
        self.AppColors = ConfigData?["color"] as! NSDictionary
        
        let bottomHeight:CGFloat = 45.0;
        
        let bbutton:UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = bbutton

        self.navigationController?.navigationItem.backBarButtonItem = bbutton
        

        self.containerAnimationView = UIView(frame: CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.width, (self.view.bounds.height-bottomHeight)))
        //
        
        if device.isPad() {
            self.navigationItem.hidesBackButton = true
            self.navigationController?.navigationBar.backgroundColor = UIColor(rgba: (self.AppColors["mainnavigationtitle"] as! String))
            self.navigationController?.navigationBar.barTintColor = UIColor(rgba: (self.AppColors["mainnavigationtitle"] as! String))
            self.navigationController?.navigationBar.tintColor = UIColor(rgba: (self.AppColors["mainnavigationtitletint"] as! String))
            self.navigationController?.navigationBar.translucent = false
        }

        //let source = "document.body.style.background = \"#CCC\";"
        //let userScript = WKUserScript(source: source, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        //userContentController.addUserScript(userScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.userContentController.addScriptMessageHandler(self, name: "ShowWebView")
        
        self.webView = WKWebView(frame: self.containerAnimationView.bounds, configuration: configuration)
        self.webView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.webView.allowsBackForwardNavigationGestures = false
        
        self.view.backgroundColor = UIColor(rgba: (self.AppColors["maincolor"] as! String))
        self.webView.backgroundColor = UIColor(rgba: (self.AppColors["maincolor"] as! String))
        self.webView.tag = 200
        self.webViewCommon = self.webView
        
        self.webView2 = WKWebView(frame: self.containerAnimationView.bounds, configuration: configuration)
        self.webView2.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.webView2.allowsBackForwardNavigationGestures = false
        self.webView2.tag = 201
        self.webView2.backgroundColor = UIColor(rgba: (self.AppColors["maincolor"] as! String))
        self.webView2.hidden = true
        
        self.containerAnimationView.addSubview(self.webViewCommon)
        self.containerAnimationView.addSubview(self.webView2)
        self.containerAnimationView.backgroundColor = UIColor(rgba: (self.AppColors["maincolor"] as! String))
        self.view.addSubview(self.containerAnimationView)
        
        self.BottomBar = UIView(frame: CGRectMake(0,(self.view.bounds.height),self.view.bounds.width,45))
        //self.BottomBar.backgroundColor = UIColor.purpleColor()
        self.BottomBar.backgroundColor = UIColor(rgba: (self.AppColors["mainnavigationfooter"] as! String))

        let buttonOriginalWidth:CGFloat = 70
        let buttonOriginalHeight:CGFloat = 46
        let imageScale1:CGFloat = 10.0
        let imageScale2:CGFloat = imageScale1*1.521739
        self.upButton = UIButton(frame: CGRectMake(0, 0, buttonOriginalWidth, buttonOriginalHeight))
        //self.upButton.backgroundColor = UIColor.redColor()
        self.upButton.setImage(UIImage(named: "uparrow"), forState: UIControlState.Normal)
        self.upButton.addTarget(self, action: "upNewsView:", forControlEvents: UIControlEvents.TouchUpInside)
        self.upButton.imageEdgeInsets = UIEdgeInsetsMake(imageScale1,imageScale2,imageScale1,imageScale2)

        self.BottomBar.addSubview(self.upButton)
        
        self.downButton = UIButton(frame: CGRectMake(0, 0, buttonOriginalWidth, buttonOriginalHeight))
        //self.downButton.backgroundColor = UIColor.brownColor()
        //self.downButton.imageView = UIImage(named: "downarrow")
        self.downButton.setImage(UIImage(named: "downarrow"), forState: UIControlState.Normal)
        self.downButton.addTarget(self, action: "downNewsView:", forControlEvents: UIControlEvents.TouchUpInside)
        self.downButton.imageEdgeInsets = UIEdgeInsetsMake(imageScale1,imageScale2,imageScale1,imageScale2)
        self.BottomBar.addSubview(self.downButton)
        //self.BottomBar.hidden = true
        self.view.addSubview(self.BottomBar)

        //let imageScale3:CGFloat = 3.0
        //let imageScale4:CGFloat = imageScale3*1.42
        self.shareButton = UIButton(frame: CGRectMake(0, -2, 75,49))
        //self.downButton.imageView = UIImage(named: "downarrow")
        self.shareButton.setImage(UIImage(named: "sharearrow"), forState: UIControlState.Normal)
        self.shareButton.addTarget(self, action: "shareButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.shareButton.imageEdgeInsets = UIEdgeInsetsMake(imageScale1,imageScale2,imageScale1,imageScale2)
        self.BottomBar.addSubview(self.shareButton)
        //self.BottomBar.hidden = true
        
        self.readButton = UIButton(frame: CGRectMake(0, 0, buttonOriginalWidth, buttonOriginalHeight))
        //self.readButton.backgroundColor = UIColor.brownColor()
        //self.downButton.imageView = UIImage(named: "downarrow")
        self.readButton.setImage(UIImage(named: "readarrow"), forState: UIControlState.Normal)
        self.readButton.addTarget(self, action: "readButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.readButton.imageEdgeInsets = UIEdgeInsetsMake(imageScale1,imageScale2,imageScale1,imageScale2)
        self.BottomBar.addSubview(self.readButton)
        //self.BottomBar.hidden = true
        self.view.addSubview(self.BottomBar)
        
        
        self.topBorder = UIView(frame: CGRectMake(0, 0, self.BottomBar.bounds.width, 1))
        self.topBorder.backgroundColor = UIColor.blackColor()
        self.topBorder.alpha = 0.3
        self.BottomBar.addSubview(self.topBorder)
        
        if self.newsid == nil {
            //self.getNewsData(self.newsid)
            self.shareButton.enabled = false
            self.upButton.enabled = false
            self.downButton.enabled = false
            self.readButton.enabled = false
            
        } else {
            

        }
        
        constrain(self.BottomBar,self.view) { bview,mview in
            bview.width == mview.width
            bview.height == 45
            bview.bottom == mview.bottom
            //sview.top == nview.bottom
            //sview.width == (nview.superview?.width)!
            //nview.top == (nview.superview?.top)!
        }
        //self.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        //self.containerAnimationView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        /*
        layout((self.navigationController?.navigationBar)!,self.view) { nview,mview in
            mview.top == nview.bottom
            mview.bottom == (mview.superview?.bottom)!
        }
        */
/*
        cview.height == mview.height-40
        cview.top == mview.top
        cview.width == mview.width
        */


        //self.webViewCommon.hidden = true
    }

    func shareButtonAction(sender:UIButton) {
        if !device.isPad() {
            let tstring = self.newsid+"\n"+self.newslink
            let firstActivityItem = tstring
            let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
            self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
        } else {
            let text = self.newsid
            let url = self.newslink
            let controller = UIActivityViewController(activityItems: [text, url], applicationActivities:nil)
            
            presentViewController(controller, animated: true, completion: nil)
            
            if controller.respondsToSelector("popoverPresentationController") {
                // iOS 8+
                let presentationController = controller.popoverPresentationController
                presentationController?.sourceView = view
            }
        }
    }
    
    func readButtonAction(sender:UIButton) {
        self.OpenWebView(self.newslink)
    }
    
    func bottomBarButtonReload() {
        if self.BottomBar != nil {
            let buttonOriginalWidth:CGFloat = 70
            //let buttonOriginalHeight:CGFloat = 46
            let barWidth = self.BottomBar.bounds.width
            let buttonWidth = (barWidth-(buttonOriginalWidth*4))/5
            let buttonMargin = buttonWidth
            var buttonx:CGFloat = buttonMargin
            
            self.upButton.frame.origin.x = buttonx
            buttonx = buttonx+buttonOriginalWidth+buttonMargin
            self.downButton.frame.origin.x = buttonx
            buttonx = buttonx+buttonOriginalWidth+buttonMargin
            self.shareButton.frame.origin.x = buttonx
            buttonx = buttonx+buttonOriginalWidth+buttonMargin
            self.readButton.frame.origin.x = buttonx
            self.topBorder.frame.size.width = barWidth
        }
    }
    
    func downNewsView(sender:UIButton) {
        self.upButton.userInteractionEnabled = false
        self.downButton.userInteractionEnabled = false
        if self.downnewsid != nil {
            
            var tempstate = "webview1"
            if (self.webViewState == "webview1") {
                tempstate="webview2"
            }
            
            self.getNewsData(self.downnewsid,webViewStatement: tempstate)
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.containerAnimationView.frame.origin.y = -self.view.bounds.height
                self.containerAnimationView.alpha = 0
            }, completion: { finished in
                if (self.webViewState == "webview1") {
                    self.webView2.hidden = false
                    self.webViewCommon = self.webView2
                } else {
                    self.webView.hidden = false
                    self.webViewCommon = self.webView
                }
                
                self.containerAnimationView.frame.origin.y = self.view.bounds.height
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    
                    if self.webViewState == "webview1" && self.device.isPhone() {
                        self.containerAnimationView.frame.origin.y = 60
                    } else {
                        self.containerAnimationView.frame.origin.y = 0
                    }
                    
                    self.containerAnimationView.alpha = 1
                    if (self.webViewState == "webview1") {
                        self.webView.hidden = true
                        self.webView.loadHTMLString("", baseURL: nil)
                        self.webViewState = "webview2"
                    } else {
                        self.webView2.hidden = true
                        self.webView2.loadHTMLString("", baseURL: nil)
                        self.webViewState = "webview1"
                    }
                    }, completion: { finished in
                        //self.webViewCommon.hidden = true
                        //self.containerAnimationView.frame.origin.y = 60
                        
                        self.upButton.userInteractionEnabled = true
                        self.downButton.userInteractionEnabled = true
                        
                        if self.webViewState == "webview2" {
                            //self.webView2.frame.origin.y = (self.navigationController?.navigationBar.bounds.height)!+20
                        }
                })
                
        })
    }
    
    func upNewsView(sender:UIButton) {
        self.upButton.userInteractionEnabled = false
        self.downButton.userInteractionEnabled = false
        if self.upnewsid != nil {
            
            var tempstate = "webview1"
            if (self.webViewState == "webview1") {
                tempstate="webview2"
            }
            
            self.getNewsData(self.upnewsid,webViewStatement: tempstate)
        }
        //
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.containerAnimationView.frame.origin.y = self.view.bounds.height
            self.containerAnimationView.alpha = 0
            }, completion: { finished in
                if (self.webViewState == "webview1") {
                    self.webView2.hidden = false
                    self.webViewCommon = self.webView2
                } else {
                    self.webView.hidden = false
                    self.webViewCommon = self.webView
                }

                self.containerAnimationView.frame.origin.y = -self.view.bounds.height
                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {

                    
                    if self.webViewState == "webview1" && self.device.isPhone() {
                        self.containerAnimationView.frame.origin.y = 60
                    } else {
                        self.containerAnimationView.frame.origin.y = 0
                    }
                    self.containerAnimationView.alpha = 1
                    if (self.webViewState == "webview1") {
                        self.webView.hidden = true
                        self.webView.loadHTMLString("", baseURL: nil)
                        self.webViewState = "webview2"
                    } else {
                        self.webView2.hidden = true
                        self.webView2.loadHTMLString("", baseURL: nil)
                        self.webViewState = "webview1"
                    }
                    }, completion: { finished in
                        self.upButton.userInteractionEnabled = true
                        self.downButton.userInteractionEnabled = true
                        
                })
                
        })


    }
    
    override func viewWillAppear(animated: Bool) {
        //viewWillAppear
        super.viewWillAppear(true)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.isLoadWebView = false
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //var tempheight:CGFloat = (self.BottomBar.bounds.height)+(self.navigationController?.navigationBar.bounds.height)!
        //self.containerAnimationView.frame.size.height = self.view.bounds.height-tempheight
        self.containerAnimationView.frame.size.height = self.view.bounds.height-45
        self.containerAnimationView.frame.size.width = self.view.bounds.width
        self.webViewCommon.frame = self.containerAnimationView.bounds
        
        //println("---------------X")
        //println(self.containerAnimationView.bounds.origin.y)
        //self.containerAnimationView.frame.origin.y = 0
        
        if self.newsid != nil && self.isLoadWebView == false && self.firstTouch == true {
            self.getNewsData(self.newsid,webViewStatement: self.webViewState)
            self.isLoadWebView = true
        }
        
        // ilk tıklamadaki width, height sorunu
        if self.firstTouch == false {
            self.firstTouch = true
        }

        self.bottomBarButtonReload()
    }
    
    func getNewsData(nid:String,webViewStatement:String) {
        var myHTMLString:String! = ""
        var myTitle:String! = ""
        var SummaryData:String = ""
        var row:SQLRow!
        var NewsDate:String = ""
        var myImage:[String:String]!
        var myImageTag:String = ""
        
        if (self.newsid != nil) {
            self.shareButton.enabled = true
            self.upButton.enabled = true
            self.downButton.enabled = true
            self.readButton.enabled = true
            
            
            let data = db.query("SELECT news.*,mylist.language FROM news LEFT JOIN mylist ON news.CatIdentifier=mylist.identifier WHERE news.title=?", parameters:[nid])
            // sorgudan data donuyor if ile kontrol edilecek
            
            if !data.isEmpty {
                row = data[0]
                var nid:Int = 0
                
                if let id = row["id"] {
                    nid = id.asInt()
                }

                if let name = row["title"] {
                    myTitle = "<div class=\"newstitle\">"+name.asString()+"</div>"
                    self.title = name.asString()
                    self.newsid = self.title
                }
                
                if let lang = row["language"] {
                    if lang.asString() == "RTL" {
                        self.RTLState = true
                    } else {
                        self.RTLState = false
                    }
                }
                
                if let nsummary = row["summary"] {
                    SummaryData = nsummary.asString()
                }
                
                var EnclosuresData:String = ""
                if let nenclosures = row["enclosures"] {
                    EnclosuresData = nenclosures.asString()
                }
                
                var ImageData:String = ""
                if let nimage = row["image"] {
                    ImageData = nimage.asString()
                }
                
                var ndatesql = ""
                if let ndate = row["date"] {
                    NewsDate = "<div class=\"newsdate\">"+ndate.asString()+"</div>"
                    ndatesql = (row["date"]?.asString())!
                }
                
                var CatIden:String = ""
                if let ncat = row["CatIdentifier"] {
                    CatIden = ncat.asString()
                }

                if let nlink = row["link"] {
                    self.newslink = nlink.asString()
                }
                
                // ustteki haber
                let updata = db.query("select title from news where date > ? AND CatIdentifier=? ORDER BY date ASC limit 1", parameters:[ndatesql,CatIden])
                
                if !updata.isEmpty {
                    let rowup = updata[0]
                    //var nidup:Int = 0
                    
                    if let idup = rowup["title"] {
                        self.upnewsid = idup.asString()
                        self.upButton.enabled = true
                    }
                } else {
                    // eger bossa
                    
                    let updata2 = db.query("select title from news where id < ? AND CatIdentifier=? AND date >=? ORDER BY id DESC limit 1", parameters:[nid,CatIden,ndatesql])
                    if !updata2.isEmpty {
                        let rowup = updata2[0]
                        //var nidup:Int = 0
                        
                        if let idup = rowup["title"] {
                            self.upnewsid = idup.asString()
                            self.upButton.enabled = true
                        }
                    } else {
                        //println("baska yok")
                        // yukari butonu disabled
                        self.upButton.enabled = false
                    }
                }
                
                // alttaki haber
                let downdata = db.query("select title from news where date < ? AND CatIdentifier=? ORDER BY date DESC limit 1", parameters:[ndatesql,CatIden])
                
                if !downdata.isEmpty {
                    let rowdown = downdata[0]
                    //var niddown:Int = 0
                    
                    if let iddown = rowdown["title"] {
                        self.downnewsid = iddown.asString()
                        self.downButton.enabled = true
                    }
                } else {
                    // alttaki haber
                    let downdata2 = db.query("select title from news where id > ? AND CatIdentifier=? AND date <=? ORDER BY date ASC limit 1", parameters:[nid,CatIden,ndatesql])
                    
                    if !downdata2.isEmpty {
                        let rowdown = downdata2[0]
                        //var niddown:Int = 0
                        
                        if let iddown = rowdown["title"] {
                            self.downnewsid = iddown.asString()
                            self.downButton.enabled = true
                        }
                    } else {
                        // asagi butonu disabled
                        self.downButton.enabled = false
                    }
                }
                
                myImage = String.FindImageTag(SummaryData, Enclosures: EnclosuresData, Image: ImageData)
                
                if myImage["status"] != "summary" {
                
                    myImageTag = "<img src=\""+myImage["image"]!+"\" class=\"yukanewsimage\" />";
                    //myImageTag = "<img src=\""+test2+"\" class=\"yukanewsimage\" />";
                } else {
                    //println("not found content")
                }
            } else {
                //println("summary __________________")
            }
            
            // http://img.hurriyet.com.tr/_np/6470/27226470.jpg
            /*
            let imURL = NSURL(string: "http://img.hurriyet.com.tr/_np/6470/27226470.jpg")
            let cache = Haneke.Shared.imageCache
            cache.fetch(URL: imURL!).onSuccess { (_) in
                // Hacky way of getting cache URL from Haneke
                let basePath = DiskCache.basePath().stringByAppendingPathComponent("shared-images/original/")
                let path = DiskCache(path: basePath, capacity: UINT64_MAX).pathForKey((imURL?.absoluteString)!)
                let fileURL = NSURL(fileURLWithPath: path)
                println(fileURL)
            }*/
            
            myHTMLString = String.RemoveHTMLStyle(SummaryData)
            
            // filtreyi cek
            let FiltreData = db.query("SELECT * FROM filtre")
            for frow in FiltreData {
                var tPreg = ""
                if let fpreg = frow["preg"] {
                    tPreg = fpreg.asString()
                }
                
                var tMatch = ""
                if let fmatch = frow["match"] {
                    tMatch = fmatch.asString()
                }
                
                if !tPreg.isEmpty {
                    // pattern for
                    myHTMLString = String.ReplaceHTMLTag(myHTMLString, mypattern: tPreg, mytemplate: tMatch)
                }
            }

            // font-size:\(fontSizeCSS)px;
            
            let fontCSS = Font.WEB_DEFAULT_FONT_NAME
            let fontTitleCSS = Font.WEB_TITLE_DEFAULT_FONT_NAME
            let fontSizeCSS = Font.READ_TEXT_SIZE
            //var font500base64:String = getBase64FromFile("museosans-500", "ttf")
            var cssContent = readFile("appstyle", fileType: "css")    // read css file
            
            let font100Content = readFile("base64OpenSansLight", fileType: "string")    // read css file
            let font300Content = readFile("base64OpenSansLight", fileType: "string")    // read css file
            let font500Content = readFile("base64OpenSansRegular", fileType: "string")    // read css file
            let font700Content = readFile("base64OpenSansBold", fileType: "string")    // read css file
            let font900Content = readFile("base64OpenSansSemibold", fileType: "string")    // read css file
            
            let tempFontSizeCss = fontSizeCSS.description
            cssContent = cssContent.stringByReplacingOccurrencesOfString("[FONTSIZESYTTEM]", withString: tempFontSizeCss, options: NSStringCompareOptions.LiteralSearch, range: nil)
            cssContent = cssContent.stringByReplacingOccurrencesOfString("[FONTWEBSYTTEM]", withString: fontCSS, options: NSStringCompareOptions.LiteralSearch, range: nil)
            cssContent = cssContent.stringByReplacingOccurrencesOfString("[FONTTITLEWEBSYTTEM]", withString: fontTitleCSS, options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            cssContent = cssContent.stringByReplacingOccurrencesOfString("[FONT100BASE64]", withString: font100Content, options: NSStringCompareOptions.LiteralSearch, range: nil)
            cssContent = cssContent.stringByReplacingOccurrencesOfString("[FONT300BASE64]", withString: font300Content, options: NSStringCompareOptions.LiteralSearch, range: nil)
            cssContent = cssContent.stringByReplacingOccurrencesOfString("[FONT500BASE64]", withString: font500Content, options: NSStringCompareOptions.LiteralSearch, range: nil)
            cssContent = cssContent.stringByReplacingOccurrencesOfString("[FONT700BASE64]", withString: font700Content, options: NSStringCompareOptions.LiteralSearch, range: nil)
            cssContent = cssContent.stringByReplacingOccurrencesOfString("[FONT900BASE64]", withString: font900Content, options: NSStringCompareOptions.LiteralSearch, range: nil)
            cssContent = cssContent.stringByReplacingOccurrencesOfString("[BACKGROUNDCOLOR]", withString: (self.AppColors["maincolor"] as! String), options: NSStringCompareOptions.LiteralSearch, range: nil)
            //cssContent = cssContent.stringByReplacingOccurrencesOfString("[FONTWEBSYTTEM]", withString: font500base64, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
            
            let jsContent = readFile("app", fileType: "js")   // read javascript file
            
            let detailsviewwidth = self.view.bounds.width
            
            let RTLLanguageCSS = "<style type=\"text/css\">.textClass { text-align:right !important; }.newstitle { text-align:right !important; } .newsdate { text-align:left !important; }</style>";
            
            var metaData = "<!DOCTYPE html><html><head><meta name=\"viewport\" content=\"width=\(detailsviewwidth)\"/><meta name=\"viewport\" content=\"width=\(detailsviewwidth), initial-scale=1.0, maximum-scale=1.0, user-scalable=no\" /><style type=\"text/css\">\(cssContent) </style>"
            let javascriptData = "<script type=\"text/javascript\">\(jsContent)</script></head><body>"
            
            var ReadNewsHTMLData = ""
            
            if let link = row["link"] {
                self.newslink = link.asString().trimmed()
                ReadNewsHTMLData = "<br /><br /><a class=\"readnewslink\" href=\"javascript:void(0);\" onclick=\"window.webkit.messageHandlers.ShowWebView.postMessage('\(self.newslink)');\">Read News</a></body></html>";
            }
            
            if self.RTLState {
                metaData = metaData+RTLLanguageCSS
            }

            myHTMLString = metaData+javascriptData+myTitle+NewsDate+myImageTag+myHTMLString+ReadNewsHTMLData
            let wwwpath = NSBundle.mainBundle().resourcePath
            let baseUrl = NSURL(fileURLWithPath: wwwpath!)
            //println(wwwpath)
            if webViewStatement == "webview1" {
                self.webView.loadHTMLString(myHTMLString, baseURL: baseUrl)
            } else if webViewStatement == "webview2" {
                self.webView2.loadHTMLString(myHTMLString, baseURL: baseUrl)
            } else {
                self.webViewCommon.loadHTMLString(myHTMLString, baseURL: baseUrl)
            }
            
            /*
            var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            
            var getImagePath = wwwpath.stringByAppendingPathComponent("museosans-500.ttf")
            
            var checkValidation = NSFileManager.defaultManager()

            
            if (checkValidation.fileExistsAtPath(getImagePath))
            {
                println("FILE AVAILABLE");
            }
            else
            {
                println("FILE NOT AVAILABLE");
            }*/
        }
        
    }

    // sayfa icerisindeki javascript fonksiyonu bu metoda gelir
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let id = message.body as? String {
            self.OpenWebView(id as String)
        }
    }
    
    // webview ac
    func OpenWebView(nid:String) {
        //NavigationController
        let WebPage = SVWebViewController(address: nid)
        WebPage.barsTintColor = UIColor(rgba: (self.AppColors["webviewfooter"] as! String))
        WebPage.barsBackgroundColor = UIColor(rgba: (self.AppColors["webviewfootertint"] as! String))
        //WebPage.navigationController?.toolbar.backgroundColor = UIColor.blackColor()
        //WebPage.navigationController?.toolbar.barTintColor = UIColor.blackColor()
        self.navigationController?.pushViewController(WebPage, animated: true)

        // Modal
        /*
        let WebPage = SVModalWebViewController(address: nid)
        presentViewController(WebPage, animated: true, completion: nil)
        */
    }

    // webview icin disardan javascript kodu calistirir
    func RunJavascriptCode(code:String) {
        self.webViewCommon.evaluateJavaScript(code,completionHandler:nil)
    }
    
    /*
    sharekit code
    */
    func shareCode() {
        let tstring = self.newsid+" "+self.newslink
        let firstActivityItem = tstring
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
    }
}