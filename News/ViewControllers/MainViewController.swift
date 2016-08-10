//
//  MainViewController.swift
//  News
//
//  Created by yavuz on 30/09/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation
import GoogleMobileAds

import UIKit

class MainViewController: UIViewController, GADInterstitialDelegate,GADBannerViewDelegate {
    var interstitial:GADInterstitial!
    var bannerView = GADBannerView()
    var bannerAdView = UIView()
    var bannerstate = 0
    var AdmobFull = Bool()
    var AdmobFullUnitID = String()
    var AdmobFullDelay = Double()
    
    var AdmobBanner = Bool()
    var AdmobBannerUnitID = String()
    var AdmobBannerDelay = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ConfigData = Defaults["appconfig"].dictionary
        self.AdmobFull = ConfigData?["admobfullsourcelinkopen"] as! Bool
        self.AdmobFullUnitID = ConfigData?["admobfullunitid"] as! String
        self.AdmobFullDelay = (ConfigData?["admobfulldelay"]!.doubleValue)!
        
        self.AdmobBanner = ConfigData?["admobbannersourcelinkopen"] as! Bool
        self.AdmobBannerUnitID = ConfigData?["admobbannerunitid"] as! String
        self.AdmobBannerDelay = (ConfigData?["admobbannerdelay"]!.doubleValue)!

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contentSizeDidChangeNotification:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        /*
        if Defaults.hasKey("appadstate") {
            var adstate = Defaults["appadstate"].string
            if adstate == "open" {
                if Defaults.hasKey("appadduration") {
                    var adduration = Defaults["appadduration"].double
                    if adduration != nil {
                        var AdTimer = NSTimer.scheduledTimerWithTimeInterval(adduration!, target: self, selector: Selector("adView"), userInfo: nil, repeats: false)
                    }
                }
            }
        }
        */
        
        //self.bannerView2.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60)

        //adViewHeight = bannerView.frame.size.height
        if(self.AdmobFull) {
            let adduration = self.AdmobFullDelay
            _ = NSTimer.scheduledTimerWithTimeInterval(adduration, target: self, selector: Selector("adView"), userInfo: nil, repeats: false)
        }
        if(self.AdmobBanner) {
            let addurationbanner = self.AdmobBannerDelay
            NSTimer.scheduledTimerWithTimeInterval(addurationbanner, target: self, selector: Selector("setupBannerAd"), userInfo: nil, repeats: false)
            
        }
        
    }
    

    func setupBannerAd() {
        bannerAdView = UIView()
        bannerAdView.backgroundColor = UIColor(rgba: "#000000")
        self.navigationController?.view.addSubview(bannerAdView)
        //self.navigationController.view.subviews
        //self.navigationController?.view.frame.size.height = self.view.bounds.height-60

        print(self.AdmobBannerUnitID)
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        self.bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        self.bannerView.adUnitID = self.AdmobBannerUnitID
        self.bannerView.delegate = self
        self.bannerView.rootViewController = self.navigationController
        self.bannerView.loadRequest(request)//loadRequest(GADRequest())
        self.bannerAdView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        
        self.bannerAdView.addSubview(bannerView)
        //self.navigationController!.view.sendSubviewToBack(self.bannerAdView)

        //self.navigationController?.view.bringSubviewToFront(self.bannerView)
        //self.bannerAdView.bringSubviewToFront(self.bannerView)

        //self.bannerView2.frame = CGRectMake(0, self.view.frame.size.height-kGADAdSizeSmartBannerPortrait.size.height, self.view.frame.size.width, kGADAdSizeSmartBannerPortrait.size.height)
        constrain((self.navigationController?.view)!,self.bannerAdView,self.bannerView) { mview,bview,bbview in
            bview.bottom == mview.bottom
            bview.width == mview.width
            bview.height == bbview.height
        }
    }

    
    func adViewDidReceiveAd(bview: GADBannerView!) {
        print("basarili")
        if(self.bannerstate == 0) {
        //self.navigationController?.view.frame.size.height = (self.navigationController?.view.bounds.size.height)!-bview.bounds.height
            //self.bannerAdView.frame.size.height = self.bannerView.bounds.size.height
            self.bannerstate = 1
        }
        //self.bannerAdView.frame = CGRectMake(0, (self.navigationController?.view.bounds.size.height)!, bview.bounds.width, bview.bounds.height)
        
        //self.bannerView.frame = CGRectMake(0, 0, bview.bounds.width, 100)
        
    }
    
    private func contentSizeDidChangeNotification(notification: NSNotification) {
        if let userInfo: NSDictionary = notification.userInfo {
            self.contentSizeDidChange(userInfo[UIContentSizeCategoryNewValueKey] as! String)
        }
    }
    
    
    func contentSizeDidChange(size: String) {
        // Implement in subclass
        print("content size change mainview")
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        self.interstitial.presentFromRootViewController(self)
    }
    
    func adView() {
        print(self.AdmobFullUnitID)
        self.interstitial = GADInterstitial(adUnitID: self.AdmobFullUnitID)
        self.interstitial.delegate = self
        
        let Request  = GADRequest()
        Request.testDevices = [kGADSimulatorID]
        self.interstitial.loadRequest(Request)
        print(self.interstitial.isReady)

    }
}
