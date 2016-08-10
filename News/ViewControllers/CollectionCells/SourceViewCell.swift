// Copyright (c) 2014 evolved.io (http://evolved.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class SourceViewCell: UICollectionViewCell {
    var customLabel1:UILabel!
    var customSourceLabel:UILabel!
    var customDate:UILabel!
    var customLabelBackground1:UIView!
    var customLabelBackground2:UIView!
    var customTextView:UITextView!
    var customImageView:UIImageView!
    var customHeight:CGFloat!
    var customTagStateView:Bool = false
    var AppColors = NSDictionary()
    /*
    override init(style: UICollectionViewCell, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews(reuseIdentifier)
    }*/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let ConfigData = Defaults["appconfig"].dictionary
        self.AppColors = ConfigData?["color"] as! NSDictionary
        self.setupViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setData(item: [String:AnyObject]) {
        self.customLabel1.text = item["name"] as? String
        let fav = item["favicon"] as? String
        let url = NSURL(string: fav!)
        //self.customImageView?.hnk_setImageFromURL(url!)
        self.customImageView.kf_setImageWithURL(url!)
    }
    
    func setupViews() {
        //self.backgroundColor = UIColor.redColor()
        self.layer.borderColor = UIColor(rgba: "#CCCCCC").CGColor
        self.layer.borderWidth = 0.5
        
        self.customLabel1 = UILabel(frame: CGRectMake(0, 0, self.bounds.width, self.bounds.height))
        //self.customLabel1.backgroundColor = UIColor.whiteColor()
        self.customLabel1.textColor = UIColor(rgba: YukaColors.DEFAULT_TEXT_COLOR)
        self.customLabel1.numberOfLines = 2
        self.customLabel1.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.customLabel1.adjustsFontSizeToFitWidth = false
        self.customLabel1.font = Font.defaultFont
        self.customLabel1.textColor = UIColor(rgba: (self.AppColors["selectednewspagefontcolor"] as! String))
        self.contentView.addSubview(self.customLabel1)
        
        let ImageNews = UIImage(named: "newsplaceholder")
        self.customImageView = UIImageView(image: ImageNews)
        self.customImageView.frame = CGRectMake(12, 17, 16, 16)
        self.contentView.addSubview(self.customImageView)
        
        constrain(self.customLabel1,self.customImageView,self.contentView) { label1,Image1,customself in
            label1.centerY == Image1.centerY
            label1.left == Image1.right+10
            label1.right == customself.right
        }
    }

}