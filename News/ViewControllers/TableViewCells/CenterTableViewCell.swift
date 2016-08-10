//
//  LeftMenuViewCell.swift
//  News
//
//  Created by yavuz on 04/11/14.
//  Copyright (c) 2014 yuka. All rights reserved.
//

import UIKit


class CenterTableViewCell: UITableViewCell {
    var customLabel1:UILabel!
    var customSourceLabel:UILabel!
    var customDate:UILabel!
    var customLabelBackground1:UIView!
    var customLabelBackground2:UIView!
    var customTextView:UITextView!
    var customImageView:UIImageView!
    var customHeight:CGFloat!
    var customTagStateView:Bool = false
    var customBottomLine:UIView!
    var RTLState:Bool = false
    var AppColors = NSDictionary()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let ConfigData = Defaults["appconfig"].dictionary
        self.AppColors = ConfigData?["color"] as! NSDictionary
        
        self.setupViews(reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setViewTag(state:Bool) {
        self.customTagStateView = state
    }
    
    func setRTLStateFunc(state:Bool) {
        self.RTLState = state
    }
    
    func setData(item:NewsFeedItem) {
        if !item.title.isEmpty {
            var title = item.title
            if !title.isEmpty {
                title = String.stringByRemovingHTMLEntities(title)
                self.customLabel1.text = title.trimmed()
            }
            
            if((self.customSourceLabel) != nil && !item.sname.isEmpty) {
                self.customSourceLabel.text = textCharacterLimit(item.sname,range: 2)
            }
            
            if(self.customTagStateView) {
                if((self.customSourceLabel) != nil) {
                    self.customSourceLabel.hidden = false
                }
                if((self.customLabelBackground2) != nil) {
                    self.customLabelBackground2.hidden = false
                }
            } else {
                if((self.customSourceLabel) != nil) {
                    self.customSourceLabel.hidden = true
                }
                if((self.customLabelBackground2) != nil) {
                    self.customLabelBackground2.hidden = true
                }
            }
            
            if((self.customDate) != nil && item.date != nil) {
                self.customDate.text = MHPrettyDate.prettyDateFromDate(item.date, withFormat: MHPrettyDateLongRelativeTime)
            }
            
            if !item.imageLink.isEmpty {
                self.customImageView.image = UIImage(named: "firstnewsplaceholder")!
                self.customImageView.alpha = 0
                let EspaceURL = item.imageLink.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                let fext = NSString(string: EspaceURL!).pathExtension
                let elements = ["gif","png","jpg","jpeg","bmp","tif","svg"]   // accept image extensions
                let tempfext:String = (fext.lowercaseString)
                
                // uzanti kontrolu
                if elements.contains(tempfext) {
                    let URL: NSURL = NSURL(string: EspaceURL!)!
                    //self.customImageView.hnk_setImageFromURL(URL)
                    
                    //imageView.kf_setImageWithURL(NSURL(string: "http://your_image_url.png")!)
                    self.customImageView.kf_setImageWithURL(URL)
                    
                } else {
                    var myStringArr = tempfext.componentsSeparatedByString("?")
                    if !(myStringArr.isEmpty) {
                        let tempfext:String = (myStringArr[0].lowercaseString)
                        
                        if elements.contains(tempfext) {
                            let URL: NSURL = NSURL(string: EspaceURL!)!
                            //self.customImageView.hnk_setImageFromURL(URL)
                            self.customImageView.kf_setImageWithURL(URL)
                        }
                    }
                }

                self.customImageView.contentMode = UIViewContentMode.ScaleAspectFill
                UIView.animateWithDuration(0.3,
                    delay: 0,
                    options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction],
                    animations: {
                        self.customImageView.alpha = 1
                    },
                    completion: { finished in
                        
                    }
                )
                
                
            } else {
                //println("imagetag yok")
                self.customImageView.image = UIImage(named: "firstnewsplaceholder")!
            }
            
            // support RTL
            if self.RTLState {
                customLabel1.textAlignment = NSTextAlignment.Right
            } else {
                customLabel1.textAlignment = NSTextAlignment.Left
            }
            
        }
    }
    /*
    override func prepareForReuse() {
        self.customImageView.netImage.URL = nil; // Sets image to placeholderImage or empty if no placeholder image is present.
    }*/
    
    func setupViews(CellState:String?) {
        self.backgroundColor = UIColor(rgba: (self.AppColors["maincolor"] as! String))
        //self.contentView.layer.borderWidth = 2
        //self.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        if CellState == "First" {
            self.customHeight = 190
            let image3 = UIImage(named: "firstnewsplaceholder")!
            //image3 = RBSquareImageTo(image3, CGSizeMake(136, 136))
            customImageView = UIImageView(image: image3)
            customImageView.frame = self.bounds
            customImageView.backgroundColor = UIColor(rgba: "#DDDDDD")
            customImageView.translatesAutoresizingMaskIntoConstraints = false
            customImageView.contentMode = UIViewContentMode.ScaleAspectFit
            customImageView.clipsToBounds = true
            customImageView.layer.cornerRadius = 2
            self.addSubview(customImageView)

            customLabelBackground1 = UIView()
            customLabelBackground1.backgroundColor = UIColor.blackColor()
            customLabelBackground1.alpha = 0.7
            customLabelBackground1.translatesAutoresizingMaskIntoConstraints = false
            customLabelBackground1.hidden = false
            self.addSubview(customLabelBackground1)
            

            customLabel1 = UILabel()
            customLabel1.textColor = UIColor.whiteColor()
            customLabel1.font = Font.defaultBoldFont
            customLabel1.numberOfLines = 2
            customLabel1.translatesAutoresizingMaskIntoConstraints = false
            customLabel1.hidden = false
            self.addSubview(customLabel1)
            /*
            layout(customImageView,customLabel1,customLabelBackground1) { view,view2,view3 in
                view.height == view.superview!.height
                view.width == view.superview!.width
                
                view2.bottom == (view.superview?.bottom)!-5
                view2.left == (view.superview?.left)!+5
                view2.width <= (view2.superview?.width)!    // maximum
                view2.width >= view2.width    // minimum
                
                view3.center == view2.center
                view3.left == view2.left-5
                view3.right == view2.right+5
                view3.top == view2.top-5
                view3.bottom == view2.bottom+5
            }
            */
            
            constrain(customImageView,customLabel1,customLabelBackground1) { view,view2,view3 in
                view.height == view.superview!.height-10
                view.width == (view.superview!.width)-10
                
                view.top == (view.superview?.top)!+5
                view.left == (view.superview?.left)!+5
                
                view2.bottom == (view.superview?.bottom)!-10
                view2.left == view.left+5
                view2.right == view.right-5
                
                view3.center == view2.center
                view3.left == view2.left-5
                view3.right == view2.right+5
                view3.top == view2.top-5
                view3.bottom == view2.bottom+5
                
                /*
                view.height == view.superview!.height-10
                view.width == (view.superview!.width)-10
                
                view.top == (view.superview?.top)!+5
                view.left == (view.superview?.left)!+5
                
                
                view2.bottom == (view.superview?.bottom)!-10
                view2.left == (view.superview?.left)!+10
                view2.width <= (view2.superview?.width)!    // maximum
                view2.width >= view2.width    // minimum
                
                view3.center == view2.center
                view3.left == view2.left-5
                view3.right == view2.right+5
                view3.top == view2.top-5
                view3.bottom == view2.bottom+5
                */
            }
        } else {
            
            self.customHeight = 100
            //let imageWidth = (self.bounds.width*32/100)
            customImageView = UIImageView(image: UIImage(named: "firstnewsplaceholder")!)
            //customImageView.hnk_setImage(image)
            customImageView.backgroundColor = UIColor(rgba: "#DDDDDD")
            customImageView.translatesAutoresizingMaskIntoConstraints = false
            customImageView.contentMode = UIViewContentMode.ScaleAspectFill
            customImageView.layer.borderColor = UIColor(rgba: "#DFDFDF").CGColor
            customImageView.layer.borderWidth = 0
            customImageView.clipsToBounds = true
            customImageView.layer.cornerRadius = 2

            self.addSubview(customImageView)
            
            customLabel1 = UILabel()
            customLabel1.font = Font.defaultMediumFont
            customLabel1.textColor = Font.defaultFontColor
            customLabel1.translatesAutoresizingMaskIntoConstraints = false
            customLabel1.numberOfLines = 2
            customLabel1.hidden = false
            
            self.addSubview(customLabel1)
            
            customLabelBackground2 = UIView()
            customLabelBackground2.backgroundColor = UIColor(rgba: "#56A1E4")
            customLabelBackground2.alpha = 0.7
            customLabelBackground2.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(customLabelBackground2)
            
            customSourceLabel = UILabel()
            customSourceLabel.font = Font.defaultSmallFont
            customSourceLabel.textColor = UIColor.whiteColor()
            customSourceLabel.translatesAutoresizingMaskIntoConstraints = false
            customSourceLabel.numberOfLines = 1
            self.addSubview(customSourceLabel)
            
            customDate = UILabel()
            customDate.font = Font.defaultSmallFont
            customDate.textColor = Font.defaultFontColor
            customDate.translatesAutoresizingMaskIntoConstraints = false
            customDate.numberOfLines = 1
            self.addSubview(customDate)
            
            customBottomLine = UIView(frame: CGRectMake(0, customHeight, self.bounds.width, 1))
            customBottomLine.backgroundColor = UIColor.grayColor()
            customBottomLine.alpha = 0.1
            customBottomLine.hidden = true
            customBottomLine.opaque = true
            customBottomLine.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(customBottomLine)
            
/*
            
            // 100%
            layout(customImageView,customLabel1) { view,view2 in
                view.height == view.superview!.height
                view.width == (view.superview!.width * 40)/100
                view2.width == ((view2.superview!.width * 60)/100)-20
                view2.left == view.right+10
                view2.top == view.top+4
            }
            */
            
            constrain(customImageView,customLabel1) { view,view2 in
                view.height == (view.superview!.height)-10
                view.width == (view.superview!.width * 35)/100
                view.top == (view.superview?.top)!+5
                view.left == (view.superview?.left)!+5
                view2.width == ((view2.superview!.width * 60)/100)-20
                view2.left == view.right+10
                view2.top == view.top+4
            }
            
            constrain(customImageView,customLabelBackground2,customSourceLabel) { view,viewback,view2 in
                viewback.left == view.right+5
                view2.left == viewback.left+5
                view2.bottom == view.bottom-5
                viewback.right == view2.right+5
                viewback.top == view2.top-2
                viewback.bottom == view2.bottom+2
            }
            
            
            constrain(customDate) { viewDate in
                viewDate.right == viewDate.superview!.right-5
                viewDate.bottom == viewDate.superview!.bottom-5
            }
            
            constrain(customBottomLine) { viewBottomLine in
                viewBottomLine.width == viewBottomLine.superview!.width
                viewBottomLine.bottom == viewBottomLine.superview!.bottom
                viewBottomLine.height == 1
            }
            /*
            
            view3.right == view3.superview!.right-5
            view3.bottom == view.bottom-5*/
        }

    }

}