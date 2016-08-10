//
//  AppDelegate.swift
//  News
//
//  Created by yavuz on 28/09/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import UIKit
import SwiftyJSON

var hasInternetConnection:Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UISplitViewControllerDelegate {
    
    var window: UIWindow?
    var drawerController: DrawerController!
    var device: Device = Device.currentDevice;
    let db = SQLiteDB.sharedInstance()
    let splitVC:UISplitViewController = UISplitViewController()
    let reachability = Reachability.reachabilityForInternetConnection()
    
    var cacheDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1]
    }
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        let tconfig = ConfigApp()
        let configAppVar = tconfig.readConfigFile()
        //println(configAppVar["title"])
        var mode = ""
        
        tconfig.setConfigDefaultVariable(configAppVar)
        let pp = Defaults["appconfig"].dictionary
        //println(pp?["properties"]?["age"])
        if let tmode: AnyObject = pp?["mode"] {
            //println(tmode)
            mode = tmode as! String
        }
        
        
        // uygulamanin moduna bak
        
        let defaultmode = "newsapp"
        var menus:NSArray
        if(mode == "newsapp") {
            
            /********************************************************************************
            haber mode
            *********************************************************************************/
            Defaults["appmode"] = "newsapp"
            
        } else if(mode == "singleapp") {
            
            /********************************************************************************
            single mode
            *********************************************************************************/
            Defaults["appmode"] = "singleapp"
            var sourceurl = ""
            if let source: AnyObject = pp?["sourceurl"] {
                //println(tmode)
                var nameapp = ""
                if let aname: AnyObject = pp?["appname"] {
                    nameapp = aname as! String
                }
                
                sourceurl = source as! String
                
                
                let sid = 1
                let sname = nameapp
                let sfavicon = ""
                let surl = sourceurl
                let sidentifier = slug(sname)
                //name,url,identifier
                _ = db.execute("INSERT OR REPLACE INTO mylist (id,name,url,identifier,favicon) VALUES (?,?,?,?,?)", parameters:[sid,sname,surl,sidentifier,sfavicon])
            }
            
            
        } else if(mode == "menuapp") {
            
            /********************************************************************************
            menu mode
            *********************************************************************************/
            
            Defaults["appmode"] = "menuapp"
            
            // menuleri oku
            menus = tconfig.readSourcesFile()
            for SearchData in menus {
                
                
                let sid = SearchData["id"] as! Int
                let sname = SearchData["title"] as! String
                let sfavicon = SearchData["favicon"] as! String
                let surl = SearchData["rsslink"] as! String
                let sidentifier = slug(sname)
                //name,url,identifier
                db.execute("INSERT OR REPLACE INTO mylist (id,name,url,identifier,favicon) VALUES (?,?,?,?,?)", parameters:[sid,sname,surl,sidentifier,sfavicon])
            }

            
        } else {
            
            if !Defaults.hasKey("appmode") {
                Defaults["appmode"] = defaultmode
            }
            
            
        }
        
        
        if !Defaults.hasKey("applang") {
            Defaults["applang"] = "en"
            ChangeLanguage("en")
        }
        
        if !Defaults.hasKey("appautorefresh") {
            Defaults["appautorefresh"] = 1
        }
        
        if !Defaults.hasKey("appsounds") {
            Defaults["appsounds"] = 1
        }
        
        // Setup XCGLogger
        // let logPath : NSURL = self.cacheDirectory.URLByAppendingPathComponent("XCGLogger_Log.txt")
        // log.setup(logLevel: .Info, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: logPath)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if !device.isPad() {
            let LeftMenuDrawViewController = MainLeftMenuViewController()
            let CenterDrawViewController = CenterViewController()
            
            let navigationController = UINavigationController(rootViewController: CenterDrawViewController)
            navigationController.restorationIdentifier = "ExampleCenterNavigationControllerRestorationKey"
            
            //#CONFIG : single mode olunca bu satirlar commentlenecek - start
            if(mode != "singleapp") {
                let leftSideNavController = UINavigationController(rootViewController: LeftMenuDrawViewController)
                leftSideNavController.restorationIdentifier = "ExampleLeftNavigationControllerRestorationKey"
                
                self.drawerController = DrawerController(centerViewController: navigationController, leftDrawerViewController: leftSideNavController);
                self.drawerController.showsShadows = false
                
                self.drawerController.restorationIdentifier = "Drawer"
                self.drawerController.maximumLeftDrawerWidth = 250.0
                
                self.drawerController.openDrawerGestureModeMask = .All
                self.drawerController.closeDrawerGestureModeMask = .All
                
                self.drawerController.shouldStretchDrawer = false
                self.drawerController.navigationController?.navigationBarHidden = true
                self.window?.rootViewController = self.drawerController
            } else if(mode == "singleapp"){
                self.window?.rootViewController = navigationController
            }
            // commentlenecek - finish
            
            
            //
        } else {
            
            let LeftMenuDrawViewController = MainLeftMenuViewController()
            let CenterDrawViewController = CenterViewController()
            
            let navigationController = UINavigationController(rootViewController: CenterDrawViewController)
            navigationController.restorationIdentifier = "ExampleCenterNavigationControllerRestorationKey"
            
            
            
            let leftSideNavController = UINavigationController(rootViewController: LeftMenuDrawViewController)
            leftSideNavController.restorationIdentifier = "ExampleLeftNavigationControllerRestorationKey"
            
            self.drawerController = DrawerController(centerViewController: navigationController, leftDrawerViewController: leftSideNavController);
            self.drawerController.showsShadows = false
            
            self.drawerController.restorationIdentifier = "Drawer"
            self.drawerController.maximumLeftDrawerWidth = 250.0
            
            self.drawerController.openDrawerGestureModeMask = .All
            self.drawerController.closeDrawerGestureModeMask = .All
            
            
            self.drawerController.shouldStretchDrawer = false
            self.drawerController.navigationController?.navigationBarHidden = true
            
            let ReadController = ReadViewController()
            let Read = UINavigationController(rootViewController: ReadController)
            
            //let CenterController = CenterViewController()
            //let CenterController = MainLeftMenuViewController()
            //CenterController.view.frame = CenterController.view.bounds
            //let Center = UINavigationController(rootViewController: navigationController)
            
            
            if(mode == "singleapp") {
                splitVC.viewControllers = [navigationController,Read]
            } else if(mode != "singleapp") {
                let Center = UINavigationController(rootViewController: self.drawerController)
                Center.navigationBar.hidden = true
                splitVC.viewControllers = [Center,Read]
            }
            
            splitVC.delegate = self
            splitVC.view.backgroundColor = UIColor(rgba: "#4E3F7F")
            
            self.window?.rootViewController = splitVC
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        
        reachability!.startNotifier()
        
        if reachability!.isReachable() {
            hasInternetConnection = true
        } else {
            hasInternetConnection = false
        }
        
        // font list enable
        //self.getFontList()
        
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func getFontList() {
        for fontFamilyName in UIFont.familyNames() {
            print("This is the font family: \(fontFamilyName)")
            for fontName in UIFont.fontNamesForFamilyName(fontFamilyName.debugDescription) {
                print("    This is the font name: \(fontName)")
            }
        }
    }
    /*
    func getFiltre() {
        let url = NSURL(string: "http://domain.com/settings.php")
        let request = NSURLRequest(URL: url!)
        //var JsonUrlData:NSString!
        var rqueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: rqueue) {(response, JsonUrlData, error) in
            //JsonUrlData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println(JsonUrlData)
            if JsonUrlData != nil {
                let json = SwiftyJSON.JSON(data: JsonUrlData!)
                var items:[[String:AnyObject]] = []
                for(key: String, SearchData: JSON) in json[0]["filtre"] {
                    
                    var ObjectData = [String: String]
                    
                    ObjectData["preg"] = SearchData["preg"].stringValue
                    ObjectData["match"] = SearchData["match"].stringValue
                    //let searchname = turkishSlug(name).lowercaseString
                    items.append(ObjectData)
                }
                //println(self.items)
                
                
                
                if !items.isEmpty {
                    let db = SQLiteDB.sharedInstance()
                    db.execute("DELETE FROM filtre")
                    
                    for pregItem in items {
                        var TempPreg = pregItem["preg"] as! String
                        
                        var TempMatch = pregItem["match"] as! String
                        
                        let result = self.db.execute("INSERT OR REPLACE INTO filtre (preg,match) VALUES (?,?)", parameters:[TempPreg,TempMatch])
                    }
                    
                    
                    // database ekle
                } else {
                    // eger data yoksa viewi gosterilecek
                }
                
                // ads durumu
                var adstate = json[0]["ads"]
                for(key: String, ADData: JSON) in adstate {
                    Defaults["appadstate"] = ADData["state"].stringValue
                    Defaults["appadduration"] = ADData["duration"].doubleValue
                }
            }
        }
    }
    */
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //self.window.backgroundColor = UIColor.whiteColor()
        //self.window.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    deinit {
        reachability!.stopNotifier()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            // baglanti var
            hasInternetConnection = true
        } else {
            hasInternetConnection = false
            
            // eger baglangi yoksa
            let notification: NSNotification = NSNotification(name: "StopParsingTimer", object: nil, userInfo: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
}

