//
//  LeftMenuViewCell.swift
//  News
//
//  Created by yavuz on 04/11/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class MenuItem {
    var title: String = ""
    var identifier:String = ""
    var link:String = ""
    var favicon:String = ""
}

class LeftMenuViewCell: UITableViewCell {
    var customLabel1:UILabel!
    var faviconImage:UIImageView!
    var FavImageURL:NSURL!
    var AppColors = NSDictionary()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let ConfigData = Defaults["appconfig"].dictionary
        self.AppColors = ConfigData?["color"] as! NSDictionary
        
        self.setupViews(reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(item:[String:AnyObject]) {

        customLabel1.text = textCharacterLimit((item["name"] as? String)!, range: 4)
        if (item["url"] as! String) != "native" {
            let favURL = item["favicon"] as! String
            /*var temptest = ""
            if (favURL?.host != nil) {
                temptest = (favURL?.host)!
            }*/
            //@FIX sub url silinecek
            //let fav = "http://www.google.com/s2/favicons?domain="+temptest//+(favURL?.host)!
            
            self.FavImageURL = NSURL(string: favURL)
        } else {
            // last news
            self.FavImageURL = NSURL(string: "http://yavuzyildirim.com/native.png")
        }
        //self.faviconImage.hnk_setImageFromURL(self.FavImageURL)
        self.faviconImage.kf_setImageWithURL(self.FavImageURL)

    }
    
    func setupViews(CellState:String?) {
        self.backgroundColor = UIColor(rgba: self.AppColors["leftmenu"] as! String)  // UIColor(rgba: "#F4F4F4")
        //self.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight

        self.faviconImage = UIImageView(frame: CGRectMake(10, ((self.bounds.height/2)-11), 16, 16))
        self.faviconImage.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
        self.contentView.addSubview(self.faviconImage)
        
        customLabel1 = UILabel(frame: CGRectMake(36, 0, self.bounds.width, self.bounds.height))
        //customLabel1.backgroundColor = UIColor.redColor()
        customLabel1.lineBreakMode = NSLineBreakMode.ByWordWrapping
        customLabel1.font = Font.menuFont
        customLabel1.textColor = UIColor(rgba: (self.AppColors["leftmenufontcolor"] as! String))
        customLabel1.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        //customLabel1.numberOfLines = 2
        self.contentView.addSubview(customLabel1)
    }
    
}